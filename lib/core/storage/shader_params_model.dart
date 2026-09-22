import 'dart:ui' show Color;

import '../../domain/entities/shader_params.dart';

/// Maps [ShaderParams] to and from the plain `Map` shape Hive stores.
///
/// This exists as a separate class rather than `toJson`/`fromJson` methods
/// on the entity so the domain layer never learns about persistence.
/// Color is stored as a 32-bit int (`toARGB32`) rather than a string so a
/// future migration to a different store doesn't need a parser.
abstract final class ShaderParamsModel {
  static Map<String, Object> toMap(ShaderParams params) => <String, Object>{
    'speed': params.speed,
    'intensity': params.intensity,
    'colorA': params.colorA.toARGB32(),
    'colorB': params.colorB.toARGB32(),
  };

  /// Returns `null` for anything that doesn't match the expected shape.
  ///
  /// Callers fall back to [ShaderSpec.defaults]. This matters because a
  /// Hive box written by an older build can outlive a schema change, and
  /// a gallery that crashes on a stale key is worse than one that quietly
  /// resets a slider.
  static ShaderParams? tryFromMap(Map<dynamic, dynamic> map) {
    final speed = map['speed'];
    final intensity = map['intensity'];
    final colorA = map['colorA'];
    final colorB = map['colorB'];

    if (speed is! num ||
        intensity is! num ||
        colorA is! int ||
        colorB is! int) {
      return null;
    }

    return ShaderParams(
      speed: speed.toDouble().clamp(
        ShaderParams.speedMin,
        ShaderParams.speedMax,
      ),
      intensity: intensity.toDouble().clamp(
        ShaderParams.intensityMin,
        ShaderParams.intensityMax,
      ),
      colorA: Color(colorA),
      colorB: Color(colorB),
    );
  }
}
