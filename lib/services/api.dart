import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class Api {
  Api._(); // no instance

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://suttacentral.net/api/",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// =========================
  /// SIMPLE IN-MEMORY CACHE
  /// =========================

  static final Map<String, _CacheEntry> _cache = HashMap();
  static final Map<String, Future<dynamic>> _inflight = {};

  /// default TTL
  static const Duration _defaultTTL = Duration(minutes: 10);

  /// =========================
  /// PUBLIC GET
  /// =========================
  /// Tambahin batas maksimal cache biar HP ga meledak
  static const int _maxCacheSize = 100;

  static Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    Duration ttl = _defaultTTL,
    bool forceRefresh = false,
  }) async {
    final key = _makeKey(path, query);

    // 1. Cek Inflight (tetap sama)
    if (_inflight.containsKey(key)) {
      return _inflight[key]!;
    }

    // 2. Cek Cache (tetap sama)
    if (!forceRefresh && _cache.containsKey(key)) {
      final entry = _cache[key]!;
      if (!entry.isExpired) {
        return entry.data;
      } else {
        _cache.remove(key);
      }
    }

    // 3. Request API
    final future = _dio
        .get(path, queryParameters: query)
        .then((res) {
          // --- TAMBAHAN: Memory Safety ---
          if (_cache.length >= _maxCacheSize) {
            // Hapus entry pertama (paling tua dimasukin) kalau penuh
            // Atau bisa clear semua: _cache.clear();
            final firstKey = _cache.keys.first;
            _cache.remove(firstKey);
          }
          // -------------------------------

          _cache[key] = _CacheEntry(
            data: res.data,
            expiry: DateTime.now().add(ttl),
          );
          return res.data;
        })
        // --- REVISI: Error Handling ---
        // Jangan di-catch lalu di-throw Exception string doang.
        // Biarin UI yang handle DioException, atau rethrow.
        .catchError((e) {
          debugPrint("❌ Error [$path]: $e");
          throw e; // Lempar aslinya biar UI tau ini timeout/404/dll
        })
        // -----------------------------
        .whenComplete(() {
          _inflight.remove(key);
        });

    _inflight[key] = future;
    return future;
  }

  /// =========================
  /// CACHE CONTROL
  /// =========================

  /// Clear seluruh cache
  static void clear() {
    _cache.clear();
    debugPrint("🗑️ Cache cleared");
  }

  /// Invalidate specific entry
  static void invalidate(String path, {Map<String, dynamic>? query}) {
    final key = _makeKey(path, query);
    _cache.remove(key);
    debugPrint("🔄 Invalidated: $path");
  }

  /// Get cache stats (untuk monitoring/debug)
  static Map<String, int> getStats() {
    return {
      "cached_entries": _cache.length,
      "inflight_requests": _inflight.length,
    };
  }

  /// Print cache stats ke console
  static void printStats() {
    final stats = getStats();
    debugPrint(
      "📊 Cache Stats: ${stats['cached_entries']} entries, ${stats['inflight_requests']} inflight",
    );
  }

  /// =========================
  /// INTERNAL
  /// =========================

  static String _makeKey(String path, Map<String, dynamic>? query) {
    if (query == null || query.isEmpty) return path;
    final sorted = Map.fromEntries(
      query.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return "$path?${sorted.entries.map((e) => "${e.key}=${e.value}").join("&")}";
  }
}

/// =========================
/// CACHE ENTRY
/// =========================

class _CacheEntry {
  final dynamic data;
  final DateTime expiry;

  _CacheEntry({required this.data, required this.expiry});

  bool get isExpired => DateTime.now().isAfter(expiry);
}
