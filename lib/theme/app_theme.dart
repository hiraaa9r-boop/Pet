import 'package:flutter/material.dart';

class AppBrand {
  static const supportEmail = 'petcareassistenza@gmail.com';

  static const Color primary = Color(0xFF0F6259);
  static const Color background = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF333333);

  static const double borderRadius = 12.0;
  static const double spacingXS = 8.0;
  static const double spacingS = 12.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: AppBrand.primary,
        secondary: AppBrand.primary,
        surface: AppBrand.background,
        onPrimary: Colors.white,
        onSurface: AppBrand.textPrimary,
      ),
      scaffoldBackgroundColor: AppBrand.background,
      primaryColor: AppBrand.primary,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppBrand.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      textTheme: _textTheme(base.textTheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppBrand.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBrand.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppBrand.spacingL,
            vertical: AppBrand.spacingS,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBrand.borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBrand.borderRadius),
          borderSide: const BorderSide(color: AppBrand.primary, width: 2),
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      // Titoli Poppins Bold
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
        color: AppBrand.textPrimary,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
        color: AppBrand.textPrimary,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
        color: AppBrand.textPrimary,
      ),
      // Testo Inter Regular
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        color: AppBrand.textSecondary,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        color: AppBrand.textSecondary,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        color: AppBrand.textPrimary,
      ),
    );
  }
}
