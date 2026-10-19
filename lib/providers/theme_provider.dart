import 'package:flutter/material.dart';

/// [ThemeProvider] — Mengelola preferensi tema aplikasi (Light / Dark / System).
///
/// Diakses dari mana saja melalui Provider:
/// ```dart
/// // Baca mode aktif
/// context.watch<ThemeProvider>().themeMode
///
/// // Toggle
/// context.read<ThemeProvider>().toggleTheme()
/// ```
///
/// State bertahan selama aplikasi berjalan. Jika ingin persisten antar-sesi,
/// integrasikan dengan shared_preferences di [toggleTheme].
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  /// Mode tema saat ini — dikonsumsi langsung oleh [MaterialApp.themeMode].
  ThemeMode get themeMode => _themeMode;

  /// Apakah mode gelap sedang aktif (termasuk system dark).
  bool isDark(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Toggle antara Light ↔ Dark.
  /// Jika saat ini System, ikut brightness perangkat lalu flip.
  void toggleTheme(BuildContext context) {
    final currentlyDark = isDark(context);
    _themeMode = currentlyDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  /// Paksa ke mode tertentu.
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
