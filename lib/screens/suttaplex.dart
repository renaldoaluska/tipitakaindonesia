import 'package:flutter/material.dart';
import '../services/sutta.dart';
import 'sutta_detail.dart';

class Suttaplex extends StatefulWidget {
  final String uid;
  const Suttaplex({super.key, required this.uid});

  @override
  State<Suttaplex> createState() => _SuttaplexState();
}

class _SuttaplexState extends State<Suttaplex> {
  Map<String, dynamic>? _sutta;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchSuttaplex();
  }

  Future<void> _fetchSuttaplex() async {
    try {
      final raw = await SuttaService.fetchSuttaplex(widget.uid, language: "id");
      final data = (raw is List && raw.isNotEmpty) ? raw[0] : null;
      if (data == null) {
        setState(() {
          _sutta = null;
          _loading = false;
        });
        return;
      }

      final translations = List<Map<String, dynamic>>.from(
        data["translations"] ?? [],
      );

      final langs = translations.map((t) => t["lang"]).toSet();

      // ✅ Ensure Pāli option exists
      if (!langs.contains("pli")) {
        translations.insert(0, {
          "lang": "pli",
          "author": "Teks Pāli",
          "author_uid": "ms",
          "segmented": true,
        });
      }

      // ✅ Ensure Indonesian option exists (dummy if missing)
      if (!langs.contains("id")) {
        translations.add({
          "lang": "id",
          "author": "Belum ada terjemahan Indonesia",
          "author_uid": "",
          "segmented": false,
          "disabled": true,
        });
      }

      final filtered = translations
          .where((t) => ["id", "en", "pli"].contains(t["lang"]))
          .toList();

      // urutkan: pli → id → en
      filtered.sort((a, b) {
        const order = {"pli": 0, "id": 1, "en": 2};
        return (order[a["lang"]] ?? 99).compareTo(order[b["lang"]] ?? 99);
      });

      data["filtered_translations"] = filtered;

      setState(() {
        _sutta = data;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error fetch suttaplex: $e");
      setState(() => _loading = false);
    }
  }

  Widget buildTranslationList(List<dynamic> translations) {
    if (translations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          "Terjemahan belum tersedia dalam bahasa Indonesia, Inggris, atau Pāli.",
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: translations.map((t) {
        final String lang = (t["lang"] ?? "") as String;
        final String author = (t["author"] ?? "") as String;
        final String authorUid = (t["author_uid"] ?? "") as String;
        final bool segmented = (t["segmented"] ?? false) as bool;
        final bool disabled = (t["disabled"] ?? false) as bool;

        final label = lang == "id"
            ? "Bahasa Indonesia"
            : lang == "en"
            ? "Bahasa Inggris"
            : "Bahasa Pāli";

        // ✅ Icon berbeda untuk Pāli
        final icon = lang == "pli" ? Icons.menu_book : Icons.translate;

        return ListTile(
          leading: Icon(icon),
          title: Text(
            label,
            style: TextStyle(color: disabled ? Colors.grey : Colors.black),
          ),
          subtitle: Text(
            author,
            style: TextStyle(color: disabled ? Colors.grey : Colors.black54),
          ),
          enabled: !disabled,
          onTap: disabled
              ? null
              : () async {
                  try {
                    final textData = await SuttaService.fetchTextForTranslation(
                      uid: _sutta?["uid"] ?? widget.uid,
                      authorUid: authorUid.isNotEmpty ? authorUid : "ms",
                      lang: lang,
                      segmented: segmented,
                    );

                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SuttaDetail(
                          uid: widget.uid,
                          lang: lang,
                          textData: textData,
                        ),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Gagal memuat teks untuk $label")),
                    );
                  }
                },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title =
        _sutta?["translated_title"] ?? _sutta?["original_title"] ?? widget.uid;
    final blurb = _sutta?["blurb"] ?? "";
    final translations = _sutta?["filtered_translations"] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.uid.toUpperCase()),
        leading: IconButton(
          icon: const Icon(Icons.close), // atau Icons.arrow_back
          onPressed: () {
            Navigator.of(context).pop(); // nutup bottom sheet / page
          },
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sutta == null
          ? const Center(child: Text("Data tidak tersedia"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(blurb),
                  const Divider(height: 32),
                  const Text(
                    "Pilih Bahasa:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  buildTranslationList(translations),

                  const SizedBox(height: 24),
                  const Text(
                    "Tafsiran Aṭṭhakathā:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  ListTile(
                    leading: const Icon(Icons.menu_book),
                    title: const Text("Bahasa Pāli"),
                    subtitle: const Text(
                      "Buddhaghosa",
                      style: TextStyle(color: Colors.grey),
                    ),
                    enabled: false,
                  ),
                  ListTile(
                    leading: const Icon(Icons.menu_book),
                    title: const Text("Bahasa Indonesia"),
                    subtitle: const Text(
                      "Belum ada terjemahan Indonesia",
                      style: TextStyle(color: Colors.grey),
                    ),
                    enabled: false,
                  ),

                  // 👉 Tambahan baru di bawah Tafsiran Ṭīkā
                  const SizedBox(height: 24),
                  const Text(
                    "Tafsiran Ṭīkā:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  ListTile(
                    leading: const Icon(Icons.menu_book),
                    title: const Text("Bahasa Pāli"),
                    subtitle: const Text(
                      "Dhammapāla",
                      style: TextStyle(color: Colors.grey),
                    ),
                    enabled: false,
                  ),
                  ListTile(
                    leading: const Icon(Icons.menu_book),
                    title: const Text("Bahasa Indonesia"),
                    subtitle: const Text(
                      "Belum ada terjemahan Indonesia",
                      style: TextStyle(color: Colors.grey),
                    ),
                    enabled: false,
                  ),
                ],
              ),
            ),
    );
  }
}
