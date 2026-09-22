import 'package:flutter/widgets.dart';

import '../theme/design_tokens.dart';

/// A row of color swatches, one selected.
///
/// Six fixed swatches rather than a full color picker. This is a design
/// decision, not a shortcut: a picker lets users make ugly shaders, and
/// the whole app is a portfolio piece where every screen needs to look
/// good in a screenshot. Curating the palette keeps the gallery coherent.
///
/// The selected swatch is marked with a ring rather than a checkmark —
/// a checkmark on a saturated color is illegible, and at 28pt the ring
/// reads at a glance.
class ColorSwatchPicker extends StatelessWidget {
  final List<Color> swatches;
  final Color selected;
  final ValueChanged<Color> onChanged;

  /// Swatch diameter. The ring sits [ringGap] outside this, so the tap
  /// target is `diameter + 2 * (ringWidth + ringGap)`.
  final double diameter;

  static const double ringWidth = 2.0;
  static const double ringGap = 3.0;

  const ColorSwatchPicker({
    super.key,
    required this.swatches,
    required this.selected,
    required this.onChanged,
    this.diameter = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final color in swatches)
          Padding(
            padding: const EdgeInsets.only(right: T.s12),
            child: _Swatch(
              color: color,
              selected: color.toARGB32() == selected.toARGB32(),
              diameter: diameter,
              onTap: () => onChanged(color),
            ),
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final double diameter;
  final VoidCallback onTap;

  const _Swatch({
    required this.color,
    required this.selected,
    required this.diameter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final outer =
        diameter +
        2 * (ColorSwatchPicker.ringWidth + ColorSwatchPicker.ringGap);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: outer,
        height: outer,
        child: Center(
          child: Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(
                      color: T.textPrimary,
                      width: ColorSwatchPicker.ringWidth,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
