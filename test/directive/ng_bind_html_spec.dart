library ng_bind_html_spec;

import 'dart:html' as dom;
import '../_specs.dart';

main() {
  describe('BindHtmlDirective', () {

    it('should sanitize and set innerHtml and sanitize and set html', (Scope scope, TestBed _) {
      _.compile('<div bind-ng-bind-html="htmlVar"></div>');
      scope.context['htmlVar'] = '<a href="http://www.google.com"><b>Google!</b></a>';
      scope.apply();
      // Sanitization removes the href attribute on the <a> tag.
      expect(_.rootElement).toHaveHtml('<a><b>Google!</b></a>');
    });

    describe('injected NodeValidator', () {
      beforeEachModule((Module module) {
        module.bind(dom.NodeValidator, toFactory: (_) {
          final validator = new NodeValidatorBuilder();
          validator.allowNavigation(new AnyUriPolicy());
          validator.allowTextElements();
          return validator;
        });
      });

      it('should use injected NodeValidator and override default sanitize behavior', (Scope scope, TestBed _) {
        _.compile('<div bind-ng-bind-html="htmlVar"></div>');
        scope.context['htmlVar'] = '<a href="http://www.google.com"><b>Google!</b></a>';
        scope.apply();
        // Sanitation allows href attributes per injected sanitizer.
        expect(_.rootElement).toHaveHtml('<a href="http://www.google.com"><b>Google!</b></a>');
      });
    });
  });
}

class AnyUriPolicy implements UriPolicy {
  bool allowsUri(String uri) => true;
}
