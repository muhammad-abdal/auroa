import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// A slider with its label above and its formatted value to the right.
///
/// The value is right-aligned rather than adjacent to the label so the
/// numbers form a column down the panel — much easier to scan three
/// sliders at once. [format] is responsible for units; passing `(v) =>
/// '${v.toStringAsFixed(1)}×'` for speed and `(v) => v.toStringAsFixed(2)`
/// for intensity is the convention.
///
/// Deliberately not a `FormField`. Nothing here validates, nothing
/// submits, and a `GlobalKey<FormFieldState>` per slider is state you'd
/// have to thread through the customize controller for no benefit.
class LabeledSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final String Function(double) format;

  const LabeledSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.format,
    this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: T.textPrimary,
                ),
              ),
            ),
            Text(
              format(value),
              style: const TextStyle(
                fontSize: 13,
                fontFeatures: [FontFeature.tabularFigures()],
                color: T.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: T.s4),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
      ],
    );
  }
}
