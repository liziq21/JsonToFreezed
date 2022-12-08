import 'dart:html';
import 'dart:convert';

Future<void> main() async {
  TextAreaElement a = document.getElementById('mytextfield') as TextAreaElement;
  InputElement classN = document.getElementById('class-name') as InputElement;

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
    String className = classN.value != null && classN.value!.isNotEmpty
        ? camelCase(classN.value ?? '')
        : '';
    print('class Name = $className aa');
    try {
      String result =
          "class ${className != '' ? className : CLASS_NAME} with _\$${className != '' ? className : CLASS_NAME} {\n";
      String constructor =
          'factory ${className != '' ? className : CLASS_NAME}({ \n';
      String endConstructor =
          "  }) = _${className != '' ? className : CLASS_NAME};";
      //
      Map<String, dynamic> decoded = JsonDecoder().convert(a.value ?? '');
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
      result =
          '$result$constructor ${fromJsonSyntax(className: className)} \n}';
      document.querySelector('#output')?.text = result;
      print(result);
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
}

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
const CLASS_NAME = 'ClassName';

String fromJsonSyntax({String? className}) =>
    "\nfactory ${className != null && className.isNotEmpty ? className : CLASS_NAME}.fromJson(Map<String, dynamic> json) =>_\$${className != null && className.isNotEmpty ? className : CLASS_NAME}FromJson(json);";

// String syntax(String key, dynamic value) =>
//     'final ${getType(value)}? ${camelCaseFirstLower(key)};\n';

String constr(String key) => 'this.${camelCaseFirstLower(key)},';

String freezedSyntax(String key, dynamic value) =>
    '   ${jsonKey(key)} final ${getType(value)}? ${camelCaseFirstLower(key)},\n';

String freezedSyntaxWithDefault(String key, dynamic value,
        {bool? enableStr = false,
        bool? enableInt = false,
        bool? enableDouble = false,
        bool? enableBoolean = false,
        bool? boolValue = false}) =>
    '   ${jsonKey(key)} ${getDefault(
      enableStr: enableStr,
      enableInt: enableInt,
      enableDouble: enableDouble,
      enableBoolean: enableBoolean,
      boolValue: boolValue,
      type: getType(value),
    )}final ${getType(value)}? ${camelCaseFirstLower(key)},\n';

String getType(dynamic data) {
  try {
    data.entries; //if here no error it is MAP
    return "Map<String,dynamic>";
  } catch (e) {
    print(data.runtimeType.toString());
    return '${data.runtimeType}';
  }
}

String camelCase(String text) {
  String capitalize(Match m) =>
      m[0]!.substring(0, 1).toUpperCase() + m[0]!.substring(1);
  String skip(String s) => "";
  return text.splitMapJoin(RegExp(r'[a-zA-Z0-9]+'),
      onMatch: capitalize, onNonMatch: skip);
}

String camelCaseFirstLower(String text) {
  final camelCaseText = camelCase(text);
  final firstChar = camelCaseText.substring(0, 1).toLowerCase();
  final rest = camelCaseText.substring(1);
  return '$firstChar$rest';
}

String jsonKey(String key) => "@JsonKey(name: \"$key\")";
String defaultKey(key) => "@Default($key) ";

const String strV = '';
const num numV = 0;
const bool boolV = false;

String getDefault(
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
    value = defaultKey(numV);
  }
  if (type == 'double' && enableDouble!) {
    value = defaultKey(numV);
  }
  if (type == 'bool' && enableBoolean!) {
    value = defaultKey(boolValue);
  }
  return value;
}
