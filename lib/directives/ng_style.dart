part of angular;

@NgDirective(
    selector: '[ng-style-width]',
    map: const {'ng-style-width': '=.style'}
)
class NgStyleDirective {
  dom.Element element;
  Scope scope;

  NgStyleDirective(dom.Element this.element, Scope this.scope);

  set style(value) {
    element.style.width = value;
  }
}
