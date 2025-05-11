import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFFEC4899);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color lightCardBackground = Color(0xFFF8FAFC);
  static const Color darkCardBackground = Color(0xFF1E293B);
  static const Color lightTextColor = Color(0xFF1E293B);
  static const Color darkTextColor = Color(0xFFF8FAFC);
  static const Color lightTextSecondaryColor = Color(0xFF64748B);
  static const Color darkTextSecondaryColor = Color(0xFF94A3B8);
  static const Color lightBorderColor = Color(0xFFE2E8F0);
  static const Color darkBorderColor = Color(0xFF334155);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);

  static ThemeData get lightTheme => ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: lightBackground,
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          secondary: accentColor,
          background: lightBackground,
          surface: lightCardBackground,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: lightTextColor,
          onSurface: lightTextColor,
          error: errorColor,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: lightBackground,
          foregroundColor: lightTextColor,
          elevation: 0,
        ),
        cardTheme: const CardTheme(
          color: lightCardBackground,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: lightTextColor, fontSize: 26),
          displayMedium: TextStyle(color: lightTextColor, fontSize: 24),
          displaySmall: TextStyle(color: lightTextColor, fontSize: 22),
          headlineLarge: TextStyle(color: lightTextColor, fontSize: 20),
          headlineMedium: TextStyle(color: lightTextColor, fontSize: 18),
          headlineSmall: TextStyle(color: lightTextColor, fontSize: 16),
          titleLarge: TextStyle(color: lightTextColor, fontSize: 18),
          titleMedium: TextStyle(color: lightTextColor, fontSize: 16),
          titleSmall: TextStyle(color: lightTextColor, fontSize: 14),
          bodyLarge: TextStyle(color: lightTextColor, fontSize: 16),
          bodyMedium: TextStyle(color: lightTextColor, fontSize: 14),
          bodySmall: TextStyle(color: lightTextSecondaryColor, fontSize: 12),
          labelLarge: TextStyle(color: lightTextColor, fontSize: 14),
          labelMedium: TextStyle(color: lightTextColor, fontSize: 12),
          labelSmall: TextStyle(color: lightTextColor, fontSize: 11),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightCardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: lightBorderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: lightBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: primaryColor,
          secondary: accentColor,
          background: darkBackground,
          surface: darkCardBackground,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: darkTextColor,
          onSurface: darkTextColor,
          error: errorColor,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBackground,
          foregroundColor: darkTextColor,
          elevation: 0,
        ),
        cardTheme: const CardTheme(
          color: darkCardBackground,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: darkTextColor, fontSize: 26),
          displayMedium: TextStyle(color: darkTextColor, fontSize: 24),
          displaySmall: TextStyle(color: darkTextColor, fontSize: 22),
          headlineLarge: TextStyle(color: darkTextColor, fontSize: 20),
          headlineMedium: TextStyle(color: darkTextColor, fontSize: 18),
          headlineSmall: TextStyle(color: darkTextColor, fontSize: 16),
          titleLarge: TextStyle(color: darkTextColor, fontSize: 18),
          titleMedium: TextStyle(color: darkTextColor, fontSize: 16),
          titleSmall: TextStyle(color: darkTextColor, fontSize: 14),
          bodyLarge: TextStyle(color: darkTextColor, fontSize: 16),
          bodyMedium: TextStyle(color: darkTextColor, fontSize: 14),
          bodySmall: TextStyle(color: darkTextSecondaryColor, fontSize: 12),
          labelLarge: TextStyle(color: darkTextColor, fontSize: 14),
          labelMedium: TextStyle(color: darkTextColor, fontSize: 12),
          labelSmall: TextStyle(color: darkTextColor, fontSize: 11),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkCardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: darkBorderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: darkBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      );
}
