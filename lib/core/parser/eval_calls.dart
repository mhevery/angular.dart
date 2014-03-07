library angular.core.parser.eval_calls;

import 'package:angular/core/parser/parser.dart';
import 'package:angular/core/parser/syntax.dart' as syntax;
import 'package:angular/core/parser/utils.dart';
import 'package:angular/core/module.dart';

class CallScope extends syntax.CallScope {
  final MethodClosure function;
  CallScope(name, this.function, arguments)
      : super(name, arguments);

  eval(scope, [FilterMap filters]) {
    var args = new List(arguments.length);
    for(var i = 0; i < arguments.length; i++) {
      args[i] = arguments[i].eval(scope, filters);
    }
    if (scope is Map) {
      var fn = scope[name];
      if (fn == null)
        _throwUndefinedFunction(name);
      return Function.apply(fn, args);
    } else {
      if (function == null) {
        _throwUndefinedFunction(name);
      }
      return function(scope, args);
    }
  }
}

class CallMember extends syntax.CallMember {
  final MethodClosure function;
  CallMember(object, this.function, name, arguments)
      : super(object, name, arguments)
  {
    if (function == null) {
      _throwUndefinedFunction(name);
    }
  }

  eval(scope, [FilterMap filters]) {
    var args = new List(arguments.length);
    for(var i = 0; i < arguments.length; i++) {
      args[i] = arguments[i].eval(scope, filters);
    }
    return function(object.eval(scope, filters), args);
  }
}

class CallFunction extends syntax.CallFunction {
  CallFunction(function, arguments) : super(function, arguments);
  eval(scope, [FilterMap filters]) {
    var function  = this.function.eval(scope, filters);
    if (function is! Function) {
      throw new EvalError('${this.function} is not a function');
    } else {
      return relaxFnApply(function, evalList(scope, arguments, filters));
    }
  }
}

_throwUndefinedFunction(name) {
  throw "Undefined function $name";
}

