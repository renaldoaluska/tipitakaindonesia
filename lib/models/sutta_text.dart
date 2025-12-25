class SegmentedSutta {
  final String uid;
  final String lang;
  final Map<String, String> segments;

  SegmentedSutta({
    required this.uid,
    required this.lang,
    required this.segments,
  });

  factory SegmentedSutta.fromJson(Map<String, dynamic> json) {
    Map<String, String> segs = {};

    // ✅ Case 1: segments di root
    if (json.containsKey("segments") && json["segments"] is Map) {
      segs = Map<String, String>.from(json["segments"]);
    }
    // ✅ Case 2: segments nested di translation
    else if (json.containsKey("translation") &&
        json["translation"] is Map &&
        json["translation"].containsKey("segments")) {
      segs = Map<String, String>.from(json["translation"]["segments"]);
    }
    // ✅ Case 3: segments nested di root_text
    else if (json.containsKey("root_text") &&
        json["root_text"] is Map &&
        json["root_text"].containsKey("segments")) {
      segs = Map<String, String>.from(json["root_text"]["segments"]);
    }

    return SegmentedSutta(
      uid: json["uid"] ?? "",
      lang: json["lang"] ?? "",
      segments: segs,
    );
  }

  /// Gabung semua segmen jadi teks rapi
  String get fullText => segments.values.join("\n\n");
}

class NonSegmentedSutta {
  final String uid;
  final String lang;
  final String text;

  NonSegmentedSutta({
    required this.uid,
    required this.lang,
    required this.text,
  });

  factory NonSegmentedSutta.fromJson(Map<String, dynamic> json) {
    return NonSegmentedSutta(
      uid: json["uid"] ?? "",
      lang: json["lang"] ?? "",
      text: json["text"] ?? "",
    );
  }
}
