library angular.static;

// REMOVE once all mirrors dependencies are gone.
@MirrorsUsed(override: const ['*'], targets: const [])
import 'dart:mirrors';

import 'package:di/static_injector.dart';
import 'package:angular/angular.dart';
import 'package:angular/core/registry_static.dart';
import 'package:angular/change_detection/change_detection.dart';
import 'package:angular/change_detection/dirty_checking_change_detector_static.dart';

class NgStaticApp extends NgApp {
  final Map<Type, TypeFactory> typeFactories;

  NgStaticApp(Map<Type, TypeFactory> this.typeFactories,
              Map<Type, Object> metadata,
              Map<String, FieldGetter> fieldGetters,
              ClosureMap closureMap) {
    ngModule
      ..value(MetadataExtractor, new StaticMetadataExtractor(metadata))
      ..value(FieldGetterFactory, new StaticFieldGetterFactory(fieldGetters))
      ..value(ClosureMap, closureMap);
  }

  Injector createInjector()
      => new StaticInjector(modules: modules, typeFactories: typeFactories);
}
