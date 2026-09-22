import 'package:flutter/foundation.dart';

import 'shader_params.dart';

/// An immutable description of one shader in the gallery.
///
/// [defaults] seeds the Customize panel and is what Reset restores.
///
/// Every shader shares the same 11-slot uniform layout, documented in
/// `infrastructure/rendering/shader_view.dart`. There is deliberately no
/// per-shader slot map — the fixed contract is what lets you add a shader
/// by touching three files instead of six.
@immutable
class ShaderSpec {
  /// Stable identifier. Used as the Hive key, the asset filename stem,
  /// the Hero tag suffix, and the ThumbnailCache key. Never localize it.
  final String id;

  /// Display name shown in the detail header and the favorites list.
  final String name;

  /// Path relative to the repo root, matching the `flutter: shaders:` entry.
  final String assetPath;

  final ShaderParams defaults;

  const ShaderSpec({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.defaults,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ShaderSpec && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
