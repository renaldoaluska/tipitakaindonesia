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

    // ✅ Service sudah flatten ke "segments"
    if (json.containsKey("segments") && json["segments"] is Map) {
      segs = Map<String, String>.from(json["segments"]);
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
