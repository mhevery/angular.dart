part of angular.core.dom_internal;

@Injectable()
class TranscludingComponentFactory implements ComponentFactory {

  final Expando expando;
  final ViewCache viewCache;
  final CompilerConfig config;

  TranscludingComponentFactory(this.expando, this.viewCache, this.config);

  bind(DirectiveRef ref, directives, injector) =>
      new BoundTranscludingComponentFactory(this, ref, directives, injector);
}

class BoundTranscludingComponentFactory implements BoundComponentFactory {
  final TranscludingComponentFactory _f;
  final DirectiveRef _ref;
  final DirectiveMap _directives;
  final Injector _injector;

  Component get _component => _ref.annotation as Component;
  async.Future<ViewFactory> _viewFactoryFuture;
  ViewFactory _viewFactory;

  BoundTranscludingComponentFactory(this._f, this._ref, this._directives, this._injector) {
    _viewFactoryFuture = BoundComponentFactory._viewFactoryFuture(_component, _f.viewCache, _directives);
    if (_viewFactoryFuture != null) {
      _viewFactoryFuture.then((viewFactory) => _viewFactory = viewFactory);
    }
  }

  List<Key> get callArgs => _CALL_ARGS;
  static var _CALL_ARGS = [ DIRECTIVE_INJECTOR_KEY, SCOPE_KEY,
                            VIEW_CACHE_KEY, HTTP_KEY, TEMPLATE_CACHE_KEY,
                            DIRECTIVE_MAP_KEY, NG_BASE_CSS_KEY, EVENT_HANDLER_KEY];
  Function call(dom.Node node) {
    // CSS is not supported.
    assert(_component.cssUrls == null ||
           _component.cssUrls.isEmpty);

    var element = node as dom.Element;
    var component = _component;
    return (DirectiveInjector injector, Scope scope,
            ViewCache viewCache, Http http, TemplateCache templateCache,
            DirectiveMap directives, NgBaseCss baseCss, EventHandler eventHandler) {

      List<async.Future> futures = [];
      var lightDom = new LightDom(element, scope);
      TemplateLoader templateLoader = new TemplateLoader(element, futures);
      Scope shadowScope = scope.createChild(new HashMap());
      DirectiveInjector childInjector = new ComponentDirectiveInjector(
          injector, this._injector, eventHandler, shadowScope, templateLoader,
          new EmulatedShadowRoot(element), lightDom);
      childInjector.bindByKey(_ref.typeKey, _ref.factory, _ref.paramKeys, _ref.annotation.visibility);

      var controller = childInjector.getByKey(_ref.typeKey);
      shadowScope.context[component.publishAs] = controller;
      if (controller is ScopeAware) controller.scope = shadowScope;
      BoundComponentFactory._setupOnShadowDomAttach(controller, templateLoader, shadowScope);

      if (_viewFactoryFuture != null && _viewFactory == null) {
        futures.add(_viewFactoryFuture.then((ViewFactory viewFactory) =>
            _insert(viewFactory, element, childInjector, lightDom)));
      } else {
        scope.rootScope.runAsync(() {
          _insert(_viewFactory, element, childInjector, lightDom);
        });
      }
      return controller;
    };
  }

  _insert(ViewFactory viewFactory, dom.Element element, DirectiveInjector childInjector,
          LightDom lightDom) {
    lightDom.pullNodes();
    if (viewFactory != null) {
      lightDom.shadowDomView = viewFactory.call(childInjector.scope, childInjector);
    }
  }
}
