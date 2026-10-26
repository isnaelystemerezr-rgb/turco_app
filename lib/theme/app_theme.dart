import 'package:flutter/material.dart';

class AppTheme {
  static const Color seedColor = Color(0xFF00695C);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      primary: const Color(0xFF006A60),
      primaryContainer: const Color(0xFF9EF2E4),
      secondaryContainer: const Color(0xFFCCE8E2),
      tertiary: const Color(0xFF456179),
      error: const Color(0xFFBA1A1A),
      errorContainer: const Color(0xFFFFDAD6),
      surface: const Color(0xFFF4FBF9),
      surfaceContainer: const Color(0xFFE9EFED),
      outline: const Color(0xFF6F7977),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Poppins',
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        color: colorScheme.surfaceContainer, 
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      primary: const Color(0xFF53DBC9),
      primaryContainer: const Color(0xFF005047),
      secondaryContainer: const Color(0xFF314B47),
      tertiary: const Color(0xFFADCAE6),
      error: const Color(0xFFFFB4AB),
      errorContainer: const Color(0xFF93000A),
      surface: const Color(0xFF0E1514),
      surfaceContainer: const Color(0xFF1A2120),
      outline: const Color(0xFF899390),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Poppins',
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        color: colorScheme.surfaceContainer,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}