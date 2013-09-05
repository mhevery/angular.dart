part of angular;

@NgDirective(
    selector: '[ng-click]',
    map: const {'ng-click': '&.onClick'}
)
class NgClickAttrDirective {
  Function onClick;

  NgClickAttrDirective(dom.Node node, Scope scope) {
    node.onClick.listen((event) {
      event.preventDefault();
      scope.$apply(onClick);
    });
  }
}
