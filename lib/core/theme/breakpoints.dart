import 'dart:ui' show Size;

/// The three window classes the app adapts to.
///
/// Thresholds are Material 3's window size classes — they're where the
/// layouts actually change behavior, not arbitrary numbers.
enum ShellLayout { compact, medium, expanded }

const double kCompactMax = 600; // phones, narrow windows
const double kMediumMax = 1024; // large phones, small tablets

ShellLayout layoutFor(Size size) {
  if (size.width >= kMediumMax) return ShellLayout.expanded;
  if (size.width >= kCompactMax) return ShellLayout.medium;
  return ShellLayout.compact;
}

/// Per-layout values for the gallery grid.
///
/// [tileResolution] is the important one. A full-resolution fragment shader
/// on a 12.9" tablet at 5 columns is 5× the fragment count of a phone at
/// 2 columns; dropping to 0.70 keeps GPU cost roughly flat across devices.
extension ShellLayoutX on ShellLayout {
  bool get isExpanded => this == ShellLayout.expanded;
  bool get isCompact => this == ShellLayout.compact;

  int get gridColumns => switch (this) {
    ShellLayout.compact => 2,
    ShellLayout.medium => 3,
    ShellLayout.expanded => 5,
  };

  double get tileResolution => switch (this) {
    ShellLayout.compact => 0.60,
    ShellLayout.medium => 0.65,
    ShellLayout.expanded => 0.70,
  };

  double get gridGutter => switch (this) {
    ShellLayout.compact => 12,
    ShellLayout.medium => 16,
    ShellLayout.expanded => 20,
  };
}
