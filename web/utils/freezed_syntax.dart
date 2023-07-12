class FreezedSyntax {
  final String? className;

  FreezedSyntax({required this.className});

  final _defaultClassName = 'ClassName';
  final _freezedImport =
      "import 'package:freezed_annotation/freezed_annotation.dart';";

  String get _getPartImport => '''
part '${_getClassName.toLowerCase()}.freezed.dart';
part '${_getClassName.toLowerCase()}.g.dart';''';

  String get _getClassName => className != null && className!.isNotEmpty
      ? className!
      : _defaultClassName;

  String startClass() =>
      "$_freezedImport\n$_getPartImport\n\n@Freezed\nclass $_getClassName with _\$$_getClassName {\n";
  String startConstructor() => 'factory $_getClassName({ \n';
  String endConstructor() => "  }) = _$_getClassName;";
  String fromJsonSyntax() =>
      "\nfactory $_getClassName.fromJson(Map<String, dynamic> json) =>_\$${_getClassName}FromJson(json);";

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
