import 'dart:ui' show Color;

import 'entities/shader_params.dart';
import 'entities/shader_spec.dart';

/// The six shaders in the gallery, in display order.
///
/// Adding a seventh means editing exactly three files: the new `.frag`,
/// `pubspec.yaml`, and this list. If it means touching anything else,
/// the uniform contract has been broken.
const kShaderCatalog = <ShaderSpec>[
  ShaderSpec(
    id: 'aurora',
    name: 'Aurora',
    assetPath: 'shaders/aurora.frag',
    defaults: ShaderParams(
      speed: 1.0,
      intensity: 0.85,
      colorA: Color(0xFF2DD4BF),
      colorB: Color(0xFF7C3AED),
    ),
  ),
  ShaderSpec(
    id: 'nebula',
    name: 'Nebula',
    assetPath: 'shaders/nebula.frag',
    defaults: ShaderParams(
      speed: 0.6,
      intensity: 0.90,
      colorA: Color(0xFF6366F1),
      colorB: Color(0xFFEC4899),
    ),
  ),
  ShaderSpec(
    id: 'plasma',
    name: 'Plasma',
    assetPath: 'shaders/plasma.frag',
    defaults: ShaderParams(
      speed: 1.4,
      intensity: 0.70,
      colorA: Color(0xFFF59E0B),
      colorB: Color(0xFFEF4444),
    ),
  ),
  ShaderSpec(
    id: 'ripple',
    name: 'Ripple',
    assetPath: 'shaders/ripple.frag',
    defaults: ShaderParams(
      speed: 1.2,
      intensity: 0.75,
      colorA: Color(0xFF06B6D4),
      colorB: Color(0xFF3B82F6),
    ),
  ),
  ShaderSpec(
    id: 'ember',
    name: 'Ember',
    assetPath: 'shaders/ember.frag',
    defaults: ShaderParams(
      speed: 1.0,
      intensity: 0.90,
      colorA: Color(0xFF1C1917),
      colorB: Color(0xFFF97316),
    ),
  ),
  ShaderSpec(
    id: 'prism',
    name: 'Prism',
    assetPath: 'shaders/prism.frag',
    defaults: ShaderParams(
      speed: 0.8,
      intensity: 0.80,
      colorA: Color(0xFF10B981),
      colorB: Color(0xFF8B5CF6),
    ),
  ),
];

/// Convenience lookup. Returns `null` for an unknown id rather than
/// throwing, so a stale favorite in Hive can't crash the app.
ShaderSpec? shaderById(String id) {
  for (final spec in kShaderCatalog) {
    if (spec.id == id) return spec;
  }
  return null;
}
