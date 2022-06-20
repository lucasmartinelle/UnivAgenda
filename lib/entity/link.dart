class Link {
  final String link;

  const Link({required this.link});

  Map<String, dynamic> toMap() {
    return {
      'link': link,
    };
  }

  @override
  String toString() {
    return link;
  }
}
