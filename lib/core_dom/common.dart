part of angular.core.dom_internal;

List<dom.Node> cloneElements(elements) {
  return elements.map((el) => el.clone(true)).toList();
}

class MappingParts {
  final String attrName;
  final String mode;
  final String src;
  final Expression srcExp;
  final String dst;
  final Expression dstExp;
  final String originalValue;

  const MappingParts(this.attrName, this.mode, this.src, this.srcExp,
                     this.dst, this.dstExp, this.originalValue);
}

class DirectiveRef {
  final dom.Node element;
  final Type type;
  final Factory factory;
  final List<Key> paramKeys;
  final Key typeKey;
  final Directive annotation;
  final String value;
  final String expression;
  final mappings = new List<MappingParts>();

  DirectiveRef(this.element, type, this.annotation, this.typeKey, [ this.value, this.expression ])
      : type = type,
        factory = Module.DEFAULT_REFLECTOR.factoryFor(type),
        paramKeys = Module.DEFAULT_REFLECTOR.parameterKeysFor(type);

  String toString() {
    var html = element is dom.Element
        ? (element as dom.Element).outerHtml
        : element.nodeValue;
    return '{ element: $html, selector: ${annotation.selector}, value: $value, '
           'type: $type }';
  }
}

/**
 * Creates a child injector that allows loading new directives, formatters and
 * services from the provided modules.
 */
Injector forceNewDirectivesAndFormatters(Injector injector, List<Module> modules) {
  modules.add(new Module()
      ..bind(Scope, toFactory: (Injector injector) {
          var scope = injector.parent.getByKey(SCOPE_KEY);
          return scope.createChild(new PrototypeMap(scope.context));
        }, inject: [INJECTOR_KEY])
      ..bind(DirectiveMap)
      ..bind(FormatterMap));

  return new ModuleInjector(modules, injector);
}
