import 'package:flutter/foundation.dart';

/// Forwards repaint ticks from [source] only while open.
///
/// A [ShaderView] hands this to its painter as `repaint:`. When the tile
/// scrolls off-screen, [close] stops the forwarding — the ticker keeps
/// running, the notifier keeps updating, but the painter never hears
/// about it and the raster thread skips that tile entirely.
///
/// Reopening is not just "resume forwarding" — [open] calls
/// [notifyListeners] once immediately, so the tile repaints with the
/// current time the moment it scrolls back into view. Without that,
/// a tile scrolled off for 30 seconds and back would sit on its last
/// painted frame until the next tick, which looks like a stutter.
class RepaintGate extends ChangeNotifier {
  final Listenable source;
  bool _open;
  bool _disposed = false;

  RepaintGate(this.source, {this._open = true}) {
    source.addListener(_onTick);
  }

  bool get isOpen => _open;

  void _onTick() {
    if (_disposed || !_open) return;
    notifyListeners();
  }

  void open() {
    if (_disposed || _open) return;
    _open = true;
    notifyListeners();
  }

  void close() {
    _open = false;
  }

  @override
  void dispose() {
    _disposed = true;
    source.removeListener(_onTick);
    super.dispose();
  }
}
