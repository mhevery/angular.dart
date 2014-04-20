library dirty_checking_change_detector_dynamic;

import 'package:angular/change_detection/change_detection.dart';
export 'package:angular/change_detection/change_detection.dart' show
    FieldGetterFactory;

/**
 * We are using mirrors, but there is no need to import anything.
 */
@MirrorsUsed(targets: const [ DynamicFieldGetterFactory ], metaTargets: const [] )
import 'dart:mirrors';

class DynamicFieldGetterFactory implements FieldGetterFactory {
  final isMethodInvoke = true;

  bool isMethod(Object object, String name) {
    InstanceMirror im = reflect(object);
    Map methods = {};
    im.type.instanceMembers.forEach((Symbol symbol, MethodMirror methodMirror) {
      if(methodMirror.isRegularMethod) methods[symbol] = methodMirror;
    });
    return methods.keys.contains(new Symbol(name));
  }

  Function method(Object object, String name) {
    Symbol symbol = new Symbol(name);
    InstanceMirror instanceMirror = reflect(object);
    return (List args, Map namedArgs) =>
        instanceMirror.invoke(symbol, args, namedArgs).reflectee;
  }

  Function getter(Object object, String name) {
    Symbol symbol = new Symbol(name);
    InstanceMirror instanceMirror = reflect(object);
    return (Object object) =>  instanceMirror.getField(symbol).reflectee;
  }
}
