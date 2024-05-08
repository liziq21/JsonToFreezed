import 'dart:convert';
import 'dart:html';

import 'utils/default_value.dart';
import 'utils/enity_class_builder.dart';
import 'utils/freezed_class_builder.dart';
import 'utils/json_serializable_class_builder.dart';
import 'utils/string_util.dart';

Future<void> main() async {
  ///TextArea
  TextAreaElement? inputJson =
      document.getElementById('input__json') as TextAreaElement?;
  InputElement inputClassName =
      document.getElementById('input__classname') as InputElement;

  ButtonElement? btnGenerate =
      document.getElementById("btn__generate") as ButtonElement?;

  ButtonElement? btnCopy =
      document.getElementById("btn__copy") as ButtonElement?;

  ButtonElement? btnClear =
      document.getElementById("btn__clear") as ButtonElement?;

  CheckboxInputElement stringBTN =
      document.getElementById("string") as CheckboxInputElement;
  CheckboxInputElement intBTN =
      document.getElementById("int") as CheckboxInputElement;
  CheckboxInputElement doubleBTN =
      document.getElementById("double") as CheckboxInputElement;
  CheckboxInputElement booleanBTN =
      document.getElementById("boolean") as CheckboxInputElement;
  CheckboxInputElement listBTN =
      document.getElementById("list") as CheckboxInputElement;

  SelectElement boolOptionValue =
      document.getElementById("option__box-boolen-value") as SelectElement;

  // SelectElement choice =
  //     document.getElementById('boolean-choice') as SelectElement;

  // bool enabledDefault() =>
  //     stringBTN.checked! ||
  //     intBTN.checked! ||
  //     doubleBTN.checked! ||
  //     booleanBTN.checked!;

  // Element? copybtn = document.getElementById("copy");

  void generate() async {
    final className =
        inputClassName.value != null && inputClassName.value!.isNotEmpty
            ? camelCase(inputClassName.value!)
            : null;

    try {
      //
      final jsonToFreezedGenerator =
          JsonToFreezedGenerator(className: className);
      final jsonSerializableGenerator =
          JsonSerializableGenerator(className: className);
      final entityModelGenerator = EntityModelGenerator(className: className);

      final jsonInput = inputJson?.value;

      final defaultValues = DefaultValue(
          defaultString: stringBTN.checked,
          defaultBool: booleanBTN.checked,
          defaultDouble: doubleBTN.checked,
          defaultInt: intBTN.checked,
          defaultList: listBTN.checked,
          boolValue: boolOptionValue.value ?? 'false');

      if (jsonInput != null && jsonInput != '') {
        final dynamic decodedJson = await jsonDecode(jsonInput);
        jsonToFreezedGenerator.generateFreezedDartDataClass(
            decodedJson: decodedJson, defaultValues: defaultValues);

        final serialized =
            jsonSerializableGenerator.generateJsonSerializableDataClass(
                decodedJson: decodedJson, defaultValues: defaultValues);

        final entity = entityModelGenerator.generateEntityModelClass(
            decodedJson: decodedJson, defaultValues: defaultValues);

        ///output
        document.querySelector('#output-freezed')?.text =
            jsonToFreezedGenerator.allClasses.join('\n\n');

        document.querySelector('#output-entity')?.text = entity;
        document.querySelector('#output-model')?.text = serialized;
      } else {
        window.alert('Please input Json in the box left to Generate.');
      }
    } catch (e) {
      // print(e);
      if (e is FormatException) {
        window
            .alert('Json data are not correct. try recheck again ${e.message}');
      } else {
        window.alert('Something went wrong. try refresh the page again');
      }
    }
  }

  btnGenerate?.addEventListener("click", (_) async {
    print('Clicked');

    generate();
  });

  btnCopy?.addEventListener("click", (_) async {
    final outputTexts = document.querySelector('#output')?.text ?? '';

    if (outputTexts.trim().isNotEmpty) {
      window.navigator.clipboard
          ?.writeText(document.querySelector('#output')?.text ?? '');
    } else {
      window.alert('No outputs found!');
    }
  });

  btnClear?.addEventListener("click", (_) async {
    print('Clear');
    inputJson?.value = '';
    inputClassName.value = '';
    document.querySelector('#output')?.text = '';
    //TODO: Clear
  });
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
