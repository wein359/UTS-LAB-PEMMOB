import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/quiz_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(
    // MultiProvider memungkinkan lebih dari satu Provider tersedia
    // di seluruh widget tree tanpa nesting manual.
    MultiProvider(
      providers: [
        // ThemeProvider — state tema (light/dark/system)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // QuizProvider — state seluruh alur kuis
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: const QuizApp(),
    ),
  );
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    // watch ThemeProvider agar MaterialApp rebuild saat tema berubah
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Kuis Pilihan Ganda',
      debugShowCheckedModeBanner: false,

      // ── Tema ──────────────────────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // Dikontrol ThemeProvider — bukan lagi hardcode ThemeMode.system
      themeMode: themeProvider.themeMode,

      home: const WelcomeScreen(),
    );
  }
}
