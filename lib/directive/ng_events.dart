part of angular.directive;

// NOTE(deboer): onXX functions are now typed as 'var' instead of 'Getter'
// to work-around https://code.google.com/p/dart/issues/detail?id=13519

/**
 * Allows you to specify custom behavior for DOM UI events such as mouse,
 * keyboard and touch events.
 *
 * The custom behavior is specified via an Angular binding expression specified
 * on the `ng-`*event* directive (e.g. `ng-click`).  This expression is evaluated
 * on the correct `scope` every time the event occurs.  The event is available
 * to the expression as `$event`.
 *
 * This is more secure than inline DOM handlers in HTML that execute arbitrary
 * JavaScript code and have access to globals instead of the scope without the
 * safety constraints of the Angular expression language.
 *
 * Example:
 *
 *     <button ng-click="lastEvent='Click'"
 *             ng-doubleclick="lastEvent='DblClick'">
 *         Button
 *     </button>
 *
 * The full list of supported handlers are:
 *
 * - [ng-abort]
 * - [ng-beforecopy]
 * - [ng-beforecut]
 * - [ng-beforepaste]
 * - [ng-blur]
 * - [ng-change]
 * - [ng-click]
 * - [ng-contextmenu]
 * - [ng-copy]
 * - [ng-cut]
 * - [ng-doubleclick]
 * - [ng-drag]
 * - [ng-dragend]
 * - [ng-dragenter]
 * - [ng-dragleave]
 * - [ng-dragover]
 * - [ng-dragstart]
 * - [ng-drop]
 * - [ng-error]
 * - [ng-focus]
 * - [ng-fullscreenchange]
 * - [ng-fullscreenerror]'
 * - [ng-input]
 * - [ng-invalid]
 * - [ng-keydown]
 * - [ng-keypress]
 * - [ng-keyup]
 * - [ng-load]
 * - [ng-mousedown]
 * - [ng-mouseenter]
 * - [ng-mouseleave]
 * - [ng-mousemove]
 * - [ng-mouseout]
 * - [ng-mouseover]
 * - [ng-mouseup]
 * - [ng-mousewheel]
 * - [ng-paste]
 * - [ng-reset]
 * - [ng-scroll]
 * - [ng-search]
 * - [ng-select]
 * - [ng-selectstart]
 * - [ng-speechchange] (documented in dart but not available)
 * - [ng-submit]
 * - [ng-toucheancel]
 * - [ng-touchend]
 * - [ng-touchenter]
 * - [ng-touchleave]
 * - [ng-touchmove]
 * - [ng-touchstart]
 * - [ng-transitionend]
 */
@NgDirective(selector: '[ng-abort]',            map: const {'ng-abort':            '&onAbort'})
@NgDirective(selector: '[ng-beforecopy]',       map: const {'ng-beforecopy':       '&onBeforeCopy'})
@NgDirective(selector: '[ng-beforecut]',        map: const {'ng-beforecut':        '&onBeforeCut'})
@NgDirective(selector: '[ng-beforepaste]',      map: const {'ng-beforepaste':      '&onBeforePaste'})
@NgDirective(selector: '[ng-blur]',             map: const {'ng-blur':             '&onBlur'})
@NgDirective(selector: '[ng-change]',           map: const {'ng-change':           '&onChange'})
@NgDirective(selector: '[ng-click]',            map: const {'ng-click':            '&onClick'})
@NgDirective(selector: '[ng-contextmenu]',      map: const {'ng-contextmenu':      '&onContextMenu'})
@NgDirective(selector: '[ng-copy]',             map: const {'ng-copy':             '&onCopy'})
@NgDirective(selector: '[ng-cut]',              map: const {'ng-cut':              '&onCut'})
@NgDirective(selector: '[ng-doubleclick]',      map: const {'ng-doubleclick':      '&onDoubleClick'})
@NgDirective(selector: '[ng-drag]',             map: const {'ng-drag':             '&onDrag'})
@NgDirective(selector: '[ng-dragend]',          map: const {'ng-dragend':          '&onDragEnd'})
@NgDirective(selector: '[ng-dragenter]',        map: const {'ng-dragenter':        '&onDragEnter'})
@NgDirective(selector: '[ng-dragleave]',        map: const {'ng-dragleave':        '&onDragLeave'})
@NgDirective(selector: '[ng-dragover]',         map: const {'ng-dragover':         '&onDragOver'})
@NgDirective(selector: '[ng-dragstart]',        map: const {'ng-dragstart':        '&onDragStart'})
@NgDirective(selector: '[ng-drop]',             map: const {'ng-drop':             '&onDrop'})
@NgDirective(selector: '[ng-error]',            map: const {'ng-error':            '&onError'})
@NgDirective(selector: '[ng-focus]',            map: const {'ng-focus':            '&onFocus'})
@NgDirective(selector: '[ng-fullscreenchange]', map: const {'ng-fullscreenchange': '&onFullscreenChange'})
@NgDirective(selector: '[ng-fullscreenerror]',  map: const {'ng-fullscreenerror':  '&onFullscreenError'})
@NgDirective(selector: '[ng-input]',            map: const {'ng-input':            '&onInput'})
@NgDirective(selector: '[ng-invalid]',          map: const {'ng-invalid':          '&onInvalid'})
@NgDirective(selector: '[ng-keydown]',          map: const {'ng-keydown':          '&onKeyDown'})
@NgDirective(selector: '[ng-keypress]',         map: const {'ng-keypress':         '&onKeyPress'})
@NgDirective(selector: '[ng-keyup]',            map: const {'ng-keyup':            '&onKeyUp'})
@NgDirective(selector: '[ng-load]',             map: const {'ng-load':             '&onLoad'})
@NgDirective(selector: '[ng-mousedown]',        map: const {'ng-mousedown':        '&onMouseDown'})
@NgDirective(selector: '[ng-mouseenter]',       map: const {'ng-mouseenter':       '&onMouseEnter'})
@NgDirective(selector: '[ng-mouseleave]',       map: const {'ng-mouseleave':       '&onMouseLeave'})
@NgDirective(selector: '[ng-mousemove]',        map: const {'ng-mousemove':        '&onMouseMove'})
@NgDirective(selector: '[ng-mouseout]',         map: const {'ng-mouseout':         '&onMouseOut'})
@NgDirective(selector: '[ng-mouseover]',        map: const {'ng-mouseover':        '&onMouseOver'})
@NgDirective(selector: '[ng-mouseup]',          map: const {'ng-mouseup':          '&onMouseUp'})
@NgDirective(selector: '[ng-mousewheel]',       map: const {'ng-mousewheel':       '&onMouseWheel'})
@NgDirective(selector: '[ng-paste]',            map: const {'ng-paste':            '&onPaste'})
@NgDirective(selector: '[ng-reset]',            map: const {'ng-reset':            '&onReset'})
@NgDirective(selector: '[ng-scroll]',           map: const {'ng-scroll':           '&onScroll'})
@NgDirective(selector: '[ng-search]',           map: const {'ng-search':           '&onSearch'})
@NgDirective(selector: '[ng-select]',           map: const {'ng-select':           '&onSelect'})
@NgDirective(selector: '[ng-selectstart]',      map: const {'ng-selectstart':      '&onSelectStart'})
//@NgDirective(selector: '[ng-speechchange]',     map: const {'ng-speechchange':     '&onSpeechChange'})
@NgDirective(selector: '[ng-submit]',           map: const {'ng-submit':           '&onSubmit'})
@NgDirective(selector: '[ng-toucheancel]',      map: const {'ng-touchcancel':      '&onTouchCancel'})
@NgDirective(selector: '[ng-touchend]',         map: const {'ng-touchend':         '&onTouchEnd'})
@NgDirective(selector: '[ng-touchenter]',       map: const {'ng-touchenter':       '&onTouchEnter'})
@NgDirective(selector: '[ng-touchleave]',       map: const {'ng-touchleave':       '&onTouchLeave'})
@NgDirective(selector: '[ng-touchmove]',        map: const {'ng-touchmove':        '&onTouchMove'})
@NgDirective(selector: '[ng-touchstart]',       map: const {'ng-touchstart':       '&onTouchStart'})
@NgDirective(selector: '[ng-transitionend]',    map: const {'ng-transitionend':    '&onTransitionEnd'})

class NgEvent {
  // Is it better to use a map of listeners or have 29 properties on this
  // object?  One would pretty much only assign to one or two of those
  // properties.  I'm opting for the map since it's less boilerplate code.
  var listeners = {};
  final EventHandler eventHandler;
  final dom.Element element;
  final Scope scope;

  NgEvent(this.element, this.scope, this.eventHandler);

  // NOTE: Do not use the element.on['some_event'].listen(...) syntax.  Doing so
  //     has two downsides:
  //     - it loses the event typing
  //     - some DOM events may have multiple platform-dependent event names
  //       under the covers.  The standard Stream getters you will get the
  //       platform specific event name automatically but you're on your own if
  //       you use the on[] syntax.  This also applies to $dom_addEventListener.
  //     Ref: http://api.dartlang.org/docs/releases/latest/dart_html/Events.html
  _initListener(name, stream, handler) {
    print("DEPRECATED: ng-$name is depricated use on-$name instead.");
    element.attributes['on-$name'] = element.attributes['ng-$name'];
    eventHandler.register(name);
  }

  set onAbort(value)             => _initListener('abort',           element.onAbort,            value);
  set onBeforeCopy(value)        => _initListener('beforecopy',      element.onBeforeCopy,       value);
  set onBeforeCut(value)         => _initListener('beforecut',       element.onBeforeCut,        value);
  set onBeforePaste(value)       => _initListener('beforepaste',     element.onBeforePaste,      value);
  set onBlur(value)              => _initListener('blur',            element.onBlur,             value);
  set onChange(value)            => _initListener('change',          element.onChange,           value);
  set onClick(value)             => _initListener('click',           element.onClick,            value);
  set onContextMenu(value)       => _initListener('contextmenu',     element.onContextMenu,      value);
  set onCopy(value)              => _initListener('copy',            element.onCopy,             value);
  set onCut(value)               => _initListener('cut',             element.onCut,              value);
  set onDoubleClick(value)       => _initListener('doubleclick',     element.onDoubleClick,      value);
  set onDrag(value)              => _initListener('drag',            element.onDrag,             value);
  set onDragEnd(value)           => _initListener('dragend',         element.onDragEnd,          value);
  set onDragEnter(value)         => _initListener('dragenter',       element.onDragEnter,        value);
  set onDragLeave(value)         => _initListener('dragleave',       element.onDragLeave,        value);
  set onDragOver(value)          => _initListener('dragover',        element.onDragOver,         value);
  set onDragStart(value)         => _initListener('dragstart',       element.onDragStart,        value);
  set onDrop(value)              => _initListener('drop',            element.onDrop,             value);
  set onError(value)             => _initListener('error',           element.onError,            value);
  set onFocus(value)             => _initListener('focus',           element.onFocus,            value);
  set onFullscreenChange(value)  => _initListener('fullscreenchange',element.onFullscreenChange, value);
  set onFullscreenError(value)   => _initListener('fullscreenerror', element.onFullscreenError,  value);
  set onInput(value)             => _initListener('input',           element.onInput,            value);
  set onInvalid(value)           => _initListener('invalid',         element.onInvalid,          value);
  set onKeyDown(value)           => _initListener('keydown',         element.onKeyDown,          value);
  set onKeyPress(value)          => _initListener('keypress',        element.onKeyPress,         value);
  set onKeyUp(value)             => _initListener('keyup',           element.onKeyUp,            value);
  set onLoad(value)              => _initListener('load',            element.onLoad,             value);
  set onMouseDown(value)         => _initListener('mousedown',       element.onMouseDown,        value);
  set onMouseEnter(value)        => _initListener('mouseenter',      element.onMouseEnter,       value);
  set onMouseLeave(value)        => _initListener('mouseleave',      element.onMouseLeave,       value);
  set onMouseMove(value)         => _initListener('mousemove',       element.onMouseMove,        value);
  set onMouseOut(value)          => _initListener('mouseout',        element.onMouseOut,         value);
  set onMouseOver(value)         => _initListener('mouseover',       element.onMouseOver,        value);
  set onMouseUp(value)           => _initListener('mouseup',         element.onMouseUp,          value);
  set onMouseWheel(value)        => _initListener('mousewheel',      element.onMouseWheel,       value);
  set onPaste(value)             => _initListener('paste',           element.onPaste,            value);
  set onReset(value)             => _initListener('reset',           element.onReset,            value);
  set onScroll(value)            => _initListener('scroll',          element.onScroll,           value);
  set onSearch(value)            => _initListener('search',          element.onSearch,           value);
  set onSelect(value)            => _initListener('select',          element.onSelect,           value);
  set onSelectStart(value)       => _initListener('selectstart',     element.onSelectStart,      value);
//set onSpeechChange(value)      => _initListener('speechchange',    element.onSpeechChange,     value);
  set onSubmit(value)            => _initListener('submit',          element.onSubmit,           value);
  set onTouchCancel(value)       => _initListener('touchcancel',     element.onTouchCancel,      value);
  set onTouchEnd(value)          => _initListener('touchend',        element.onTouchEnd,         value);
  set onTouchEnter(value)        => _initListener('touchenter',      element.onTouchEnter,       value);
  set onTouchLeave(value)        => _initListener('touchleave',      element.onTouchLeave,       value);
  set onTouchMove(value)         => _initListener('touchmove',       element.onTouchMove,        value);
  set onTouchStart(value)        => _initListener('touchstart',      element.onTouchStart,       value);
  set onTransitionEnd(value)     => _initListener('transitionend',   element.onTransitionEnd,    value);
}
