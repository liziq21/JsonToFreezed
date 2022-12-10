class FreezedSyntax {
  final String? className;

  FreezedSyntax({required this.className});

  String defaultClassName = 'ClassName';

  String get getClassName => className != null && className!.isNotEmpty
      ? className!
      : defaultClassName;

  String startClass() =>
      "@Freezed\nclass $getClassName with _\$$getClassName {\n";
  String startConstructor() => 'factory $getClassName({ \n';
  String endConstructor() => "  }) = _$getClassName;";
  String fromJsonSyntax() =>
      "\nfactory $getClassName.fromJson(Map<String, dynamic> json) =>_\$${getClassName}FromJson(json);";

  String buildClass(
      {required Map<String, dynamic> mapData, required bool enableDefault}) {
    String result = startClass();
    String constructor = startConstructor();

    mapData.entries.map((e) {
      constructor = constructor + e.value;
    }).toList();
    constructor = constructor + endConstructor();

    result = result + constructor + fromJsonSyntax();

    return result;
  }
}
