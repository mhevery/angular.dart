library dirty_checking_change_detector_dynamic;

import 'package:angular/change_detection/change_detection.dart';

/**
 * We are using mirrors, but there is no need to import anything.
 */
@MirrorsUsed(targets: const [], metaTargets: const [])
import 'dart:mirrors';

class DynamicFieldGetterFactory implements FieldGetterFactory {
  FieldGetter call (Object object, String name) {
    Symbol symbol = new Symbol(name);
    InstanceMirror instanceMirror = reflect(object);
    return (Object object) {
      return instanceMirror.getField(symbol).reflectee;
    };
  }
}
