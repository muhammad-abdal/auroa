import 'package:flutter/widgets.dart';

import '../theme/breakpoints.dart';

/// Publishes the current [ShellLayout] to the subtree.
///
/// The shell measures once with a single [LayoutBuilder] and every screen
/// downstream reads the result through this scope. Without it, each screen
/// would call `MediaQuery.of(context).size` independently, and on a grid
/// repainting at 60fps those lookups add up.
class LayoutScope extends InheritedWidget {
  final ShellLayout layout;

  const LayoutScope({super.key, required this.layout, required super.child});

  static ShellLayout of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LayoutScope>();
    assert(
      scope != null,
      'LayoutScope is missing from the widget tree.\n'
      'It must wrap the subtree that contains any responsive screen.',
    );
    return scope!.layout;
  }

  @override
  bool updateShouldNotify(LayoutScope oldWidget) => oldWidget.layout != layout;
}
