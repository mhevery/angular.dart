library angular.test.tools.transformer.metadata_generator_spec;

import 'dart:async';

import 'package:angular/tools/transformer/options.dart';
import 'package:angular/tools/transformer/static_angular_generator.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:code_transformers/tests.dart' as tests;

import '../../jasmine_syntax.dart';

main() {
  describe('StaticAngularGenerator', () {
    var options = new TransformOptions(
        dartEntries: ['web/main.dart'],
        sdkDirectory: dartSdkDirectory);

    var resolvers = new Resolvers(dartSdkDirectory);

    var phases = [
      [new StaticAngularGenerator(options, resolvers)]
    ];

    it('should modify NgDynamicApp', () {
      return tests.applyTransformers(phases,
          inputs: {
            'angular|lib/angular_dynamic.dart': libAngularDynamic,
            'di|lib/di.dart': libDI,
            'a|web/main.dart': '''
import 'package:angular/angular_dynamic.dart';
import 'package:di/di.dart' show Module;

class MyModule extends Module {}

main() {
  var app = new NgDynamicApp()
    .addModule(new MyModule())
    .run();
}
'''
          },
          results: {
            'a|web/main.dart': '''
import 'package:angular/angular_static.dart';
import 'package:di/di.dart' show Module;
import 'main_static_expressions.dart' as generated_static_expressions;
import 'main_static_metadata.dart' as generated_static_metadata;
import 'main_static_injector.dart' as generated_static_injector;

class MyModule extends Module {}

main() {
  var app = new NgStaticApp(generated_static_injector.factories, generated_static_metadata.typeAnnotations, generated_static_expressions.getters, new generated_static_expressions.StaticClosureMap())
    .addModule(new MyModule())
    .run();
}
'''
          });
    });

    it('handles prefixed app imports', () {
      return tests.applyTransformers(phases,
          inputs: {
            'angular|lib/angular_dynamic.dart': libAngularDynamic,
            'di|lib/di.dart': libDI,
            'a|web/main.dart': '''
import 'package:angular/angular_dynamic.dart' as ng;
import 'package:di/di.dart' show Module;

class MyModule extends Module {}

main() {
  var app = new ng.NgDynamicApp()
    .addModule(new MyModule())
    .run();
}
'''
          },
          results: {
            'a|web/main.dart': '''
import 'package:angular/angular_static.dart' as ng;
import 'package:di/di.dart' show Module;
import 'main_static_expressions.dart' as generated_static_expressions;
import 'main_static_metadata.dart' as generated_static_metadata;
import 'main_static_injector.dart' as generated_static_injector;

class MyModule extends Module {}

main() {
  var app = new ng.NgStaticApp(generated_static_injector.factories, generated_static_metadata.typeAnnotations, generated_static_expressions.getters, new generated_static_expressions.StaticClosureMap())
    .addModule(new MyModule())
    .run();
}
'''
          });
    });
  });
}



const String libAngularDynamic = '''
library angular.dynamic

class NgDynamicApp {};
''';

const String libDI = '''
class Module {}
''';
