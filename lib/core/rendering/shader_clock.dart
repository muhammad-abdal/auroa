import 'package:flutter/widgets.dart';

/// The app's single time source.
///
/// One [Ticker] in the shell updates one [ValueNotifier<double>]. Every
/// live shader in the tree reads that notifier and hands it to
/// [CustomPainter.repaint] — which means tiles repaint **without a widget
/// rebuild**. That's the difference between a gallery at 60fps and one
/// that stalls the raster thread on every tick.
///
/// Never create a per-tile Ticker. Six tickers on a grid is the single
/// biggest perf mistake in this app.
///
/// The [time] notifier is stable for the app's lifetime — the shell creates
/// it once and disposes it on unmount. [updateShouldNotify] therefore
/// returns false, and dependents never rebuild just because a frame passed.
class ShaderClock extends InheritedWidget {
  final ValueNotifier<double> time;

  const ShaderClock({super.key, required this.time, required super.child});

  /// Looks up the clock. Safe to call from `didChangeDependencies` — the
  /// widget registers a dependency, so if the shell ever swaps the
  /// notifier, tiles re-resolve it on the next build.
  static ValueNotifier<double> of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ShaderClock>();
    assert(
      scope != null,
      'ShaderClock is missing from the widget tree.\n'
      'It must wrap the subtree that contains any ShaderView.',
    );
    return scope!.time;
  }

  @override
  bool updateShouldNotify(ShaderClock oldWidget) => oldWidget.time != time;
}
