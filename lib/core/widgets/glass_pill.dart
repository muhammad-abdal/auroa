import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../theme/design_tokens.dart';

/// A frosted floating bar, used for the detail screen's action row.
///
/// The [ui.BackdropFilter] is the expensive part and it only works inside
/// a clip — an unclipped backdrop filter paints over the entire surface
/// behind it, which is both wrong and slow. The [ClipRRect] is load-bearing,
/// not decorative.
///
/// The blur is 20 sigma, tuned so a shader behind the pill is legible as
/// color but not as structure. Anything sharper fights the icons; anything
/// softer turns the pill into a solid rectangle.
class GlassPill extends StatelessWidget {
  final List<Widget> children;

  /// Horizontal padding between icons. The pill's outer padding is
  /// derived — [spacing] controls both the gap between children and the
  /// pill's own inset, so the shape stays balanced when you add a fourth
  /// action.
  final double spacing;

  const GlassPill({super.key, required this.children, this.spacing = T.s24});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(T.rPill),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: T.surface.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(T.rPill),
            border: Border.all(color: T.divider),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing, vertical: T.s12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) SizedBox(width: spacing),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
