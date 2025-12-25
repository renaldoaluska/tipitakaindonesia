import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';
import '../models/sutta_text.dart';

class SuttaDetail extends StatelessWidget {
  final String uid;
  final String lang;
  final Map<String, dynamic>? textData;

  const SuttaDetail({
    super.key,
    required this.uid,
    required this.lang,
    required this.textData,
  });

  Widget _buildSegmentList(List<MapEntry<String, String>> segments) {
    return ListView.builder(
      itemCount: segments.length,
      itemBuilder: (context, index) {
        final seg = segments[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(seg.value, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              Text(
                seg.key,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Divider(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (textData == null || textData!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("$uid [$lang]")),
        body: const Center(child: Text("Teks tidak tersedia")),
      );
    }

    Widget body;

    // ✅ Case 1: segmented sutta (segments di root)
    if (textData!.containsKey("segments")) {
      final sutta = SegmentedSutta.fromJson(textData!);
      body = _buildSegmentList(sutta.segments.entries.toList());

      // ✅ Case 2: nested translation.segments
    } else if (textData!.containsKey("translation") &&
        textData!["translation"].containsKey("segments")) {
      final segs = Map<String, String>.from(
        textData!["translation"]["segments"],
      );
      final sutta = SegmentedSutta(uid: uid, lang: lang, segments: segs);
      body = _buildSegmentList(sutta.segments.entries.toList());

      // ✅ Case 3: nested root_text.segments
    } else if (textData!.containsKey("root_text") &&
        textData!["root_text"].containsKey("segments")) {
      final segs = Map<String, String>.from(textData!["root_text"]["segments"]);
      final sutta = SegmentedSutta(uid: uid, lang: lang, segments: segs);
      body = _buildSegmentList(sutta.segments.entries.toList());

      // ✅ Case 4: non-segmented sutta (root_text.text)
    } else if (textData!.containsKey("root_text")) {
      final root = Map<String, dynamic>.from(textData!["root_text"]);
      final sutta = NonSegmentedSutta.fromJson(root);

      // decode HTML escaped string (\u003C = <)
      final unescape = HtmlUnescape();
      final decoded = unescape.convert(sutta.text);

      body = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Html(
          data: decoded,
          style: {
            "p": Style(fontSize: FontSize(16), lineHeight: LineHeight(1.5)),
            "h1": Style(fontSize: FontSize(22), fontWeight: FontWeight.bold),
            "h2": Style(fontSize: FontSize(18), fontWeight: FontWeight.w600),
          },
        ),
      );

      // ✅ Fallback
    } else {
      body = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(textData.toString()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("$uid [$lang]")),
      body: body,
    );
  }
}
