library angular.core.parser_dynamic;

import 'package:angular/core/parser/parser.dart';
import 'dart:mirrors';

class DynamicClosureMap implements ClosureMap {
  Getter lookupGetter(String name) {
    var symbol = new Symbol(name);
    return (o) {
      if (o is Map) {
        return o[name];
      } else {
        return reflect(o).getField(symbol).reflectee;
      }
    };
  }

  Setter lookupSetter(String name) {
    var symbol = new Symbol(name);
    return (o, value) {
      if (o is Map) {
        return o[name] = value;
      } else {
        reflect(o).setField(symbol, value);
        return value;
      }
    };
  }

  MethodClosure lookupFunction(String name, int arity) {
    var symbol = new Symbol(name);
    return (o, args) {
      if (o is Map) {
        var fn = o[name];
        if (fn is Function) {
          return Function.apply(fn, args);
        } else {
          throw "Property '$name' is not of type function.";
        }
      } else {
        try {
          return reflect(o).invoke(symbol, args).reflectee;
        } on NoSuchMethodError catch (e) {
          throw 'Undefined function $name';
        }
      }
    };
  }
}
