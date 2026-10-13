import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/quiz_provider.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(
    // ChangeNotifierProvider membungkus seluruh app agar QuizProvider
    // bisa diakses dari widget mana saja menggunakan context.watch / context.read.
    // State tetap tersimpan saat rotasi layar karena Provider hidup di atas MaterialApp.
    ChangeNotifierProvider(
      create: (_) => QuizProvider(),
      child: const QuizApp(),
    ),
  );
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kuis Pilihan Ganda',
      debugShowCheckedModeBanner: false,

      // ── Tema ──────────────────────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // ThemeMode.system → otomatis ikut mode perangkat (Light/Dark).
      // Ganti ke ThemeMode.light atau ThemeMode.dark untuk paksa salah satu.
      themeMode: ThemeMode.system,

      home: const WelcomeScreen(),
    );
  }
}
