import 'dart:html';
import 'dart:convert';

import 'utils/freezed_syntax.dart';
import 'utils/string_util.dart';

Future<void> main() async {
  ///TextArea
  TextAreaElement a = document.getElementById('mytextfield') as TextAreaElement;
  InputElement inputClassName =
      document.getElementById('class-name') as InputElement;

  Element? btn = document.getElementById("btn");
  CheckboxInputElement stringBTN =
      document.getElementById("String") as CheckboxInputElement;
  CheckboxInputElement intBTN =
      document.getElementById("int") as CheckboxInputElement;
  CheckboxInputElement doubleBTN =
      document.getElementById("double") as CheckboxInputElement;
  CheckboxInputElement booleanBTN =
      document.getElementById("boolean") as CheckboxInputElement;

  SelectElement choice =
      document.getElementById('boolean-choice') as SelectElement;

  bool enabledDefault() =>
      stringBTN.checked! ||
      intBTN.checked! ||
      doubleBTN.checked! ||
      booleanBTN.checked!;

  // Element? copybtn = document.getElementById("copy");

  bool start() {
    String className =
        inputClassName.value != null && inputClassName.value!.isNotEmpty
            ? camelCase(inputClassName.value ?? '')
            : '';
    final classSyntax = FreezedSyntax(className: className);
    String result = classSyntax.startClass();
    String constructor = classSyntax.startConstructor();
    String endConstructor =
        "  }) = _${className != '' ? className : CLASS_NAME};";

    try {
      //
      Map<String, dynamic> decoded = jsonDecode(a.value ?? '');
      decoded.entries.map((e) {
        constructor =
            '$constructor ${enabledDefault() ? freezedSyntaxWithDefault(
                e.key,
                e.value,
                enableStr: stringBTN.checked,
                enableInt: intBTN.checked,
                enableDouble: doubleBTN.checked,
                enableBoolean: booleanBTN.checked,
                boolValue: choice.selectedIndex == 0,
              ) : freezedSyntax(e.key, e.value)}';
      }).toList();
      constructor = constructor + endConstructor;
      result = '$result$constructor ${classSyntax.fromJsonSyntax()} \n}';

      ///output
      document.querySelector('#output')?.text = result;
    } catch (e) {
      print(e);
      if (e is FormatException) {
        window
            .alert('Json data are not correct. try recheck again ${e.message}');
      } else {
        window.alert('Something went wrong. try refresh the page again');
      }

      return false;
    }
    return true;
  }

  btn?.addEventListener("click", (_) async {
    start();
  });

  // copybtn?.addEventListener("click", (_) async {
  //   print('VALUE : $aa');
  //   // aa?.clipboard?.writeText(document.querySelector('#output')?.text ?? '');
  // });
} //main

// ignore_for_file: constant_identifier_names

/*
@freezed
class ClassName with _$ClassName {
  factory ClassName() = _ClassName;

  factory ClassName.fromJson(Map<String, dynamic> json) =>
      _$ClassNameFromJson(json);
  Map<String, dynamic> toJson() => _$ClassNameToJson(this);
}
*/

class EnableDefault {
  bool? enableString;
  bool? enableInt;
  bool? enableDouble;
  bool? enableBoolean;
}

const CLASS_NAME = 'ClassName';

String constr(String key) => 'this.${camelCaseFirstLower(key)},';

String freezedSyntax(String key, dynamic value) =>
    '   ${jsonKey(key)} final ${getType(value)}? ${camelCaseFirstLower(key)},\n';

String freezedSyntaxWithDefault(String key, dynamic value,
        {bool? enableStr = false,
        bool? enableInt = false,
        bool? enableDouble = false,
        bool? enableBoolean = false,
        bool? boolValue = false}) =>
    '   ${jsonKey(key)} ${_getDefault(
      enableStr: enableStr,
      enableInt: enableInt,
      enableDouble: enableDouble,
      enableBoolean: enableBoolean,
      boolValue: boolValue,
      type: getType(value),
    )}final ${getType(value)}? ${camelCaseFirstLower(key)},\n';

String getType(dynamic data) {
  if (data is List) {
    return 'List<dynamic>';
  } else if (data is Map) {
    return 'Map<String,dynamic>';
  } else {
    return data.runtimeType.toString();
  }
}

String jsonKey(String key) => "@JsonKey(name:\"$key\")";
String defaultKey(key) => "@Default($key) ";

const num _defaultNum = 0;

String _getDefault(
    {bool? enableStr = false,
    bool? enableInt = false,
    bool? enableDouble = false,
    bool? enableBoolean = false,
    bool? boolValue = false,
    required String type}) {
  String value = '';

  if (type == 'String' && enableStr!) {
    value = defaultKey("\"\"");
  }
  if (type == 'int' && enableInt!) {
    value = defaultKey(_defaultNum);
  }
  if (type == 'double' && enableDouble!) {
    value = defaultKey(_defaultNum);
  }
  if (type == 'bool' && enableBoolean!) {
    value = defaultKey(boolValue);
  }
  return value;
}
