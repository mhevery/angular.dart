import 'package:angular/angular.dart';
import 'package:angular/angular_dynamic.dart';

@NgController(
    selector: '[my-controller]',
    publishAs: 'ctrl'
)
class MyController {

  String currentValue = "aaa";
  void selectionChanged() {
    print("currentValue $currentValue");
  }
}

main() {
  dynamicApplication()
      .addModule(new Module()..type(MyController))
      .run();
}
