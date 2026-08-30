import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0E0E12);
  static const surface = Color(0xFF17171D);
  static const surfaceElevated = Color(0xFF1F1F27);
  static const accent = Color(0xFFF5C24D);
  static const accentSoft = Color(0xFF3A3320);
  static const textPrimary = Color(0xFFF5F5F7);
  static const textSecondary = Color(0xFF9A9AA5);
  static const textFaint = Color(0xFF5C5C66);
  static const divider = Color(0xFF232329);
}

class AppRadii {
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const pill = 999.0;
}

class AppText {
  static const screenTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
  static const sectionLabel = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
  );
  static const trackTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
  static const trackArtist = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );
}


class ApiConstants {
  static const String BASE_URL = 'https://api.jamendo.com/v3.0';
}