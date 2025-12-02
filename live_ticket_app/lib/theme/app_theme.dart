import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const backgroundColor = Color(0xFFFAFAFA); // grey[50]
  static const textColor = Color(0xFF212121); // grey[900]
  static const cardColor = Color(0xFFF5F5F5); // grey[100]
  static const primaryBlue = Color(0xFF1565C0); // 濃いめの青
  static const primaryBlueDark = Color(0xFF0D47A1);
  
  // Gradients
  static const blackGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF424242),
      Color(0xFF212121),
      Color(0xFF000000),
    ],
  );

  static const blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1976D2),
      Color(0xFF1565C0),
      Color(0xFF0D47A1),
    ],
  );

  // Spacing
  static const double paddingDefault = 16.0;
  static const double paddingSmall = 8.0;
  static const double paddingLarge = 24.0;

  // Text Sizes
  static const double textSizeLarge = 28.0;
  static const double textSizeNormal = 14.0;

  // Button
  static const double buttonHeight = 48.0;
  static const double buttonRadius = 12.0;

  // ThemeData
  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryBlueDark,
        surface: backgroundColor,
        onSurface: textColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.notoSansJpTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.notoSansJp(
          fontSize: textSizeLarge,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        bodyMedium: GoogleFonts.notoSansJp(
          fontSize: textSizeNormal,
          color: textColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.notoSansJp(
            fontSize: textSizeNormal,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}