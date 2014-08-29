library angular.dom.view_impl;

import "dart:html" show Node;

/**
 * The purpose of the [View] is to:
 *
 * - represent a chunk of DOM that can be efficiently inserted / removed from [ViewPort]
 * - represent a chunk of DOM which is structurally fixed (only attributes, properties, and
 *   text nodes can change).
 * - instantiate Directives
 *
 *
 * # Creation
 *
 * A view is created by [ViewFactory]. The creation process involves cloning template DOM,
 * creating [WatchGroup]s for digest and flush, and setting up the DirectiveInjectors. The
 * creation should contain all of the expensive code, so that we can cache created views,
 * the goal is to make attaching/detaching cheap.
 *
 *
 * # Lifecycle
 *
 * A [View] can be either attached or detached. Attaching a view requires:
 *
 * - Inserting the [View] into [ViewPort]
 * - Linking the DirectiveInjectors, with parent view DirectiveInjectors
 * - Scheduling DOM Writes to attach DOM elements to [ViewPort]s anchor element.
 * - Hydrating directive instances
 *
 * Detaching requires:
 *
 * - Removing [View] from [ViewPort]
 * - Scheduling removal of DOM elements from [ViewPort] anchor element
 * - Releasing DirectiveInjector instances (optionally calling detach on directive instances)
 * - Un-linking the DirectiveInjector
 *
 */
class View {
  /**
   * The view Factory which created this view and is responsible for caching these Views.
   */
  final ViewFactory viewFactory;

  /**
   * A set of DOM nodes which this [View] considers roots.
   */
  final List<Node> nodes;

  /**
   * If true than [View] is part of [ViewPort] if false than it is cached view ready for reuse.
   */
  bool isAttached;

  /**
   * If attached, than next/prev is used by [ViewPort] to keep a linked list of all [View]s.
   * If detached than next/prev is used by [ViewFactory] to keep a linked list of all cached
   * [View]s available for reuse.
   *
   * Attaching/detaching requires moving the View from one list to the other.
   */
  View nextView, prevView;
  ViewPort headViewPort, tailViewPort;
  DirectiveInjector headDirectiveInjector, tailDirectiveInjector;

}
