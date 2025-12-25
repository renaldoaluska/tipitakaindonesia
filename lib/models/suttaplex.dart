class Translation {
  final String lang;
  final String authorUid;
  final String author;

  Translation({
    required this.lang,
    required this.authorUid,
    required this.author,
  });

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      lang: json["lang"] ?? "",
      authorUid: json["author_uid"] ?? "",
      author: json["author"] ?? "",
    );
  }
}

class SuttaplexModel {
  final String uid;
  final String translatedTitle;
  final String originalTitle;
  final String blurb;
  final List<Translation> translations;

  SuttaplexModel({
    required this.uid,
    required this.translatedTitle,
    required this.originalTitle,
    required this.blurb,
    required this.translations,
  });

  factory SuttaplexModel.fromJson(Map<String, dynamic> json) {
    final trans = (json["translations"] as List? ?? [])
        .map((t) => Translation.fromJson(t))
        .toList();

    return SuttaplexModel(
      uid: json["uid"] ?? "",
      translatedTitle: json["translated_title"] ?? "",
      originalTitle: json["original_title"] ?? "",
      blurb: json["blurb"] ?? "",
      translations: trans,
    );
  }
}
