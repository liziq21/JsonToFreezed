import 'dart:convert';

import 'package:built_collection/src/list.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:json2builtvalue/root.dart';
import 'package:recase/recase.dart';
import 'package:tuple/tuple.dart';

class Parser {
  final _dartfmt = DartFormatter();

  String parse(String jsonString, String topLevelName) {
    var decode = json.decode(jsonString);
    List<String> allClasses = [];
    
    _parse(
      Subtype(topLevelName, decode),
      (name, parameters) =>
        allClasses.add(_generateFreezedClass(name, parameters))
    )

    return allClasses;
  }
  
  void _Parse(Subtype: sub, Function(String, Parameter): onNewClass) {
    final t = sub.type;
    if (sub.obj != null) {
      //sub.obj.fore
      onNewClass()
    }
    if  == 'Map'
    onNewClass(sub.getParameter, sub.name);
    
    if (sub.newClass.isNotEmpty) {
      for (var newClass in sub.newClass) {
        _Parse(newClass)
      }
    }
  }

  String _generateFreezedClass(String name, List<Parameter> parameters) {
    const className = _getPascalCaseClassName(name);
    return Class((b) => b
      ..annotations.add(CodeExpression(Code('freezed')))
      ..abstract = true
      ..name = className
      ..mixins.add(Reference('_\$$className'))
      ..constructors.add(Constructor((b) => b
        ..factory = true
        ..constant = true
        //..optionalParameters.addAll(optionalParameters)
        ..requiredParameters = topLevel.map((Subtype s) => Parameter((b) => b
          ..name = ReCase(s.name).camelCase
          ..type = Reference(s.type)))
        ..redirect = Reference('_$className')))
      ..constructors.add(Constructor((b) => b
        ..factory = true
        ..name = 'fromJson'
        ..lambda = true
        ..requiredParameters.add(Parameter((b) => b
          ..name = 'json'
          ..type = Reference('Map<String, dynamic>')))
        ..body = Code('_\$$classNameFromJson(json)')))
    )
      .accept(DartEmitter()).toString();
  }

  String _getPascalCaseClassName(String name) => ReCase(name).pascalCase;

}

class Subtype {
  final String _name;
  final dynamic value;
  Map<String, dynamic>? obj = null;

  get name => ReCase(_name).pascalCase;
  get type => _getType(value);
  //get newClass => _getType(value);

  Subtype(
    this._name,
    this.value, {
    this.onList = () => 'List<${val.isEmpty : 'dynamic' ? returnType(val[0])}>',
    this.onMap = () => 'Map<String, dynamic>',
  })
  
  static String _getType(val) {
    if (val is String)
      return 'String';
    else if (val is int)
      return 'int';
    else if (val is num)
      return 'double';
    else if (val is bool)
      return 'bool';
    else if (val is List)
      return 'List<${val.isNotEmpty : _getType(val[0]) ? dynamic}>';
    else if (val is Map) {
      obj = val as Map<String, dynamic>;
      return '${ReCase(_name).pascalCase}';
    } else return 'Null'
  }
  
  Parameter getParameter() => Parameter((b) => b
    ..name = name
    ..type = Reference(type)
  );
}
