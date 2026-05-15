import 'package:flutter/material.dart';

class AppTheme {
  static const Color f1Red = Color(0xFFE10600);
  static const Color darkBg = Color(0xFF0F0F0F);
  static const Color cardBg = Color(0xFF1C1C1C);
  static const Color surfaceColor = Color(0xFF2A2A2A);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: f1Red,
      scaffoldBackgroundColor: darkBg,
      colorScheme: ColorScheme.dark(
        primary: f1Red,
        surface: cardBg,
        surfaceContainerHighest: surfaceColor,
        onPrimary: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: f1Red,
        labelColor: f1Red,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 13),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2E2E2E)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF2E2E2E)),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: f1Red,
        labelStyle: const TextStyle(fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
