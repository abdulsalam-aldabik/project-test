import 'package:flutter/material.dart';

/// App color palette for the luxury dashboard
class AppColors {
  // Primary colors
  static const Color primaryDark = Color(0xFF0A101D);
  static const Color primaryMedium = Color(0xFF1A2234);
  static const Color primaryLight = Color(0xFF2A3244);
  
  // Accent colors
  static const Color accentPrimary = Color(0xFF4764F0);
  static const Color accentSecondary = Color(0xFF05D7CC);
  static const Color accentTertiary = Color(0xFFF05C4D);
  
  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF232B3E),
    Color(0xFF0A101D),
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFF4764F0),
    Color(0xFF05D7CC),
  ];
  
  // Status colors
  static const Color success = Color(0xFF2AD182);
  static const Color warning = Color(0xFFFFD166);
  static const Color error = Color(0xFFEF476F);
  static const Color info = Color(0xFF118AB2);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB4B7BE);
  static const Color textDisabled = Color(0xFF6C7587);
  
  // Card colors
  static const Color cardBackground = Color(0xFF1A2234);
  static const Color cardBorder = Color(0xFF2A3244);
  
  // Misc
  static const Color divider = Color(0xFF2A3244);
  static const Color shadow = Color(0xFF070D1A);
} 