import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../domain/entities/shader_params.dart';
import '../../domain/entities/shader_spec.dart';
import 'repaint_gate.dart';
import 'shader_clock.dart';
import 'shader_painter.dart';
import 'shader_program_cache.dart';

/// Renders one live shader, sized to fill whatever it's placed inside.
///
/// This is the only widget in the app that touches [ui.FragmentShader].
/// The gallery grid, the detail pager, and the customize preview all use
/// it — that's why it takes [spec] and [params] as plain data rather than
/// reaching for any screen state.
///
/// Lifecycle notes:
/// - The compiled [ui.FragmentProgram] is looked up once in [initState]
///   and never re-fetched. Calling `fromAsset` per build recompiles the
///   shader every frame.
/// - The [ui.FragmentShader] instance is created once and disposed in
///   [dispose]. It is stateful across frames — that's fine, the uniforms
///   are rewritten on every paint.
/// - The [RepaintGate] is created in [didChangeDependencies] because it
///   needs the [ShaderClock] from the tree.
class ShaderView extends StatefulWidget {
  final ShaderSpec spec;
  final ShaderParams params;

  /// See [ShaderPainter.resolutionScale]. Visual only, not perf.
  final double resolutionScale;

  /// When false, the shader holds its last painted frame. Used by the
  /// detail screen's pause button.
  final bool live;

  const ShaderView({
    super.key,
    required this.spec,
    required this.params,
    this.resolutionScale = 1.0,
    this.live = true,
  });

  @override
  State<ShaderView> createState() => _ShaderViewState();
}

class _ShaderViewState extends State<ShaderView> {
  late final ui.FragmentShader _shader;
  RepaintGate? _gate;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _shader = ShaderProgramCache.program(widget.spec.id).fragmentShader();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gate ??= RepaintGate(
      ShaderClock.of(context),
      open: _visible && widget.live,
    );
  }

  @override
  void didUpdateWidget(ShaderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.live != widget.live) _syncGate();
  }

  void _syncGate() {
    final shouldBeOpen = _visible && widget.live;
    if (shouldBeOpen) {
      _gate?.open();
    } else {
      _gate?.close();
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    // 0.1 rather than 0: a tile half-scrolled off the top of the grid is
    // still worth animating, and the detector fires on every frame during
    // a scroll. Recomputing only when the boolean flips keeps the callback
    // cheap.
    final isVisible = info.visibleFraction > 0.1;
    if (isVisible == _visible) return;
    _visible = isVisible;
    _syncGate();
  }

  @override
  void dispose() {
    _gate?.dispose();
    _shader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey<String>('shader-view-${widget.spec.id}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: ShaderPainter(
            shader: _shader,
            params: widget.params,
            clock: ShaderClock.of(context),
            resolutionScale: widget.resolutionScale,
            repaint: _gate,
          ),
        ),
      ),
    );
  }
}
