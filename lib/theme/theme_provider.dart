import 'package:flutter/material.dart';

class ThemeProvider {
  static const Color accentColor = Color(0xFFFF0014);
  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);
  static final Color _darkFocusColor = Colors.white.withOpacity(0.12);
  static ThemeData lightThemeData = themeData(lightColorScheme, _lightFocusColor);
  static ThemeData darkThemeData = themeData(darkColorScheme, _darkFocusColor);

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
        colorScheme: colorScheme,
        canvasColor: colorScheme.surfaceContainer,
        scaffoldBackgroundColor: colorScheme.surface,
        primaryColor: colorScheme.primary,
        highlightColor: Colors.transparent,
        cardColor: colorScheme.surfaceContainer,
        shadowColor: colorScheme.onSurface.withOpacity(0.1),
        dividerColor: colorScheme.onSurface.withOpacity(0.1),
        dialogBackgroundColor: colorScheme.surfaceContainer,
        textTheme: textTheme,
        iconTheme: IconThemeData(color: colorScheme.onSurface.withOpacity(0.5)),
        focusColor: focusColor);
  }

  static const ColorScheme lightColorScheme = ColorScheme(
    primary: ThemeProvider.accentColor,
    onPrimary: Colors.white,
    secondary: Colors.white,
    onSecondary: Colors.amber,
    surface: Colors.white,
    surfaceContainer: Color(0xFFFEFEFE),
    onSurface: Colors.black87,
    error: Colors.redAccent,
    onError: Colors.white,
    surfaceContainerHighest: Colors.white,
    brightness: Brightness.light,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    primary: ThemeProvider.accentColor,
    onPrimary: Color(0xFF111111),
    secondary: Color(0xFFEFF3F3),
    onSecondary: Colors.amber,
    surface: Color(0xFF111111),
    surfaceContainer: Color(0xFF171718),
    onSurface: Colors.white70,
    error: Colors.redAccent,
    onError: Colors.white,
    surfaceContainerHighest: Colors.white,
    brightness: Brightness.dark,
  );

  static TextTheme textTheme = const TextTheme(
      displayLarge: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(color: Colors.amber, fontSize: 25, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 14),
      titleSmall: TextStyle(fontSize: 12));
}
