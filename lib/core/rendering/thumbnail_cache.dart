import 'dart:ui' as ui;
import 'dart:ui';

import '../../domain/entities/shader_params.dart';
import '../../domain/entities/shader_spec.dart';
import 'shader_program_cache.dart';

/// Offscreen renders of each shader, used by the Favorites screen.
///
/// Favorites must **not** run live shaders. Nobody stares at that list,
/// and six animating thumbnails on top of whatever the gallery is doing
/// is a waste of the raster budget. One still frame per shader, cached
/// for the app's lifetime, is enough.
///
/// The render time is fixed rather than passed as `clock.value` so every
/// thumbnail is deterministic — the same shader always produces the same
/// image, regardless of when the user favorited it.
abstract final class ThumbnailCache {
  static final Map<String, ui.Image> _images = <String, ui.Image>{};

  /// Synchronous peek for use in `build`. Returns `null` if the thumbnail
  /// hasn't been rendered yet, so the caller can show a placeholder.
  static ui.Image? peek(String id) => _images[id];

  /// Renders and caches a square thumbnail of [spec].
  ///
  /// Awaiting is safe — if two callers race for the same id, the second
  /// one overwrites the first with an identical image. The cost is one
  /// wasted render, not a correctness bug. [peek] first if you care.
  static Future<ui.Image> render({
    required ShaderSpec spec,
    required ShaderParams params,
    required double size,
    double time = 2.4,
  }) async {
    final cached = _images[spec.id];
    if (cached != null) return cached;

    final shader = ShaderProgramCache.program(spec.id).fragmentShader();

    shader.setFloat(0, size);
    shader.setFloat(1, size);
    shader.setFloat(2, time);
    shader.setFloat(3, params.speed);
    shader.setFloat(4, params.intensity);
    shader.setFloat(5, params.colorA.r);
    shader.setFloat(6, params.colorA.g);
    shader.setFloat(7, params.colorA.b);
    shader.setFloat(8, params.colorB.r);
    shader.setFloat(9, params.colorB.g);
    shader.setFloat(10, params.colorB.b);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(Rect.fromLTWH(0, 0, size, size), Paint()..shader = shader);

    final picture = recorder.endRecording();
    try {
      // `toImage` completes after the raster thread has consumed the
      // draw commands, so it's safe to dispose the shader once it does.
      final image = await picture.toImage(size.round(), size.round());
      _images[spec.id] = image;
      return image;
    } finally {
      picture.dispose();
      shader.dispose();
    }
  }

  /// Call when a shader's params change so the next [render] picks up
  /// the new colors. The Favorites screen peeks on every build, so
  /// evicting here is enough to force a re-render.
  static void evict(String id) {
    _images.remove(id)?.dispose();
  }

  static void clear() {
    for (final image in _images.values) {
      image.dispose();
    }
    _images.clear();
  }
}
