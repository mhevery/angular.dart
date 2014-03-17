library angular.test.tools.transformer.expression_extractor_spec;

import 'package:angular/tools/transformer/options.dart';
import 'package:angular/tools/transformer/expression_generator.dart';
import 'package:code_transformers/resolver.dart';
import 'package:code_transformers/tests.dart' as tests;
import '../../jasmine_syntax.dart';

main() {
  describe('ExpressionGenerator', () {
    var htmlFiles = [];
    var options = new TransformOptions(
        dartEntries: ['web/main.dart'],
        htmlFiles: htmlFiles,
        sdkDirectory: dartSdkDirectory);
    var resolvers = new Resolvers(dartSdkDirectory);

    var phases = [
      [new ExpressionGenerator(options, resolvers)]
    ];

    it('should extract expressions', () {
      htmlFiles.add('web/index.html');
      return tests.applyTransformers(phases,
          inputs: {
            'a|web/main.dart': '''
library foo;
''',
            'a|web/index.html': '''
<div>{{some.getter}}</div>
'''
          },
          results: {
            'a|web/main_static_expressions.dart': '''
$header
final Map<String, Getter> getters = {
  r"some": (o) => o.some,
  r"getter": (o) => o.getter
};
final Map<String, Setter> setters = {
  r"some": (o, v) => o.some = v,
  r"getter": (o, v) => o.getter = v
};
final List<Map<String, Function>> functions = [];
'''
        }).whenComplete(() {
          htmlFiles.clear();
        });
    });
  });
}

const String header = '''
library a.web.main.generated_expressions;

import 'package:angular/angular.dart';
import 'package:angular/core/parser/dynamic_parser.dart' show ClosureMap;

Module get expressionModule => new Module()
    ..value(ClosureMap, new StaticClosureMap());

class StaticClosureMap extends ClosureMap {
  Getter lookupGetter(String name) => getters[name];
  Setter lookupSetter(String name) => setters[name];
  lookupFunction(String name, int arity)
      => (arity < functions.length) ? functions[arity][name] : null;
}
''';
