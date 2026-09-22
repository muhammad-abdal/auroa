import 'dart:async';
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';

import '../../domain/entities/shader_params.dart';
import '../../domain/entities/shader_spec.dart';
import '../../domain/repositories/favorites_repository.dart';

/// Owns the in-progress edit of one shader's params.
///
/// Two responsibilities, and it earns its own file for the second one:
///  1. Hold the current [ShaderParams] and notify the UI on every change.
///     The shader behind the sheet must repaint on every slider tick.
///  2. Debounce the Hive write. Writing on every tick would hammer the
///     box hundreds of times per drag. 400ms is long enough to coalesce a
///     drag into one write, short enough that a pause feels saved.
///
/// Both [shader params] and [resetParams] flush immediately — they're
/// discrete taps, not drags, and the user expects them to stick.
class CustomizeController extends ChangeNotifier {
  final FavoritesRepository repository;
  final ShaderSpec spec;

  ShaderParams _params;
  Timer? _debounce;
  bool _disposed = false;

  static const Duration _debounceDelay = Duration(milliseconds: 400);

  CustomizeController({required this.repository, required this.spec})
    : _params = repository.paramsFor(spec);

  ShaderParams get params => _params;

  void setSpeed(double value) =>
      _commit(_params.copyWith(speed: value), immediate: false);

  void setIntensity(double value) =>
      _commit(_params.copyWith(intensity: value), immediate: false);

  void setColorA(Color value) =>
      _commit(_params.copyWith(colorA: value), immediate: true);

  void setColorB(Color value) =>
      _commit(_params.copyWith(colorB: value), immediate: true);

  void reset() {
    _debounce?.cancel();
    _params = spec.defaults;
    notifyListeners();
    repository.resetParams(spec.id);
  }

  void _commit(ShaderParams next, {required bool immediate}) {
    if (next == _params) return;
    _params = next;
    notifyListeners();

    _debounce?.cancel();
    if (immediate) {
      repository.saveParams(spec.id, _params);
    } else {
      _debounce = Timer(_debounceDelay, _flush);
    }
  }

  void _flush() {
    if (_disposed) return;
    repository.saveParams(spec.id, _params);
  }

  @override
  void dispose() {
    // A drag that ends mid-window has an unsaved value. Flush it rather
    // than dropping the user's last adjustment on the floor.
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
      _flush();
    }
    _disposed = true;
    super.dispose();
  }
}
