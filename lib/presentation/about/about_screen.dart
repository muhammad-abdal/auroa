import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/design_tokens.dart';

/// The About tab. Text only, vertically centered.
///
/// No avatar, no logo, no "built with Flutter" badge. It's the one screen
/// in the app that isn't a shader, and adding chrome to it would dilute the
/// only thing it's selling: a person who writes original GLSL.
///
/// Replace [kAuthorName] and the two URLs below with your own. The links
/// copy to the clipboard rather than opening — that keeps `url_launcher`
/// out of the dependency list, and a recruiter pasting a URL into a browser
/// is a perfectly fine workflow.
const String kAuthorName = 'Abdal';
const String kRepoUrl = 'https://github.com/you/aurora';
const String kDemoUrl = 'https://aurora.example.com';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(T.s24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  kAuthorName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                    color: T.textPrimary,
                  ),
                ).animate().fadeIn(duration: const Duration(milliseconds: 400)),
                const SizedBox(height: T.s16),
                const Text(
                  'Six original fragment shaders, written in GLSL for '
                  'Flutter. Live on every screen, tuneable, exportable.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: T.textSecondary,
                  ),
                ),
                const SizedBox(height: T.s40),
                _LinkRow(label: 'Repository', url: kRepoUrl),
                const SizedBox(height: T.s12),
                _LinkRow(label: 'Live demo', url: kDemoUrl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final String label;
  final String url;

  const _LinkRow({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: url));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Copied $url')));
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: T.s8),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: T.textPrimary,
            decoration: TextDecoration.underline,
            decorationColor: T.divider,
          ),
        ),
      ),
    );
  }
}
