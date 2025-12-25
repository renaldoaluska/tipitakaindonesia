// lib/services/sutta.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class SuttaService {
  static const String baseUrl = "https://suttacentral.net/api";

  static Future<dynamic> fetchMenu(String uid, {String language = "id"}) async {
    final url = Uri.parse("$baseUrl/menu/$uid?language=$language");
    final res = await http.get(url);
    if (res.statusCode == 200) return json.decode(res.body);
    throw Exception("Gagal memuat menu untuk $uid");
  }

  static Future<dynamic> fetchSuttaplex(
    String uid, {
    String language = "id",
  }) async {
    final url = Uri.parse("$baseUrl/suttaplex/$uid?language=$language");
    final res = await http.get(url);
    if (res.statusCode == 200) return json.decode(res.body); // List
    throw Exception("Gagal memuat detail sutta untuk $uid");
  }

  /// Ambil teks sutta sesuai translator.
  /// segmented = true → bilarasuttas, else → suttas
  static Future<Map<String, dynamic>> fetchTextForTranslation({
    required String uid,
    required String authorUid,
    required String lang,
    required bool segmented,
    String siteLanguage = "id",
  }) async {
    final Uri url = segmented
        ? Uri.parse("$baseUrl/bilarasuttas/$uid/$authorUid?lang=$lang")
        : Uri.parse(
            "$baseUrl/suttas/$uid/$authorUid?lang=$lang&siteLanguage=$siteLanguage",
          );

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception("Gagal memuat teks ($uid, $authorUid, $lang)");
    }

    final raw = json.decode(res.body);

    // ✅ Flatten segments agar mudah dipakai di model/UI
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey("translation") &&
          raw["translation"] is Map &&
          raw["translation"].containsKey("segments")) {
        raw["segments"] = raw["translation"]["segments"];
      } else if (raw.containsKey("root_text") &&
          raw["root_text"] is Map &&
          raw["root_text"].containsKey("segments")) {
        raw["segments"] = raw["root_text"]["segments"];
      }
    }

    return Map<String, dynamic>.from(raw);
  }
}
