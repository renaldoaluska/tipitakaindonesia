// lib/services/sutta.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class SuttaService {
  static const String baseUrl = "https://suttacentral.net/api";

  /// Ambil daftar menu untuk sebuah sutta
  static Future<dynamic> fetchMenu(String uid, {String language = "id"}) async {
    final url = Uri.parse("$baseUrl/menu/$uid?language=$language");
    final res = await http.get(url);
    if (res.statusCode == 200) return json.decode(res.body);
    throw Exception("Gagal memuat menu untuk $uid");
  }

  /// Ambil metadata suttaplex (judul, info singkat, dll.)
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

    // ✅ Flatten agar mudah dipakai di model/UI
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey("translation_text")) {
        // Bilara terjemahan (Sujato, dll.)
        raw["segments"] = raw["translation_text"];
      } else if (raw.containsKey("comment_text")) {
        // Catatan modern Sujato (bukan Atthakathā/Tīkā klasik)
        raw["segments"] = raw["comment_text"];
      } else if (raw.containsKey("translation") &&
          raw["translation"] is Map &&
          raw["translation"].containsKey("segments")) {
        // Legacy translation
        raw["segments"] = raw["translation"]["segments"];
      } else if (raw.containsKey("root_text") &&
          raw["root_text"] is Map &&
          raw["root_text"].containsKey("segments")) {
        // Pāli root text
        raw["segments"] = raw["root_text"]["segments"];
      }
    }

    return Map<String, dynamic>.from(raw);
  }
}
