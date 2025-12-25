class MenuItem {
  final String uid;
  String originalTitle;
  String translatedTitle;
  String acronym;
  String blurb;
  String nodeType;
  String childRange;

  MenuItem({
    required this.uid,
    required this.originalTitle,
    required this.translatedTitle,
    required this.acronym,
    required this.blurb,
    required this.nodeType,
    required this.childRange,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      uid: json["uid"] ?? "",
      originalTitle: json["root_name"] ?? "",
      translatedTitle: json["translated_name"] ?? "",
      acronym: json["acronym"] ?? "",
      blurb: json["blurb"] ?? "",
      nodeType: json["node_type"] ?? "",
      childRange: json["child_range"] ?? "",
    );
  }

  void attachSuttaplex(Map<String, dynamic> json) {
    translatedTitle = json["translated_title"] ?? translatedTitle;
    originalTitle = json["root_title"] ?? originalTitle;
    blurb = json["blurb"] ?? blurb;
    acronym = json["acronym"] ?? acronym;
  }
}
