// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: constant_identifier_names

import 'string_util.dart';

class DataMember {
  DataMember({
    required this.defaultValue,
    required this.type,
    required this.jsonkey,
  });

  final String? defaultValue;

  final String type;
  final String jsonkey;

  String get dartVariable =>
      camelCaseFirstLower(_convertToValidDartIdentifier(jsonkey));

  String get getEntityField =>
      'final $type${type.toLowerCase() == 'dynamic' ? '' : '?'} $dartVariable;';

  String get getEntityConstructorField =>
      '$type${type.toLowerCase() == 'dynamic' ? '' : '?'} $dartVariable,';

  String get getConstructorField => 'this.$dartVariable,';

  String get getFreezedField => defaultValue != null
      ? '@Default($defaultValue) @JsonKey(name: \'$jsonkey\') final $type $dartVariable;'
      : '@JsonKey(name: \'$jsonkey\') final $type${type.toLowerCase() == 'dynamic' ? '' : '?'} $dartVariable;';

  String get getJsonSerializableField => defaultValue != null
      ? '''@Default($defaultValue) 
      @JsonKey(name: '$jsonkey')
      final $type $dartVariable;'''
      : '''@JsonKey(name: '$jsonkey')
      final $type${type.toLowerCase() == 'dynamic' ? '' : '?'} $dartVariable;''';
}

String _convertToValidDartIdentifier(String input) {
  // Replace invalid characters with underscores
  final validChars = input.replaceAll(RegExp(r'[^a-zA-Z0-9_$]'), '_');
  // If the first character is a number, prefix with an underscore
  return RegExp(r'^[0-9]').hasMatch(validChars) ? '_$validChars' : validChars;
}
