import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';
import '../models/sutta_text.dart';

enum ViewMode { englishOnly, lineByLine, sideBySide }

class SuttaDetail extends StatefulWidget {
  final String uid;
  final String lang;
  final Map<String, dynamic>? textData;

  const SuttaDetail({
    super.key,
    required this.uid,
    required this.lang,
    required this.textData,
  });

  @override
  State<SuttaDetail> createState() => _SuttaDetailState();
}

class _SuttaDetailState extends State<SuttaDetail> {
  ViewMode _viewMode = ViewMode.lineByLine;

  @override
  Widget build(BuildContext context) {
    if (widget.textData == null || widget.textData!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("${widget.uid} [${widget.lang}]")),
        body: const Center(child: Text("Teks tidak tersedia")),
      );
    }

    final segmented = SegmentedSutta.fromJson(widget.textData!);

    final paliSegs = (widget.textData!["root_text"] is Map)
        ? (widget.textData!["root_text"] as Map).map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          )
        : <String, String>{};

    final translationSegs = (widget.textData!["translation_text"] is Map)
        ? (widget.textData!["translation_text"] as Map).map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          )
        : segmented.segments;

    final commentarySegs = (widget.textData!["comment_text"] is Map)
        ? (widget.textData!["comment_text"] as Map).map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          )
        : <String, String>{};

    final keysOrder = widget.textData!["keys_order"] is List
        ? List<String>.from(widget.textData!["keys_order"])
        : translationSegs.keys.toList();

    final hasTranslationMap =
        widget.textData!["translation_text"] is Map &&
        (widget.textData!["translation_text"] as Map).isNotEmpty;
    final isSegmented = hasTranslationMap && keysOrder.isNotEmpty;

    Widget body;

    if (isSegmented) {
      switch (_viewMode) {
        case ViewMode.englishOnly:
          body = ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: keysOrder.length,
            itemBuilder: (context, index) {
              final key = keysOrder[index];
              final trans = translationSegs[key] ?? "";
              final comm = commentarySegs[key] ?? "";
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (trans.isNotEmpty) Html(data: trans),
                  if (comm.isNotEmpty)
                    Html(
                      data: comm,
                      style: {
                        "p": Style(
                          fontSize: FontSize(14),
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
                      },
                    ),
                  const SizedBox(height: 12),
                ],
              );
            },
          );
          break;

        case ViewMode.lineByLine:
          body = ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: keysOrder.length,
            itemBuilder: (context, index) {
              final key = keysOrder[index];
              final pali = paliSegs[key] ?? "";
              final trans = translationSegs[key] ?? "";
              final comm = commentarySegs[key] ?? "";
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pali.isNotEmpty)
                    Text(
                      pali,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (trans.isNotEmpty) Html(data: trans),
                  if (comm.isNotEmpty) Html(data: comm),
                  const SizedBox(height: 12),
                ],
              );
            },
          );
          break;

        case ViewMode.sideBySide:
          body = ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: keysOrder.length,
            itemBuilder: (context, index) {
              final key = keysOrder[index];
              final pali = paliSegs[key] ?? "";
              final trans = translationSegs[key] ?? "";
              final comm = commentarySegs[key] ?? "";
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          pali,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: Html(data: trans)),
                    ],
                  ),
                  if (comm.isNotEmpty) Html(data: comm),
                  const SizedBox(height: 12),
                ],
              );
            },
          );
          break;
      }
    } else if (widget.textData!["root_text"] is Map &&
        !(widget.textData!["root_text"].containsKey("text"))) {
      final paliSegs = (widget.textData!["root_text"] as Map).map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
      final keysOrder = widget.textData!["keys_order"] is List
          ? List<String>.from(widget.textData!["keys_order"])
          : paliSegs.keys.toList();
      body = ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: keysOrder.length,
        itemBuilder: (context, index) {
          final key = keysOrder[index];
          final pali = paliSegs[key] ?? "";
          final verseNum = key.contains(":") ? key.split(":").last : key;
          return RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black),
              children: [
                WidgetSpan(
                  child: Transform.translate(
                    offset: const Offset(0, -6),
                    child: Text(
                      verseNum,
                      textScaleFactor: 0.7,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const TextSpan(text: " "),
                TextSpan(text: pali),
              ],
            ),
          );
        },
      );
    }
    // ✅ Fallback non-segmented translation_text.text (Indo, Bodhi)
    else if (widget.textData!["translation_text"] is Map &&
        widget.textData!["translation_text"].containsKey("text")) {
      final transMap = Map<String, dynamic>.from(
        widget.textData!["translation_text"],
      );
      final sutta = NonSegmentedSutta.fromJson(transMap);
      final decoded = HtmlUnescape().convert(sutta.text);

      body = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Html(data: decoded),
      );
    }
    // ✅ Fallback non-segmented root_text.text (legacy Pāli)
    else if (widget.textData!["root_text"] is Map &&
        widget.textData!["root_text"].containsKey("text")) {
      final root = Map<String, dynamic>.from(widget.textData!["root_text"]);
      final sutta = NonSegmentedSutta.fromJson(root);
      final decoded = HtmlUnescape().convert(sutta.text);

      body = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Html(data: decoded),
      );
    }
    // ✅ Fallback terakhir
    else {
      body = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(widget.textData.toString()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.uid} [${widget.lang}]"),
        actions: [
          if (isSegmented)
            PopupMenuButton<ViewMode>(
              onSelected: (mode) {
                setState(() {
                  _viewMode = mode;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: ViewMode.englishOnly,
                  child: Text("English only"),
                ),
                const PopupMenuItem(
                  value: ViewMode.lineByLine,
                  child: Text("Line by line"),
                ),
                const PopupMenuItem(
                  value: ViewMode.sideBySide,
                  child: Text("Side by side"),
                ),
              ],
            ),
        ],
      ),
      body: body,
    );
  }
}
