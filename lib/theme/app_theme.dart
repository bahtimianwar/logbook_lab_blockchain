import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const oranye = Color(0xFFF57C00);
  static const oranyeTua = Color(0xFFE65100);
  static const oranyeMuda = Color(0xFFFFF3E0);
  static const krem = Color(0xFFFFFBF7);
  static const hijau = Color(0xFF2E7D32);
  static const hijauMuda = Color(0xFFE8F5E9);
  static const garis = Color(0xFFF1E4D6);
  static const teks = Color(0xFF3E2723);

  static ThemeData get terang {
    final skema =
        ColorScheme.fromSeed(
          seedColor: oranye,
          brightness: Brightness.light,
        ).copyWith(
          primary: oranye,
          onPrimary: Colors.white,
          primaryContainer: oranyeMuda,
          onPrimaryContainer: oranyeTua,
          secondaryContainer: oranyeMuda,
          onSecondaryContainer: oranyeTua,
          tertiaryContainer: oranyeMuda,
          onTertiaryContainer: oranyeTua,
          surface: Colors.white,
          onSurface: teks,
          surfaceTint: Colors.transparent,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: skema,
      scaffoldBackgroundColor: krem,
      appBarTheme: const AppBarTheme(
        backgroundColor: oranye,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: oranyeMuda,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? oranyeTua
                : Colors.grey.shade600,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: s.contains(WidgetState.selected)
                ? oranyeTua
                : Colors.grey.shade600,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: oranye,
        foregroundColor: Colors.white,
      ),
      chipTheme: ChipThemeData(
        selectedColor: oranyeMuda,
        checkmarkColor: oranyeTua,
        side: const BorderSide(color: garis),
      ),
    );
  }
}
