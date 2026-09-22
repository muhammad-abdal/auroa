import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.dart';

/// A play/pause glyph that appears on tap, holds briefly, then fades.
///
/// Not a control — a confirmation. The gesture that toggles playback is a
/// tap anywhere on the shader; this only tells you which direction it went.
/// It never receives input and never blocks.
///
/// Timing: 100ms in, hold until the parent hides it, 200ms out. The
/// asymmetric fade is deliberate — you want instant feedback on the tap and
/// a slow release, so the glyph doesn't blink.
class PlaybackIndicator extends StatelessWidget {
  final bool paused;
  final bool visible;

  const PlaybackIndicator({
    super.key,
    required this.paused,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: visible
            ? const Duration(milliseconds: 100)
            : const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0x66000000),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(T.s16),
            child: Icon(
              paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              size: 36,
              color: T.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
