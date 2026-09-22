import 'dart:ui' as ui;

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/shader_spec.dart';

/// Compiles and holds the six [ui.FragmentProgram]s for the app's lifetime.
///
/// [ui.FragmentProgram] is the compiled artifact — one per shader, created
/// once. [ui.FragmentShader] is the per-tile instance that holds uniforms.
/// The distinction matters: calling `fromAsset` inside `build` recompiles
/// the shader on every frame and will tank the frame rate on device.
///
/// The raw GLSL is kept alongside each program so the export button can
/// put the exact source the app is running on the clipboard.
abstract final class ShaderProgramCache {
  static final Map<String, ui.FragmentProgram> _programs = {};
  static final Map<String, String> _sources = {};

  /// Loads every spec in [specs]. Awaited from `main()` before `runApp`.
  ///
  /// Fails loudly on the first bad shader rather than limping along with
  /// a partial gallery — a missing `.frag` almost always means the
  /// `flutter: shaders:` list is out of sync with the catalog, and you
  /// want to know that at boot, not when a user taps a black tile.
  static Future<void> warmUp(List<ShaderSpec> specs) async {
    for (final spec in specs) {
      try {
        final program = await ui.FragmentProgram.fromAsset(spec.assetPath);
        final source = await rootBundle.loadString(spec.assetPath);
        _programs[spec.id] = program;
        _sources[spec.id] = source;
      } catch (error, stackTrace) {
        throw ShaderLoadException(spec, error, stackTrace);
      }
    }
  }

  static bool isWarm(String id) => _programs.containsKey(id);

  static ui.FragmentProgram program(String id) {
    final program = _programs[id];
    if (program == null) {
      throw StateError(
        'Shader "$id" was not warmed up.\n'
        'Fix: call ShaderProgramCache.warmUp(kShaderCatalog) in main() '
        'before runApp().\n'
        'Also confirm "$id" is listed under `flutter: shaders:` in '
        'pubspec.yaml.',
      );
    }
    return program;
  }

  /// Raw GLSL for [id], or the empty string if it wasn't warmed.
  static String source(String id) => _sources[id] ?? '';
}

/// Wraps a shader load failure with the two facts you actually need:
/// which shader, and the most likely cause.
class ShaderLoadException implements Exception {
  final ShaderSpec spec;
  final Object cause;
  final StackTrace? stackTrace;

  ShaderLoadException(this.spec, this.cause, [this.stackTrace]);

  @override
  String toString() =>
      'ShaderLoadException: failed to load "${spec.id}" '
      'from "${spec.assetPath}".\n'
      'Most common cause: the .frag is missing from the '
      '`flutter: shaders:` list in pubspec.yaml.\n'
      'Underlying error: $cause';
}
