import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../domain/entities/shader_params.dart';

/// Paints one [ui.FragmentShader] over its full bounds.
///
/// Public rather than private so it can be widget-tested in isolation —
/// pump a painter with fixed params and assert it doesn't throw, without
/// standing up a full screen.
///
/// **The uniform slot contract below is fixed for every shader in the
/// catalog.** If you add a seventh shader, it uses these same 11 slots in
/// this same order. If you change the order here, you break all six at
/// once — and the failure mode is a black screen, which looks like a
/// math bug in the GLSL and sends you hunting in the wrong file.
class ShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final ShaderParams params;
  final ValueNotifier<double> clock;

  /// Shrinks the coordinate space the shader sees, so patterns render
  /// larger and softer. `1.0` is native. `0.6` is a good default for
  /// grid tiles. Values above `1.0` make patterns denser, which is rarely
  /// what you want.
  ///
  /// This does **not** reduce GPU work — the fragment count is fixed by
  /// the widget's physical size. It is a visual knob only.
  final double resolutionScale;

  ShaderPainter({
    required this.shader,
    required this.params,
    required this.clock,
    this.resolutionScale = 1.0,
    super.repaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final w = size.width / resolutionScale;
    final h = size.height / resolutionScale;

    // ── Uniform slots — do not reorder ────────────────────────────────
    //   0,1    vec2  uSize
    //   2      float uTime
    //   3      float uSpeed
    //   4      float uIntensity
    //   5,6,7  vec3  uColorA
    //   8,9,10 vec3  uColorB
    shader.setFloat(0, w);
    shader.setFloat(1, h);
    shader.setFloat(2, clock.value);
    shader.setFloat(3, params.speed);
    shader.setFloat(4, params.intensity);
    shader.setFloat(5, params.colorA.r);
    shader.setFloat(6, params.colorA.g);
    shader.setFloat(7, params.colorA.b);
    shader.setFloat(8, params.colorB.r);
    shader.setFloat(9, params.colorB.g);
    shader.setFloat(10, params.colorB.b);

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(ShaderPainter old) =>
      old.shader != shader ||
      old.params != params ||
      old.resolutionScale != resolutionScale ||
      old.clock != clock;
}
