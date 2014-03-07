library bootstrap_spec;

import '_specs.dart';
import 'package:angular/angular_dynamic.dart';

void main() {
  describe('bootstrap', () {
    BodyElement body = window.document.querySelector('body');

    it('should default to whole page', () {
      body.innerHtml = '<div>{{"works"}}</div>';
      new NgDynamicApp().run();
      expect(body.innerHtml).toEqual('<div>works</div>');
    });

    it('should compile starting at ng-app node', () {
      body.setInnerHtml(
          '<div>{{ignor me}}<div ng-app ng-bind="\'works\'"></div></div>',
          treeSanitizer: new NullTreeSanitizer());
      new NgDynamicApp().run();
      expect(body.text).toEqual('{{ignor me}}works');
    });

    it('should compile starting at ng-app node', () {
      body.setInnerHtml(
          '<div>{{ignor me}}<div ng-bind="\'works\'"></div></div>',
          treeSanitizer: new NullTreeSanitizer());
      new NgDynamicApp()..selector('div[ng-bind]')..run();
      expect(body.text).toEqual('{{ignor me}}works');
    });
  });
}
