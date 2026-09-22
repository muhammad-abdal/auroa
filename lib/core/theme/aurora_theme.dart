import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// Dark-only theme. Aurora is a gallery for luminous artwork; a light mode
/// would fight the shaders for attention.
abstract final class AuroraTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: T.bg,
      colorScheme: base.colorScheme.copyWith(
        surface: T.surface,
        primary: Colors.white,
        onPrimary: Colors.black,
      ),
      // No ripples. The tiles are the interactive surface; a Material
      // splash on top of an animated shader is visual noise.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: T.divider,

      textTheme: base.textTheme.apply(
        bodyColor: T.textPrimary,
        displayColor: T.textPrimary,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: T.bg,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? T.textPrimary
                : T.textSecondary,
          ),
        ),
      ),

      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: T.bg,
        indicatorColor: Colors.transparent,
        selectedIconTheme: IconThemeData(color: T.textPrimary, size: 22),
        unselectedIconTheme: IconThemeData(color: T.textSecondary, size: 22),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: T.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(T.rSheet)),
        ),
      ),

      sliderTheme: const SliderThemeData(
        trackHeight: 3,
        activeTrackColor: T.textPrimary,
        inactiveTrackColor: T.divider,
        thumbColor: T.textPrimary,
        overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 9),
      ),

      snackBarTheme: const SnackBarThemeData(
        backgroundColor: T.surface,
        contentTextStyle: TextStyle(color: T.textPrimary, fontSize: 14),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
