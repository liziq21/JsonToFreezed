// ignore_for_file: constant_identifier_names

class DefaultValue {
  bool? defaultString;
  bool? defaultInt;
  bool? defaultDouble;
  bool? defaultBool;
  bool? defaultList;
  String boolValue;

  DefaultValue({
    required this.defaultString,
    required this.defaultInt,
    required this.defaultDouble,
    required this.defaultBool,
    required this.defaultList,
    required this.boolValue,
  });
}

const String DF_STRING = "''";
const String DF_INT = '0';
const String DF_DOUBLE = '0.0';
const String DF_BOOL = 'true';
const String DF_LIST = '[]';

class JsonToFreezedGenerator {
  String? _className;
  final _allClassess = <String>[];

  List<String> get allClasses => _allClassess;

  String get className => _className ?? 'DefaultClassName';

  JsonToFreezedGenerator({String? className}) {
    _className = className;
  }

  void generateFreezedDartDataClass(
      {required dynamic decodedJson,
      required DefaultValue defaultValues}) async {
    try {
      _allClassess.clear();

      _generateDartClass(decodedJson, className, defaultValues);
      _moveClass();
    } catch (message) {
      rethrow;
    }
  }

  void _moveClass() {
    if (_allClassess.length > 1) {
      _allClassess.insert(0, _allClassess.removeLast());
    }
  }

  String _generateDartClass(
      dynamic json, String className, DefaultValue defaultValues) {
    final fields = <String>[];
    json.forEach((key, value) {
      String valueType = '';
      String? defaultValue; // Default value is null

      if (value is String) {
        valueType = 'String';
        if (defaultValues.defaultString == true) {
          defaultValue = DF_STRING;
        }
      } else if (value is int) {
        valueType = 'int';
        if (defaultValues.defaultInt == true) {
          defaultValue = DF_INT;
        }
      } else if (value is double) {
        valueType = 'double';
        if (defaultValues.defaultDouble == true) {
          defaultValue = DF_DOUBLE;
        }
      } else if (value is bool) {
        valueType = 'bool';
        if (defaultValues.defaultBool == true) {
          defaultValue = defaultValues.boolValue;
        }
      } else if (value is List) {
        if (defaultValues.defaultList == true) {
          defaultValue = DF_LIST;
        }

        if (value.isNotEmpty) {
          if (value[0] is String) {
            valueType = 'List<String>';
          } else if (value[0] is int) {
            valueType = 'List<int>';
          } else if (value[0] is double) {
            valueType = 'List<double>';
          } else if (value[0] is bool) {
            valueType = 'List<bool>';
          } else {
            String nestedClassName = _capitalize(key);
            valueType = 'List<$nestedClassName>';

            _generateDartClass(value[0], nestedClassName, defaultValues);
          }
        } else {
          valueType = 'List<dynamic>';
        }
      } else if (value is Map) {
        String nestedClassName = _capitalize(key);
        valueType = nestedClassName;
        // defaultValue = '$nestedClassName()';//MAP no default value
        _generateDartClass(value, nestedClassName, defaultValues);
      } else {
        valueType = 'dynamic';
      }

      final fieldName = _convertToValidDartIdentifier(key);

      if (defaultValue != null) {
        fields.add(
            '@Default($defaultValue) @JsonKey(name: \'$key\') final $valueType $fieldName;');
      } else {
        fields.add(
            '@JsonKey(name: \'$key\') final $valueType${valueType.toLowerCase() == 'dynamic' ? '' : '?'} $fieldName;');
      }
    });

    final classString = '''
    @freezed
    class $className with _\$$className {
      factory $className({
        ${fields.join('\n        ')}
      }) = _\$$className;
    }
    ''';

    _allClassess.add(classString);

    return classString;
  }

  String _capitalize(String input) {
    return input[0].toUpperCase() + input.substring(1);
  }

  String _convertToValidDartIdentifier(String input) {
    // Replace invalid characters with underscores
    final validChars = input.replaceAll(RegExp(r'[^a-zA-Z0-9_$]'), '_');
    // If the first character is a number, prefix with an underscore
    return RegExp(r'^[0-9]').hasMatch(validChars) ? '_$validChars' : validChars;
  }
}
