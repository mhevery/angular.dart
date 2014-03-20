part of angular;

/**
 * This is the top level module which describes the whole of angular.
 *
 * The Module is made up of
 *
 * - [NgCoreModule]
 * - [NgCoreDomModule]
 * - [NgDirectiveModule]
 * - [NgFilterModule]
 * - [NgPerfModule]
 * - [NgRoutingModule]
 */
class AngularModule extends Module {
  AngularModule() {
    install(new NgCoreModule());
    install(new NgCoreDomModule());
    install(new NgDirectiveModule());
    install(new NgFilterModule());
    install(new NgPerfModule());
    install(new NgRoutingModule());

    type(MetadataExtractor);
    value(Expando, _elementExpando);
  }
}

/**
 * Bootstraps AngularDart and defines which application module(s) are available to the app.
 *
 * NgApp is how you configure and run an Angular application. NgApp is abstract. There are two
 * implementations: one is dynamic, using Mirrors; the other is static, using code generation.
 *
 * To create an NgApp, import angular_dynamic.dart and call ngDynamicApp like so:
 *
 *     import 'package:angular/angular.dart';
 *     import 'package:angular/angular_dynamic.dart';
 *
 *     class HelloWorldController {
 *       ...
 *       }
 *
 *     main() {
 *      ngDynamicApp()
 *        .addModule(new Module()..type(HelloWorldController))
 *        .run();
 *     }
 *
 * On `pub build`, ngDynamicApp becomes ngStaticApp, as pub generates the getters,
 * setters, annotations, and factories for the root Injector that [ngApp] creates. This
 *
 *
 * Here, the ngBootstrap method performs the following actions:
 *
 *   1. Locating the root element of the application,
 *   2. Creating Angular [NgZone]
 *   3. Inside the [NgZone] create an injector
 *   4. Retrieve the [Compiler] and compile the root element
 *
 *
 */

abstract class NgApp {
  static _find(String selector, [dom.Element defaultElement]) {
    var element = dom.window.document.querySelector(selector);
    if (element == null) element = defaultElement;
    if (element == null)throw "Could not find application element '$selector'.";
    return element;
  }

  final NgZone zone = new NgZone();
  final AngularModule ngModule = new AngularModule();
  final List<Module> modules = <Module>[];
  dom.Element element;

  dom.Element selector(String selector) => element = _find(selector);

  NgApp(): element = _find('[ng-app]', dom.window.document.documentElement) {
    modules.add(ngModule);
    ngModule
      ..value(NgZone, zone)
      ..value(NgApp, this)
      ..factory(dom.Node, (i) => i.get(NgApp).element);
  }

  Injector injector;

  NgApp addModule(Module module) {
    modules.add(module);
    return this;
  }

  Injector run() {
    _publishToJavaScript();
    return zone.run(() {
      var rootElements = [element];
      Injector injector = createInjector();
      ExceptionHandler exceptionHandler = injector.get(ExceptionHandler);
      initializeDateFormatting(null, null).then((_) {
        try {
          var compiler = injector.get(Compiler);
          var blockFactory = compiler(rootElements, injector.get(DirectiveMap));
          blockFactory(injector, rootElements);
        } catch (e, s) {
          exceptionHandler(e, s);
        }
      });
      return injector;
    });
  }

  Injector createInjector();
}
