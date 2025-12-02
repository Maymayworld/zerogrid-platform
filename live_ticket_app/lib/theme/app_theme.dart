import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors - 株丹さんのデザインに準拠
  static const darkBackground = Color(0xFF1E1B4B); // ダークネイビー
  static const cardBackground = Color(0xFF2D2A5E); // 青紫
  static const accentCyan = Color(0xFF00D9FF); // シアン（メインアクセント）
  static const accentCyanDark = Color(0xFF00B8D4); // シアン（濃いめ）
  static const textColorDark = Color(0xFFFFFFFF); // 白
  static const textColorLight = Color(0xFF9CA3AF); // グレー
  
  // Light Theme Colors (QR画面用)
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightTextColor = Color(0xFF1F2937);
  
  // Gradients
  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B3878),
      Color(0xFF2D2A5E),
      Color(0xFF1E1B4B),
    ],
  );

  static const cyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00E5FF),
      Color(0xFF00D9FF),
      Color(0xFF00B8D4),
    ],
  );

  // Spacing
  static const double paddingDefault = 16.0;
  static const double paddingSmall = 8.0;
  static const double paddingLarge = 24.0;

  // Text Sizes
  static const double textSizeLarge = 24.0;
  static const double textSizeNormal = 14.0;
  static const double textSizeSmall = 12.0;

  // Button
  static const double buttonHeight = 56.0;
  static const double buttonRadius = 12.0;

  // Card
  static const double cardRadius = 16.0;

  // ThemeData for Dark Theme
  static ThemeData get darkTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: accentCyan,
        secondary: accentCyanDark,
        surface: darkBackground,
        onSurface: textColorDark,
      ),
      scaffoldBackgroundColor: darkBackground,
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.notoSansJpTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.notoSansJp(
          fontSize: textSizeLarge,
          fontWeight: FontWeight.bold,
          color: textColorDark,
        ),
        bodyMedium: GoogleFonts.notoSansJp(
          fontSize: textSizeNormal,
          color: textColorDark,
        ),
        bodySmall: GoogleFonts.notoSansJp(
          fontSize: textSizeSmall,
          color: textColorLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          backgroundColor: accentCyan,
          foregroundColor: darkBackground,
          textStyle: GoogleFonts.notoSansJp(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ThemeData for Light Theme (QR画面用)
  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: accentCyan,
        secondary: accentCyanDark,
        surface: lightBackground,
        onSurface: lightTextColor,
      ),
      scaffoldBackgroundColor: lightBackground,
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.notoSansJpTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.notoSansJp(
          fontSize: textSizeLarge,
          fontWeight: FontWeight.bold,
          color: lightTextColor,
        ),
        bodyMedium: GoogleFonts.notoSansJp(
          fontSize: textSizeNormal,
          color: lightTextColor,
        ),
      ),
    );
  }
}