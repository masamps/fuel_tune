import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static const _accent = Color(0xFF0A84FF);
  static const _mint = Color(0xFF30D158);
  static const _amber = Color(0xFFFF9F0A);
  static const _lightBackground = Color(0xFFF5F5F7);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _darkBackground = Color(0xFF111214);
  static const _darkSurface = Color(0xFF1C1C1E);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: Brightness.light,
      surface: _lightSurface,
    ).copyWith(primary: _accent, tertiary: _mint);

    final textTheme = _buildTextTheme(Brightness.light);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightBackground,
      textTheme: textTheme,
      cupertinoOverrideTheme: _buildCupertinoTheme(
        brightness: Brightness.light,
        colorScheme: colorScheme,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: _lightBackground,
        foregroundColor: Colors.black,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: _lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black.withValues(alpha: 0.88),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: Brightness.dark,
      surface: _darkSurface,
    ).copyWith(primary: _accent, tertiary: _amber);

    final textTheme = _buildTextTheme(Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkBackground,
      textTheme: textTheme,
      cupertinoOverrideTheme: _buildCupertinoTheme(
        brightness: Brightness.dark,
        colorScheme: colorScheme,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: _darkBackground,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: _darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _darkSurface,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final base = ThemeData(brightness: brightness).textTheme;
    final isDark = brightness == Brightness.dark;

    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 38,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: isDark ? Colors.white : Colors.black,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: isDark ? Colors.white : Colors.black,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: isDark ? Colors.white : Colors.black,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: isDark ? Colors.white : Colors.black,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.35,
        color: isDark ? Colors.white : Colors.black,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 15,
        height: 1.35,
        color: isDark ? Colors.white : Colors.black,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 13,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: isDark ? Colors.white60 : Colors.black45,
      ),
    );
  }

  static NoDefaultCupertinoThemeData _buildCupertinoTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
  }) {
    final isDark = brightness == Brightness.dark;

    return NoDefaultCupertinoThemeData(
      brightness: brightness,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: isDark ? _darkBackground : _lightBackground,
      barBackgroundColor: isDark
          ? _darkSurface.withValues(alpha: 0.88)
          : _lightSurface.withValues(alpha: 0.88),
      textTheme: CupertinoTextThemeData(
        primaryColor: colorScheme.primary,
        textStyle: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black,
        ),
        navTitleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
