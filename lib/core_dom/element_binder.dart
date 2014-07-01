part of angular.core.dom_internal;

class TemplateElementBinder extends ElementBinder {
  final DirectiveRef template;
  ViewFactory templateViewFactory;

  final bool hasTemplate = true;

  final ElementBinder templateBinder;

  var _directiveCache;
  List<DirectiveRef> get _usableDirectiveRefs {
    if (_directiveCache != null) return _directiveCache;
    return _directiveCache = [template];
  }

  TemplateElementBinder(perf, expando, parser, config,
                        this.template, this.templateBinder,
                        onEvents, bindAttrs, childMode, FormatterMap formatters)
      : super(perf, expando, parser, formatters, config,
          null, null, onEvents, bindAttrs, childMode);

  String toString() => "[TemplateElementBinder template:$template]";
}


/**
 * ElementBinder is created by the Selector and is responsible for instantiating
 * individual directives and binding element properties.
 */
class ElementBinder {
  // DI Services
  final Profiler _perf;
  final Expando _expando;
  final Parser _parser;
  final FormatterMap _formatterMap;
  final CompilerConfig _config;

  final Map onEvents;
  final Map bindAttrs;

  // Member fields
  final decorators;

  final BoundComponentData componentData;

  // Can be either COMPILE_CHILDREN or IGNORE_CHILDREN
  final String childMode;

  ElementBinder(this._perf, this._expando, this._parser, this._formatterMap, this._config,
                this.componentData, this.decorators,
                this.onEvents, this.bindAttrs, this.childMode);

  final bool hasTemplate = false;

  bool get shouldCompileChildren =>
      childMode == Directive.COMPILE_CHILDREN;

  var _directiveCache;
  List<DirectiveRef> get _usableDirectiveRefs {
    if (_directiveCache != null) return _directiveCache;
    if (componentData != null) return _directiveCache = new List.from(decorators)..add(componentData.ref);
    return _directiveCache = decorators;
  }

  bool get hasDirectivesOrEvents =>
      _usableDirectiveRefs.isNotEmpty || onEvents.isNotEmpty;

  void _bindTwoWay(_TaskList tasks, Scope scope, MappingParts mapping, controller) {
    var taskId = (tasks != null) ? tasks.registerTask() : 0;

    var viewOutbound = false;
    var viewInbound = false;
    scope.watch(mapping.src, (inboundValue, _) {
      if (!viewInbound) {
        viewOutbound = true;
        scope.rootScope.runAsync(() => viewOutbound = false);
        var value = mapping.dstExp.assign(controller, inboundValue);
        if (tasks != null) tasks.completeTask(taskId);
        return value;
      }
    });
    if (mapping.srcExp.isAssignable) {
      scope.watch(mapping.dst, (outboundValue, _) {
        if (!viewOutbound) {
          viewInbound = true;
          scope.rootScope.runAsync(() => viewInbound = false);
          mapping.srcExp.assign(scope.context, outboundValue);
          if (tasks != null) tasks.completeTask(taskId);
        }
      }, context: controller);
    }
  }

  _bindOneWay(_TaskList tasks, Scope scope, MappingParts mapping, controller) {
    var taskId = (tasks != null) ? tasks.registerTask() : 0;

    scope.watch(mapping.src, (v, _) {
      mapping.dstExp.assign(controller, v);
      if (tasks != null) tasks.completeTask(taskId);
    });
  }

  void _bindCallback(Scope scope, MappingParts mapping, controller) {
    mapping.dstExp.assign(controller, mapping.srcExp.bind(scope.context, ScopeLocals.wrapper));
  }


  void _createAttrMappings(directive, Scope scope, List<MappingParts> mappings, nodeAttrs, tasks) {
    for(var i = 0; i < mappings.length; i++) {
      MappingParts mapping = mappings[i];
      String attrName = mapping.attrName;
      String src = mapping.src;
      String dst = mapping.dst;

      if (!mapping.dstExp.isAssignable) {
        throw "Expression '${mapping.dst}' is not assignable in mapping '${mapping.originalValue}' "
              "for attribute '$attrName'.";
      }

      // Check if there is a bind attribute for this mapping.
      var bindAttr = bindAttrs["bind-${mapping.attrName}"];
      if (bindAttr != null) {
        if (mapping.mode == '<=>') {
          _bindTwoWay(tasks, scope, mapping);
        } else if (mapping.mode == '&') {
          throw "Callbacks do not support bind- syntax";
        } else {
          _bindOneWay(tasks, scope, mapping, directive);
        }
        continue;
      }

      switch (mapping.mode) {
        case '@': // string
          var taskId = (tasks != null) ? tasks.registerTask() : 0;
          nodeAttrs.observe(attrName, (value) {
            mapping.dstExp.assign(directive, value);
            if (tasks != null) tasks.completeTask(taskId);
          });
          break;

        case '<=>': // two-way
          if (nodeAttrs[attrName] == null) continue;
          _bindTwoWay(tasks, scope, mapping, directive);
          break;

        case '=>': // one-way
          if (nodeAttrs[attrName] == null) continue;
          _bindOneWay(tasks, scope, mapping, directive);
          break;

        case '=>!': //  one-way, one-time
          if (nodeAttrs[attrName] == null) continue;

          var watch;
          var lastOneTimeValue;
          watch = scope.watch(mapping.src, (value, _) {
            if ((lastOneTimeValue = mapping.dstExp.assign(directive, value)) != null && watch != null) {
                var watchToRemove = watch;
                watch = null;
                scope.rootScope.domWrite(() {
                  if (lastOneTimeValue != null) {
                    watchToRemove.remove();
                  } else {  // It was set to non-null, but stablized to null, wait.
                    watch = watchToRemove;
                  }
                });
            }
          });
          break;

        case '&': // callback
          _bindCallback(scope, mapping, directive);
          break;
      }
    }
  }

  void _link(DirectiveInjector directiveInjector, Scope scope, nodeAttrs) {
    for(var i = 0; i < _usableDirectiveRefs.length; i++) {
      DirectiveRef ref = _usableDirectiveRefs[i];
      var key = ref.typeKey;
      if (identical(key, TEXT_MUSTACHE_KEY) || identical(key, ATTR_MUSTACHE_KEY)) continue;
      var directive = directiveInjector.getByKey(ref.typeKey);

      if (ref.annotation is Controller) {
        scope.parentScope.context[(ref.annotation as Controller).publishAs] = directive;
      }

      var tasks = directive is AttachAware ? new _TaskList(() {
        if (scope.isAttached) directive.attach();
      }) : null;

      if (ref.mappings.isNotEmpty) {
        if (nodeAttrs == null) nodeAttrs = new _AnchorAttrs(ref);
        _createAttrMappings(directive, scope, ref.mappings, nodeAttrs, tasks);
      }

      if (directive is AttachAware) {
        var taskId = tasks.registerTask();
        Watch watch;
        watch = scope.watch('1', // Cheat a bit.
            (_, __) {
          watch.remove();
          tasks.completeTask(taskId);
        });
      }

      if (tasks != null) tasks.doneRegistering();

      if (directive is DetachAware) {
        scope.on(ScopeEvent.DESTROY).listen((_) => directive.detach());
      }
    }
  }

  void _createDirectiveFactories(DirectiveRef ref, DirectiveInjector nodeInjector, node,
                                 nodeAttrs) {
    if (ref.typeKey == TEXT_MUSTACHE_KEY) {
      new TextMustache(node, ref.value, nodeInjector.scope, _formatterMap);
    } else if (ref.typeKey == ATTR_MUSTACHE_KEY) {
      new AttrMustache(nodeAttrs, ref.value, ref.expression, nodeInjector.scope, _formatterMap);
    } else if (ref.annotation is Component) {
      assert(ref == componentData.ref);

      BoundComponentFactory boundComponentFactory = componentData.factory;
      Function componentFactory = boundComponentFactory.call(node);
      nodeInjector.bindByKey(ref.typeKey,
          (p) => Function.apply(componentFactory, p),
          boundComponentFactory.callArgs, ref.annotation.visibility);
    } else {
      nodeInjector.bindByKey(ref.typeKey, ref.factory, ref.paramKeys, ref.annotation.visibility);
    }
  }

  DirectiveInjector bind(View view, Scope scope,
                         DirectiveInjector parentInjector, Injector appInjector,
                         dom.Node node, EventHandler eventHandler, Animate animate) {
    var nodeAttrs = node is dom.Element ? new NodeAttrs(node) : null;

    var directiveRefs = _usableDirectiveRefs;
    if (!hasDirectivesOrEvents) return parentInjector;

    DirectiveInjector nodeInjector;
    if (this is TemplateElementBinder) {
      nodeInjector = new TemplateDirectiveInjector(parentInjector, appInjector,
          node, nodeAttrs, eventHandler, scope, animate,
          (this as TemplateElementBinder).templateViewFactory);
    } else {
      nodeInjector = new DirectiveInjector(parentInjector, appInjector,
          node, nodeAttrs, eventHandler, scope, animate);
    }

    for(var i = 0; i < directiveRefs.length; i++) {
      DirectiveRef ref = directiveRefs[i];
      Directive annotation = ref.annotation;
      if (ref.annotation is Controller) {
        scope = nodeInjector.scope = scope.createChild(new PrototypeMap(scope.context));
        scope.context['CTRL'] = true;
      }
      _createDirectiveFactories(ref, nodeInjector, node, nodeAttrs);
      if (ref.annotation.module != null) {
        DirectiveBinderFn config = ref.annotation.module;
        if (config != null) config(nodeInjector);
      }
    }

    if (_config.elementProbeEnabled) {
      _expando[node] = nodeInjector.elementProbe;
      // TODO(misko): pretty sure that clearing Expando is not necessary. Remove?
      scope.on(ScopeEvent.DESTROY).listen((_) => _expando[node] = null);
    }

    _link(nodeInjector, scope, nodeAttrs);

    if (onEvents.isNotEmpty) {
      onEvents.forEach((event, value) {
        view.registerEvent(EventHandler.attrNameToEventName(event));
      });
    }
    return nodeInjector;
  }

  String toString() => "[ElementBinder decorators:$decorators]";
}

/**
 * Private class used for managing controller.attach() calls
 */
class _TaskList {
  Function onDone;
  final List _tasks = [];
  bool isDone = false;
  int firstTask;

  _TaskList(this.onDone) {
    if (onDone == null) isDone = true;
    firstTask = registerTask();
  }

  int registerTask() {
    if (isDone) return null; // Do nothing if there is nothing to do.
    _tasks.add(false);
    return _tasks.length - 1;
  }

  void completeTask(id) {
    if (isDone) return;
    _tasks[id] = true;
    if (_tasks.every((a) => a)) {
      onDone();
      isDone = true;
    }
  }

  void doneRegistering() {
    completeTask(firstTask);
  }
}

// Used for walking the DOM
class ElementBinderTreeRef {
  final int offsetIndex;
  final ElementBinderTree subtree;

  ElementBinderTreeRef(this.offsetIndex, this.subtree);
}

class ElementBinderTree {
  final ElementBinder binder;
  final List<ElementBinderTreeRef> subtrees;

  ElementBinderTree(this.binder, this.subtrees);
}

class TaggedTextBinder {
  final ElementBinder binder;
  final int offsetIndex;

  TaggedTextBinder(this.binder, this.offsetIndex);
  String toString() => "[TaggedTextBinder binder:$binder offset:$offsetIndex]";
}

// Used for the tagging compiler
class TaggedElementBinder {
  final ElementBinder binder;
  int parentBinderOffset;
  bool isTopLevel;

  List<TaggedTextBinder> textBinders;

  TaggedElementBinder(this.binder, this.parentBinderOffset, this.isTopLevel);

  void addText(TaggedTextBinder tagged) {
    if (textBinders == null) textBinders = [];
    textBinders.add(tagged);
  }

  bool get isDummy => binder == null && textBinders == null && !isTopLevel;

  String toString() => "[TaggedElementBinder binder:$binder parentBinderOffset:"
                       "$parentBinderOffset textBinders:$textBinders]";
}
