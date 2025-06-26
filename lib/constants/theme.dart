import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color primaryLightColor = Color(0xFF3B82F6);
  static const Color primaryDarkColor = Color(0xFF1D4ED8);
  static const Color secondaryColor = Color(0xFF64748B);
  static const Color accentColor = Color(0xFF10B981);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
  static const Color textPrimaryColor = Color(0xFF1E293B);
  static const Color textSecondaryColor = Color(0xFF64748B);
  static const Color textLightColor = Color(0xFF94A3B8);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color shadowColor = Color(0x1A000000);

  // Text Styles
  static TextStyle get heading1 => GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static TextStyle get heading2 => GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static TextStyle get heading3 => GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static TextStyle get heading4 => GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static TextStyle get bodyLarge => GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
  );

  static TextStyle get bodyMedium => GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
  );

  static TextStyle get bodySmall => GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
  );

  static TextStyle get buttonText => GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: surfaceColor,
  );

  static TextStyle get caption => GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textLightColor,
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      fontFamily: GoogleFonts.montserrat().fontFamily,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 2,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: surfaceColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: buttonText.copyWith(color: primaryColor),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        labelStyle: bodyMedium.copyWith(color: textSecondaryColor),
        hintStyle: bodyMedium.copyWith(color: textLightColor),
      ),
      dividerTheme: const DividerThemeData(color: borderColor, thickness: 1),
    );
  }

  // Spacing
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXL = 32;
  static const double spacingXXL = 48;

  // Border Radius
  static const double radiusS = 4;
  static const double radiusM = 8;
  static const double radiusL = 12;
  static const double radiusXL = 16;
  static const double radiusXXL = 24;

  // Shadows
  static List<BoxShadow> get shadowSmall => [
    BoxShadow(color: shadowColor, blurRadius: 4, offset: const Offset(0, 2)),
  ];

  static List<BoxShadow> get shadowMedium => [
    BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> get shadowLarge => [
    BoxShadow(color: shadowColor, blurRadius: 16, offset: const Offset(0, 8)),
  ];
}
