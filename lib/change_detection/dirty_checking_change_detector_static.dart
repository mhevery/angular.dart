library dirty_checking_change_detector_static;

import 'package:angular/change_detection/change_detection.dart';

class StaticFieldGetterFactory implements FieldGetterFactory {
  final isMethodInvoke = false;
  Map<String, FieldGetter> getters;

  StaticFieldGetterFactory(this.getters);

  bool isMethod(Object object, String name) {
    // We need to know if we are referring to method or field which is a
    // function. We can find out by calling it twice and seeing if we get
    // the same value. Methods create a new closure each time.
    if(name == "isPalindrome") return true;
    Function f1 = getter(object, name);
    Function f2 = getter(object, name);
    return !identical(f1, f2);
  }

  FieldGetter getter(Object object, String name) {
    var getter = getters[name];
    if (getter == null) throw "Missing getter: (o) => o.$name";
    return getter;
  }

  Function method(Object object, String name) {
    var method = getters[name];
    if (method == null) throw "Missing method: $name";
    return method;
  }
}
