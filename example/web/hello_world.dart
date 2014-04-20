import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

@Controller(
    selector: '[hello-world-controller]',
    publishAs: 'ctrl')
class HelloWorld {
  String name = "Otto, anna, marko";
  List<String> _namesList = [];

  List<String> get names {
    var items;
    name.split(',').forEach((n) {
      if(!_isInNameList(n)) {
        print("${n} is not in ${_namesList}");
        _namesList.add(n);
      }
    });
    return _namesList;
  }

  _isInNameList(String s) {
    return _namesList.any((element) => element == s);
  }

  bool isPalindrome(String user) {
    return user.toLowerCase().trim() == user.split('').reversed.join().toLowerCase().trim();
  }
}

main() {
  applicationFactory()
      .addModule(new Module()..type(HelloWorld))
      .run();
}
