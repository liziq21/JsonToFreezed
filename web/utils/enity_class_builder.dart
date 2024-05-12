// ignore_for_file: constant_identifier_names

import 'data_member.dart';
import 'default_value.dart';

const String DF_STRING = "''";
const String DF_INT = '0';
const String DF_DOUBLE = '0.0';
const String DF_BOOL = 'true';
const String DF_LIST = '[]';

const String kDefaultClassName = 'DefaultClassName';

class EntityModelGenerator {
  final _allClassess = <String>[];

  final String? className;

  EntityModelGenerator({this.className});

  String generateEntityModelClass({
    required dynamic decodedJson,
    required DefaultValue defaultValues,
  }) {
    // String result = '';
    try {
      _allClassess.clear();

      _generateDartClass(
          decodedJson, className ?? kDefaultClassName, defaultValues);
      _moveClass();

      return _allClassess.join('\n\n');
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
    className = '${className}Entity';
    final fields = <String>[];
    json.forEach((key, value) {
      String memberType = '';
      String? defaultValue; // Default value is null

      if (value is String) {
        memberType = 'String';
        if (defaultValues.defaultString == true) {
          defaultValue = DF_STRING;
        }
      } else if (value is int) {
        memberType = 'int';
        if (defaultValues.defaultInt == true) {
          defaultValue = DF_INT;
        }
      } else if (value is double) {
        memberType = 'double';
        if (defaultValues.defaultDouble == true) {
          defaultValue = DF_DOUBLE;
        }
      } else if (value is bool) {
        memberType = 'bool';
        if (defaultValues.defaultBool == true) {
          defaultValue = defaultValues.boolValue;
        }
      } else if (value is List) {
        if (defaultValues.defaultList == true) {
          defaultValue = DF_LIST;
        }

        if (value.isNotEmpty) {
          final child = value.first;

          switch (child.runtimeType) {
            case String:
              memberType = 'List<String>';
              break;
            case int:
              memberType = 'List<int>';
              break;
            case double:
              memberType = 'List<double>';
              break;
            case bool:
              memberType = 'List<bool>';
              break;

            default:
              String nestedClassName = _capitalize(key);
              memberType = 'List<$nestedClassName>';

              _generateDartClass(child, nestedClassName, defaultValues);
              break;
          }
        } else {
          memberType = 'List<dynamic>';
        }
      } else if (value is Map) {
        String nestedClassName = _capitalize(key);
        memberType = '${nestedClassName}Entity';
        // defaultValue = '$nestedClassName()';//MAP no default value
        _generateDartClass(value, nestedClassName, defaultValues);
      } else {
        memberType = 'dynamic';
      }

      final member = DataMember(
        defaultValue: defaultValue,
        type: memberType,
        jsonkey: key,
      );

      fields.add(member.getEntityConstructorField);
    });

    final classString = '''
    @freezed
    class $className with _\$$className {
      factory $className({
        ${fields.join('\n        ')}
      }) = _$className;
    }
    ''';

    _allClassess.add(classString);

    return classString;
  }
}

String _capitalize(String input) {
  return input[0].toUpperCase() + input.substring(1);
}
