import 'package:angular/angular.dart';
import 'package:angular/angular_dynamic.dart';
import 'dart:html';

@NgController(
    selector: '[hello-world-controller]',
    publishAs: 'ctrl')
class HelloWorldController {
  alert() => window.alert("Works");
}

@NgComponent(
    selector: 'foo',
    publishAs: 'foo',
    template: '''
      <button ng-click="foo.bar1()">One</button>
      <button ng-click="foo.bar2()">Two</button>
      ''')
class Foo {
  @NgCallback('bar')
  Function bar1;
  void bar2() {
    bar1();
  }
}

main() {
  ngDynamicApp()
      .addModule(new Module()..type(HelloWorldController)..type(Foo))
      .run();
}
