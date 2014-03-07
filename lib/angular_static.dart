library angular.static;

import 'package:di/static_injector.dart';
import 'package:angular/angular.dart';
import 'package:angular/core/registry_static.dart';
import 'package:angular/change_detection/change_detection.dart';
import 'package:angular/change_detection/dirty_checking_change_detector_static.dart';

class _NgStaticApp extends NgApp {
  final Map<Type, TypeFactory> typeFactories;

  _NgStaticApp(Map<Type, TypeFactory> this.typeFactories,
               Map<Type, Object> metadata,
               Map<String, FieldGetter> fieldGetters,
               Map<String, FieldSetter> fieldSetters) {
    ngModule
      ..value(MetadataExtractor, new StaticMetadataExtractor(metadata))
      ..value(FieldGetterFactory, new StaticFieldGetterFactory(fieldGetters))
      ..value(ClosureMap, new StaticClosureMap(fieldGetters, fieldSetters));
  }

  Injector createInjector()
      => new StaticInjector(modules: modules, typeFactories: typeFactories);
}

class StaticClosureMap extends ClosureMap {
  final Map<String, Getter> getters;
  final Map<String, Setter> setters;

  StaticClosureMap(this.getters, this.setters);

  Getter lookupGetter(String name) {
    Getter getter = getters[name];
    if (getter == null) throw "No getter for '$name'.";
    return getter;
  }

  Setter lookupSetter(String name) {
    Setter setter = setters[name];
    if (setter == null) throw "No setter for '$name'.";
    return setter;
  }

  Function lookupFunction(String name, int arity) {
    var fn = lookupGetter(name);
    return (o, [a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13]) {
      var args = [a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13];
      return Function.apply(fn(o), args.getRange(0, arity).toList());
    };
  }
}

NgApp ngStaticApp(
    Map<Type, TypeFactory> typeFactories,
    Map<Type, Object> metadata,
    Map<String, FieldGetter> fieldGetters,
    Map<String, FieldSetter> fieldSetters) {
  return new _NgStaticApp(typeFactories, metadata, fieldGetters, fieldSetters);
}
