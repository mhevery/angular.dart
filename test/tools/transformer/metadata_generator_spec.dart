library angular.test.tools.transformer.metadata_generator_spec;

import 'dart:async';

import 'package:angular/tools/transformer/options.dart';
import 'package:angular/tools/transformer/metadata_generator.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:code_transformers/tests.dart' as tests;

import '../../jasmine_syntax.dart';

main() {
  describe('MetadataGenerator', () {
    var options = new TransformOptions(
        dartEntries: ['web/main.dart'],
        sdkDirectory: dartSdkDirectory);

    var resolvers = new Resolvers(dartSdkDirectory);

    var phases = [
      [new MetadataGenerator(options, resolvers)]
    ];

    it('should extract member metadata', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @NgDirective(selector: r'[*=/{{.*}}/]')
                @proxy
                class Engine {
                  @NgOneWay('another-expression')
                  String anotherExpression;

                  @NgCallback('callback')
                  set callback(Function) {}

                  set twoWayStuff(String abc) {}
                  @NgTwoWay('two-way-stuff')
                  String get twoWayStuff => null;
                }
                '''
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Engine': [
              'const import_1.NgDirective(selector: \'[*=/{{.*}}/]\', map: const {'
                '\'another-expression\': \'=>anotherExpression\', '
                '\'callback\': \'&callback\', '
                '\'two-way-stuff\': \'<=>twoWayStuff\''
                '})',
              'proxy',
            ]
          });
    });

    it('should warn on multiple annotations', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                class Engine {
                  @NgCallback('callback')
                  @NgOneWay('another-expression')
                  set callback(Function) {}
                }
                '''
          },
          messages: ['warning: callback can only have one annotation. '
              '(main.dart 3 18)']);
    });

    it('should warn on duplicated annotations', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @NgDirective(map: {'another-expression': '=>anotherExpression'})
                class Engine {
                  @NgOneWay('another-expression')
                  set anotherExpression(Function) {}
                }
                '''
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Engine': [
              'const import_1.NgDirective(map: const {'
                '\'another-expression\': \'=>anotherExpression\'})',
            ]
          },
          messages: ['warning: Directive @NgOneWay(\'another-expression\') '
              'already contains an entry for \'another-expression\' '
              '(main.dart 2 16)'
          ]);
    });

    it('should merge member annotations', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @NgDirective(map: {'another-expression': '=>anotherExpression'})
                class Engine {
                  set anotherExpression(Function) {}

                  set twoWayStuff(String abc) {}
                  @NgTwoWay('two-way-stuff')
                  String get twoWayStuff => null;
                }
                '''
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Engine': [
              'const import_1.NgDirective(map: const {'
                '\'another-expression\': \'=>anotherExpression\', '
                '\'two-way-stuff\': \'<=>twoWayStuff\'})',
            ]
          });
    });

    it('should warn on multiple annotations (across getter/setter)', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                class Engine {
                  @NgCallback('callback')
                  set callback(Function) {}

                  @NgOneWay('another-expression')
                  get callback() {}
                }
                '''
          },
          messages: ['warning: callback can only have one annotation. '
              '(main.dart 3 18)']);
    });

    it('should extract map arguments', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @NgDirective(map: const {'ng-value': '&ngValue', 'key': 'value'})
                class Engine {}
                '''
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Engine': [
              'const import_1.NgDirective(map: const {\'ng-value\': \'&ngValue\', \'key\': \'value\'})',
            ]
          });
    });

    it('should extract list arguments', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @NgDirective(publishTypes: const [TextChangeListener])
                class Engine {}
                '''
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Engine': [
              'const import_1.NgDirective(publishTypes: const [import_1.TextChangeListener,])',
            ]
          });
    });

    it('should extract primitive literals', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @NgOneWay(true)
                @NgOneWay(1.0)
                @NgOneWay(1)
                @NgOneWay(null)
                class Engine {}
                '''
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Engine': [
              'const import_1.NgOneWay(true)',
              'const import_1.NgOneWay(1.0)',
              'const import_1.NgOneWay(1)',
              'const import_1.NgOneWay(null)',
            ]
          });
    });

    it('should skip and warn on unserializable annotations', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @Foo
                class Engine {}

                @NgDirective(publishTypes: const [Foo])
                class Car {}
                '''
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Engine': [
              'null',
            ],
            'import_0.Car': [
              'null',
            ]
          },
          messages: [
            'warning: Unable to serialize annotation @Foo. (main.dart 2 16)',
            'warning: Unable to serialize annotation '
                '@NgDirective(publishTypes: const [Foo]). (main.dart 5 16)',
          ]);
    });

    it('should extract types across libs', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';
                import 'package:a/b.dart';

                @NgDirective(publishTypes: const [Car])
                class Engine {}
                ''',
            'a|lib/b.dart': '''
                class Car {}
                ''',
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
            'import \'package:a/b.dart\' as import_2;',
          ],
          classes: {
            'import_0.Engine': [
              'const import_1.NgDirective(publishTypes: const [import_2.Car,])',
            ]
          });
    });

    it('should not gather non-member annotations', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                class Engine {
                  Engine() {
                    @NgDirective()
                    print('something');
                  }
                }
                ''',
          });
    });

    it('properly escapes strings', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': r'''
                import 'package:angular/angular.dart';

                @NgOneWay('foo\' \\')
                class Engine {
                }
                ''',
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Engine': [
              r'''const import_1.NgOneWay('foo\' \\')''',
            ]
          });
    });

    it('should reference static and global properties', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @NgDirective(visibility: NgDirective.CHILDREN_VISIBILITY)
                @NgDirective(visibility: CONST_VALUE)
                class Engine {}

                const int CONST_VALUE = 2;
                ''',
          },
          imports: [
            'import \'main.dart\' as import_0;',
            'import \'package:angular/angular.dart\' as import_1;',
          ],
          classes: {
            'import_0.Engine': [
              '''const import_1.NgDirective(visibility: import_1.NgDirective.CHILDREN_VISIBILITY)''',
              '''const import_1.NgDirective(visibility: import_0.CONST_VALUE)''',
            ]
          });
    });

    it('should not extract private annotations', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @_Foo()
                @_foo
                class Engine {
                }

                class _Foo {
                  const _Foo();
                }
                const _Foo _foo = const _Foo();
                ''',
          },
          messages: [
            'warning: Annotation @_Foo() is not public. (main.dart 2 16)',
            'warning: Annotation @_foo is not public. (main.dart 2 16)',
          ]);
    });

    it('supports named constructors', () {
      return generates(phases,
          inputs: {
            'angular|lib/angular.dart': libAngular,
            'a|web/main.dart': '''
                import 'package:angular/angular.dart';

                @Foo.bar()
                @Foo._private()
                class Engine {
                }

                class Foo {
                  const Foo.bar();
                  const Foo._private();
                }
                ''',
          },
          imports: [
            'import \'main.dart\' as import_0;',
          ],
          classes: {
            'import_0.Engine': [
              '''const import_0.Foo.bar()''',
            ]
          },
          messages: [
            'warning: Annotation @Foo._private() is not public. '
                '(main.dart 2 16)',
          ]);
    });
  });
}

Future generates(List<List<Transformer>> phases,
    {Map<String, String> inputs, Iterable<String> imports: const [],
    Map classes: const {},
    Iterable<String> messages: const []}) {

  var buffer = new StringBuffer();
  buffer.write('$header\n');
  for (var i in imports) {
    buffer.write('$i\n');
  }
  buffer.write('$boilerPlate\n');
  for (var className in classes.keys) {
    buffer.write('  $className: const [\n');
    for (var annotation in classes[className]) {
      buffer.write('    $annotation,\n');
    }
    buffer.write('  ],\n');
  }

  buffer.write('$footer\n');

  return tests.applyTransformers(phases,
      inputs: inputs,
      results: {
        'a|web/main_static_metadata.dart': buffer.toString()
      },
      messages: messages);
}

const String header = '''
library a.web.main.generated_metadata;

import 'package:angular/angular.dart' show MetadataExtractor;
import 'package:di/di.dart' show Module;
''';

const String boilerPlate = '''
Module get metadataModule => new Module()
    ..value(MetadataExtractor, new _StaticMetadataExtractor());

class _StaticMetadataExtractor implements MetadataExtractor {
  Iterable call(Type type) {
    var annotations = typeAnnotations[type];
    if (annotations != null) {
      return annotations;
    }
    return [];
  }
}

final Map<Type, Object> typeAnnotations = {''';

const String footer = '''
};''';


const String libAngular = '''
library angular.core;

class NgAnnotation {
  NgAnnotation({map: const {}});
}

class NgDirective extends NgAnnotation {
  const NgDirective({selector, publishTypes, map, visibility}) : super(map: map);

  static const int CHILDREN_VISIBILITY = 1;
}

class NgOneWay {
  const NgOneWay(arg);
}

class NgTwoWay {
  const NgTwoWay(arg);
}

class NgCallback {
  const NgCallback(arg);
}

class NgAttr {
  const NgAttr();
}
class NgOneWayOneTime {
  const NgOneWayOneTime(arg);
}

class TextChangeListener {}
''';
