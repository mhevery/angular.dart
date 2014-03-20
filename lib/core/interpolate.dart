part of angular.core;

/**
 * Compiles a string with markup into an expression. This service is used by the
 * HTML [Compiler] service for data binding.
 *
 *     var $interpolate = ...; // injected
 *     var exp = $interpolate('Hello {{name}}!');
 *     expect(exp).toEqual('"Hello "+(name)+"!"');
 */
@NgInjectableService()
class Interpolate implements Function {
  final Parser _parse;

  Interpolate(this._parse);

  /**
   * Compiles markup text into expression.
   *
   * - `template`: The markup text to interpolate in form `foo {{expr}} bar`.
   * - `mustHaveExpression`: if set to true then the interpolation string must
   *   have embedded expression in order to return an expression. Strings with
   *   no embedded expression will return null.
   * - `startSymbol`: The symbol to start interpolation. '{{' by default.
   * - `endSymbol`: The symbol to end interpolation. '}}' by default.
   */

  String call(String template, [bool mustHaveExpression = false,
      String startSymbol = '{{', String endSymbol = '}}']) {

    int startLen = startSymbol.length;
    int endLen = endSymbol.length;
    int length = template.length;

    int startIdx;
    int endIdx;
    int index = 0;

    bool hasInterpolation = false;

    String exp;
    final expParts = <String>[];

    while (index < length) {
      startIdx = template.indexOf(startSymbol, index);
      endIdx = template.indexOf(endSymbol, startIdx + startLen);
      if (startIdx != -1 && endIdx != -1) {
        if (index < startIdx) {
          expParts.add('"${template.substring(index, startIdx)}"');
        }
        expParts.add('(${template.substring(startIdx + startLen, endIdx)})');
        index = endIdx + endLen;
        hasInterpolation = true;
      } else {
        // we did not find any interpolation, so add the remainder
        expParts.add('"${template.substring(index)}"');
        break;
      }
    }

    return !mustHaveExpression || hasInterpolation ? expParts.join('+') : null;
  }
}