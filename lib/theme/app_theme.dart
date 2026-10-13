import 'package:flutter/material.dart';

/// Konfigurasi tema aplikasi kuis.
///
/// Cara pakai di main.dart:
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
///   themeMode: ThemeMode.system, // otomatis ikut setting perangkat
///
/// ─────────────────────────────────────────────────────────────────────────
/// PANDUAN FONT KUSTOM
/// ─────────────────────────────────────────────────────────────────────────
/// 1. Unduh font (contoh: Poppins) dari https://fonts.google.com
/// 2. Simpan file .ttf ke folder  fonts/  di root proyek:
///       fonts/Poppins-Regular.ttf
///       fonts/Poppins-Bold.ttf
///       fonts/Poppins-Italic.ttf
///
/// 3. Daftarkan di pubspec.yaml (indentasi 2 spasi, WAJIB tepat):
///
///   flutter:
///     fonts:
///       - family: Poppins
///         fonts:
///           - asset: fonts/Poppins-Regular.ttf
///           - asset: fonts/Poppins-Bold.ttf
///             weight: 700
///           - asset: fonts/Poppins-Italic.ttf
///             style: italic
///
/// 4. Ganti nilai [_fontFamily] di bawah menjadi 'Poppins', lalu hot-restart.
/// ─────────────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._(); // Kelas utilitas — tidak perlu diinstansiasi

  /// Ganti string ini setelah mendaftarkan font kustom di pubspec.yaml.
  static const String _fontFamily =
      'Poppins'; // fallback ke default jika belum ada

  // ─── Palet warna ─────────────────────────────────────────────────────────
  static const Color _primaryColor = Color(0xFF4F46E5); // Indigo
  static const Color _secondaryColor = Color(0xFF06B6D4); // Cyan
  static const Color _correctColor = Color(0xFF22C55E); // Hijau
  static const Color _wrongColor = Color(0xFFEF4444); // Merah

  // Warna yang diekspos agar bisa dipakai widget lain
  static Color get correctColor => _correctColor;
  static Color get wrongColor => _wrongColor;

  // ─── Light Theme ─────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        secondary: _secondaryColor,
        brightness: Brightness.light,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Kartu soal & pilihan jawaban
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),

      // Tombol utama (Mulai, Lanjut, dll.)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input teks (nama pengguna)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // Tipografi
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E1B4B),
        ),
        headlineMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E1B4B),
        ),
        titleLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E1B4B),
        ),
        bodyLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          color: Color(0xFF374151),
        ),
        bodyMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          color: Color(0xFF6B7280),
        ),
      ),

      scaffoldBackgroundColor: const Color(0xFFF5F7FF),
    );
  }

  // ─── Dark Theme ──────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        secondary: _secondaryColor,
        brightness: Brightness.dark,
      ),

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF1E1B4B),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF1F2937),
        surfaceTintColor: Colors.transparent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF374151),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _secondaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          color: Color(0xFFD1D5DB),
        ),
        bodyMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          color: Color(0xFF9CA3AF),
        ),
      ),

      scaffoldBackgroundColor: const Color(0xFF111827),
    );
  }
}
