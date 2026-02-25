import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF0B1C24);
  static const Color green = Color(0xFF8BCF00);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF9E9E9E);
  static const Color cardBg = Color(0xFF142530);
  static const Color borderColor = Color(0xFF2A3F4D);
}

class AppTextStyles {
  static TextStyle get heading => GoogleFonts.poppins(
        color: AppColors.white,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get subheading => GoogleFonts.poppins(
        color: AppColors.white,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get body => GoogleFonts.poppins(
        color: AppColors.grey,
        fontSize: 14,
        height: 1.5,
      );

  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.green,
          surface: AppColors.background,
        ),
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: AppColors.white,
          displayColor: AppColors.white,
        ),
        useMaterial3: true,
      );
}
