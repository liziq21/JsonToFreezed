class Root {
  final String title;

  final Map<String, Subtype> jsonTree;

  Root(this.title, this.jsonTree);

  @override
  String toString() {
    return 'Root{title: $title, jsonTree: $jsonTree}';
  }
}

