import 'package:flutter/material.dart';

// class AppColors {
//   static const Color primary = Color(0xFF4CAF50);
//   static const Color secondary = Color(0xFF2196F3);
//   static const Color accent = Color(0xFFFF9800);
//   static const Color error = Color(0xFFF44336);
//   static const Color success = Color(0xFF4CAF50);
//   static const Color warning = Color(0xFFFF9800);
//   static const Color background = Color(0xFFF5F5F5);
//   static const Color surface = Colors.white;
//   static const Color textPrimary = Color(0xFF212121);
//   static const Color textSecondary = Color(0xFF757575);
//   static const Color divider = Color(0xFFBDBDBD);
// }
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);
  
  // Accent colors
  static const Color accent = Color(0xFFFF9800);
  static const Color accentDark = Color(0xFFF57C00);
  static const Color accentLight = Color(0xFFFFB74D);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Ride status colors
  static const Color ridePending = Color(0xFFFF9800);
  static const Color rideAccepted = Color(0xFF03A9F4);
  static const Color rideStarted = Color(0xFF4CAF50);
  static const Color rideCompleted = Color(0xFF8BC34A);
  static const Color rideCancelled = Color(0xFFF44336);
  
  // Location colors
  static const Color pickupColor = Color(0xFF4CAF50);
  static const Color dropoffColor = Color(0xFFF44336);
  static const Color routeColor = Color(0xFF2196F3);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Background colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);
  
  // Card colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1F000000);
  
  // Rating colors
  static const Color ratingGold = Color(0xFFFFD700);
  static const Color ratingEmpty = Color(0xFFE0E0E0);
  
  // Driver/Rider specific
  static const Color driverOnline = Color(0xFF4CAF50);
  static const Color driverOffline = Color(0xFF9E9E9E);
  static const Color riderActive = Color(0xFF2196F3);
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}