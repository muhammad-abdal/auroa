import 'package:flutter/widgets.dart';

/// The complete design vocabulary for Aurora.
///
/// Every value the UI uses lives here. No magic numbers in screen code —
/// if a color, radius, duration, or spacing appears more than once, it
/// belongs in this class.
abstract final class T {
  // ── Color ──────────────────────────────────────────────────────────
  //
  // There is deliberately no accent color. The shaders supply all color;
  // the UI is monochrome so it never competes with the artwork.

  static const bg = Color(0xFF08080A);
  static const surface = Color(0xFF141418);
  static const textPrimary = Color(0xEBFFFFFF); // 92%
  static const textSecondary = Color(0x8FFFFFFF); // 56%
  static const divider = Color(0x14FFFFFF); // 8%
  static const danger = Color(0xFFE5484D);

  // ── Radius ─────────────────────────────────────────────────────────

  static const rTile = 16.0;
  static const rSheet = 24.0;
  static const rPill = 999.0;

  // ── Spacing (4pt grid) ─────────────────────────────────────────────

  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s24 = 24.0;
  static const s40 = 40.0;

  // ── Motion ─────────────────────────────────────────────────────────

  static const fast = Duration(milliseconds: 200);
  static const hero = Duration(milliseconds: 320);
  static const ease = Curves.easeOutCubic;

  // ── Layout ─────────────────────────────────────────────────────────

  /// Caps the gallery and favorites grids on wide windows so tiles never
  /// stretch absurdly on a desktop monitor.
  static const maxContentWidth = 1100.0;

  /// Above this aspect ratio the detail screen letterboxes the shader.
  /// Full-bleed on a 32:9 ultrawide is nauseating.
  static const maxShaderAspect = 21 / 9;
}
