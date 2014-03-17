library angular.tools.transformer.expression_generator;

import 'dart:async';
import 'dart:math' as math;
import 'package:analyzer/src/generated/element.dart';
import 'package:angular/core/parser/parser.dart';
import 'package:angular/tools/html_extractor.dart';
import 'package:angular/tools/parser_getter_setter/generator.dart';
import 'package:angular/tools/source_crawler.dart';
import 'package:angular/tools/source_metadata_extractor.dart';
import 'package:angular/tools/transformer/options.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:di/di.dart';
import 'package:di/dynamic_injector.dart';
import 'package:path/path.dart' as path;

/**
 * Transformer which gathers all expressions from the HTML source files and
 * Dart source files of an application and packages them for static evaluation.
 *
 * This will also modify the main Dart source file to import the generated
 * expressions and modify all references to NG_EXPRESSION_MODULE to refer to
 * the generated expressions.
 */
class ExpressionGenerator extends Transformer with ResolverTransformer {
  final TransformOptions options;

  ExpressionGenerator(this.options, Resolvers resolvers) {
    this.resolvers = resolvers;
  }

  Future<bool> isPrimary(Asset input) => options.isDartEntry(input.id);

  Future applyResolver(Transform transform, Resolver resolver) {
    var asset = transform.primaryInput;
    var outputBuffer = new StringBuffer();

    _writeStaticExpressionHeader(asset.id, outputBuffer);

    var sourceMetadataExtractor = new SourceMetadataExtractor();
    var directives =
        sourceMetadataExtractor.gatherDirectiveInfo(null,
        new _LibrarySourceCrawler(resolver.libraries));

    var htmlExtractor = new HtmlExpressionExtractor(directives);
    return _getHtmlSources(transform)
        .forEach(htmlExtractor.parseHtml)
        .then((_) {
      var module = new Module()
        ..type(Parser, implementedBy: DynamicParser)
        ..type(ParserBackend, implementedBy: DartGetterSetterGen);
      var injector =
          new DynamicInjector(modules: [module], allowImplicitInjection: true);

      injector.get(_ParserGetterSetter).generateParser(
          htmlExtractor.expressions.toList(), outputBuffer);

      var id = transform.primaryInput.id;
      var outputFilename = '${path.url.basenameWithoutExtension(id.path)}'
          '_static_expressions.dart';
      var outputPath = path.url.join(path.url.dirname(id.path), outputFilename);
      var outputId = new AssetId(id.package, outputPath);
      transform.addOutput(
            new Asset.fromString(outputId, outputBuffer.toString()));

      transform.addOutput(asset);
    });
  }

  /**
   * Gets a stream consisting of the contents of all HTML source files to be
   * scoured for expressions.
   */
  Stream<String> _getHtmlSources(Transform transform) {
    var controller = new StreamController<String>();
    if (options.htmlFiles == null) {
      controller.close();
      return controller.stream;
    }
    Future.wait(options.htmlFiles.map((path) {
      var htmlId = new AssetId(transform.primaryInput.id.package, path);
      return transform.readInputAsString(htmlId);
    }).map((future) {
      return future.then(controller.add).catchError(controller.addError);
    })).then((_) {
      controller.close();
    });
    return controller.stream;
  }
}

void _writeStaticExpressionHeader(AssetId id, StringSink sink) {
  var libPath = path.withoutExtension(id.path).replaceAll('/', '.');
  sink.write('''
library ${id.package}.$libPath.generated_expressions;

import 'package:angular/angular.dart';
import 'package:angular/core/parser/dynamic_parser.dart' show ClosureMap;

Module get expressionModule => new Module()
    ..value(ClosureMap, new StaticClosureMap());

''');
}

class _LibrarySourceCrawler implements SourceCrawler {
  final List<LibraryElement> libraries;
  _LibrarySourceCrawler(this.libraries);

  void crawl(String entryPoint, CompilationUnitVisitor visitor) {
    libraries.expand((lib) => lib.units)
        .map((compilationUnitElement) => compilationUnitElement.node)
        .forEach(visitor);
  }
}

class _ParserGetterSetter {
  final Parser parser;
  final ParserBackend backend;
  _ParserGetterSetter(this.parser, this.backend);

  generateParser(List<String> exprs, StringSink sink) {
    exprs.forEach((expr) {
      try {
        parser(expr);
      } catch (e) {
        // Ignore exceptions.
      }
    });

    DartGetterSetterGen backend = this.backend;
    sink.write(generateClosureMap(backend.properties, backend.calls));
  }

  String generateClosureMap(Set<String> properties,
      Map<String, Set<int>> calls) {
    return '''
class StaticClosureMap extends ClosureMap {
  Getter lookupGetter(String name) => getters[name];
  Setter lookupSetter(String name) => setters[name];
  lookupFunction(String name, int arity)
      => (arity < functions.length) ? functions[arity][name] : null;
}

final Map<String, Getter> getters = ${generateGetterMap(properties)};
final Map<String, Setter> setters = ${generateSetterMap(properties)};
final List<Map<String, Function>> functions = ${generateFunctionMap(calls)};
''';
  }

  generateGetterMap(Iterable<String> keys) {
    var lines = keys.map((key) => 'r"${key}": (o) => o.$key');
    return '{\n  ${lines.join(",\n  ")}\n}';
  }

  generateSetterMap(Iterable<String> keys) {
    var lines = keys.map((key) => 'r"${key}": (o, v) => o.$key = v');
    return '{\n  ${lines.join(",\n  ")}\n}';
  }

  generateFunctionMap(Map<String, Set<int>> calls) {
    Map<int, Set<String>> arities = {};
    calls.forEach((name, callArities) {
      callArities.forEach((arity){
        arities.putIfAbsent(arity, () => new Set<String>()).add(name);
      });
    });

    var maxArity = arities.isEmpty ? 0 :
        arities.keys.reduce((x, y) => math.max(x, y));

    var maps = new Iterable.generate(maxArity + 1, (arity) {
      var names = arities[arity];
      if (names == null) {
        return '{\n    }';
      } else {
        var args = new List.generate(arity, (e) => "a$e").join(',');
        var p = args.isEmpty ? '' : ', $args';
        var lines = names.map((name) => 'r"$name": (o$p) => o.$name($args)');
        return '{\n    ${lines.join(",\n    ")}\n  }';
      }
    });

    return '[${maps.join(",")}]';
  }
}

