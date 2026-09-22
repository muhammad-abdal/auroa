import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/widgets/color_swatch_picker.dart';
import '../../core/widgets/labeled_slider.dart';
import '../../domain/entities/shader_params.dart';
import '../../domain/entities/shader_spec.dart';
import 'customize_controller.dart';

/// The bottom sheet for tuning a shader's params.
///
/// The sheet is a [DraggableScrollableSheet] rather than a fixed-height
/// modal so it survives a bumped `textScaleFactor` — at 1.5 the three rows
/// plus the header overflow a fixed 42% sheet, and the inner scroll view
/// is what prevents a yellow-and-black stripe.
///
/// It watches its [CustomizeController] rather than holding any state
/// itself. Every slider tick calls a controller setter, which notifies,
/// which rebuilds the sliders, which repaints the shader behind the sheet.
class CustomizeSheet extends StatelessWidget {
  final ShaderSpec spec;
  final CustomizeController controller;

  /// Six curated swatches per color slot. A full picker would let users
  /// make shaders that look bad, and this is a gallery where every
  /// screenshot is marketing.
  static const List<Color> _swatches = <Color>[
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFFF97316),
    Color(0xFF10B981),
    Color(0xFF06B6D4),
  ];

  const CustomizeSheet({
    super.key,
    required this.spec,
    required this.controller,
  });

  static Future<void> show({
    required BuildContext context,
    required ShaderSpec spec,
    required CustomizeController controller,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomizeSheet(spec: spec, controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.42,
      minChildSize: 0.28,
      maxChildSize: 0.70,
      expand: false,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: T.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(T.rSheet)),
          ),
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(T.s24, T.s12, T.s24, T.s24),
              children: <Widget>[
                const _Handle(),
                const SizedBox(height: T.s16),
                _Header(title: spec.name, onReset: controller.reset),
                const SizedBox(height: T.s24),
                LabeledSlider(
                  label: 'Speed',
                  value: controller.params.speed,
                  min: ShaderParams.speedMin,
                  max: ShaderParams.speedMax,
                  format: (v) => '${v.toStringAsFixed(1)}×',
                  onChanged: controller.setSpeed,
                ),
                const SizedBox(height: T.s16),
                LabeledSlider(
                  label: 'Intensity',
                  value: controller.params.intensity,
                  min: ShaderParams.intensityMin,
                  max: ShaderParams.intensityMax,
                  format: (v) => v.toStringAsFixed(2),
                  onChanged: controller.setIntensity,
                ),
                const SizedBox(height: T.s24),
                const _SectionLabel('Primary color'),
                const SizedBox(height: T.s8),
                ColorSwatchPicker(
                  swatches: _swatches,
                  selected: controller.params.colorA,
                  onChanged: controller.setColorA,
                ),
                const SizedBox(height: T.s24),
                const _SectionLabel('Secondary color'),
                const SizedBox(height: T.s8),
                ColorSwatchPicker(
                  swatches: _swatches,
                  selected: controller.params.colorB,
                  onChanged: controller.setColorB,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: T.textSecondary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onReset;

  const _Header({required this.title, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'Customize $title',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: T.textPrimary,
            ),
          ),
        ),
        GestureDetector(
          onTap: onReset,
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.all(T.s8),
            child: Text(
              'Reset',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: T.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w500,
        color: T.textSecondary,
      ),
    );
  }
}
