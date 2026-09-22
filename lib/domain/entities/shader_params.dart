import 'dart:ui' show Color, lerpDouble;

import 'package:flutter/foundation.dart';

/// The user-tunable inputs for a single shader.
///
/// Immutable, value-equal, and free of any persistence or rendering
/// concern. Serialization lives in `infrastructure/storage`; uniform
/// binding lives in `infrastructure/rendering`.
///
/// Range constants match the Customize sliders exactly. Changing them
/// here changes the sliders, and vice versa — there is one source of truth.
@immutable
class ShaderParams {
  final double speed;
  final double intensity;
  final Color colorA;
  final Color colorB;

  const ShaderParams({
    this.speed = 1.0,
    this.intensity = 0.8,
    this.colorA = const Color(0xFF3B82F6),
    this.colorB = const Color(0xFFA855F7),
  });

  static const double speedMin = 0.2;
  static const double speedMax = 3.0;
  static const double intensityMin = 0.0;
  static const double intensityMax = 1.0;

  ShaderParams copyWith({
    double? speed,
    double? intensity,
    Color? colorA,
    Color? colorB,
  }) => ShaderParams(
    speed: speed ?? this.speed,
    intensity: intensity ?? this.intensity,
    colorA: colorA ?? this.colorA,
    colorB: colorB ?? this.colorB,
  );

  /// Used to animate a Reset back to defaults without a jarring snap.
  ShaderParams lerpTo(ShaderParams other, double t) => ShaderParams(
    speed: lerpDouble(speed, other.speed, t)!,
    intensity: lerpDouble(intensity, other.intensity, t)!,
    colorA: Color.lerp(colorA, other.colorA, t)!,
    colorB: Color.lerp(colorB, other.colorB, t)!,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShaderParams &&
          other.speed == speed &&
          other.intensity == intensity &&
          other.colorA == colorA &&
          other.colorB == colorB;

  @override
  int get hashCode => Object.hash(speed, intensity, colorA, colorB);

  @override
  String toString() =>
      'ShaderParams(speed: $speed, intensity: $intensity, '
      'colorA: $colorA, colorB: $colorB)';
}
