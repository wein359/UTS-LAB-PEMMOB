import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/quiz_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/quiz_illustration.dart';
import 'quiz_screen.dart';

/// [WelcomeScreen] — Halaman pertama yang dilihat pengguna.
///
/// Fitur:
///   - Ilustrasi kuis animasi (tanpa file gambar eksternal).
///   - Input nama pengguna menggunakan [CustomTextField] dengan validasi.
///   - Tombol "Mulai Kuis" menggunakan [CustomButton] dengan animasi press.
///   - Responsif menggunakan [LayoutBuilder] + [MediaQuery]:
///       • Ukuran ilustrasi, spacing, dan font menyesuaikan tinggi layar.
///       • Tidak overflow di layar kecil (fold, tablet kecil).
///   - Mendukung Light Mode & Dark Mode secara otomatis.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Animasi fade-in + slide-up saat halaman pertama muncul
  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero).animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
        );

    // Mulai animasi setelah frame pertama render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entryController.forward();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _startQuiz() {
    // Tutup keyboard sebelum validasi
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      context.read<QuizProvider>().startQuiz(_nameController.text);
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => const QuizScreen(),
          transitionsBuilder: (_, animation, __, child) {
            // Slide dari kanan ke kiri saat masuk QuizScreen
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1.0, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // ── Background gradient ─────────────────────────────────────────────
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1E1B4B), const Color(0xFF111827)]
                : [const Color(0xFFEEF2FF), const Color(0xFFF5F7FF)],
            stops: const [0.0, 0.55],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // ── Breakpoint responsif ──────────────────────────────────
              final screenH = constraints.maxHeight;
              final screenW = constraints.maxWidth;

              // Ukuran ilustrasi: 32% tinggi layar, min 140, max 260
              final illustrationSize = (screenH * 0.32).clamp(140.0, 260.0);

              // Spacing vertikal proporsional
              final spacingLg = (screenH * 0.035).clamp(12.0, 32.0);
              final spacingSm = (screenH * 0.018).clamp(8.0, 16.0);

              // Padding horizontal: lebih sempit di tablet landscape
              final hPad = screenW > 600
                  ? screenW * 0.18
                  : (screenW * 0.06).clamp(20.0, 32.0);

              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: hPad,
                      vertical: spacingLg,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Ilustrasi ──────────────────────────────────
                          Center(
                            child: QuizIllustration(size: illustrationSize),
                          ),
                          SizedBox(height: spacingLg),

                          // ── Judul ──────────────────────────────────────
                          Text(
                            'Kuis Pemrograman\nMobile',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: screenH < 600 ? 22 : null,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: spacingSm),

                          // ── Subtitle / info soal ───────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _InfoChip(
                                icon: Icons.quiz_outlined,
                                label: '10 Soal',
                                color: theme.colorScheme.primary,
                              ),
                              SizedBox(width: spacingSm),
                              _InfoChip(
                                icon: Icons.timer_outlined,
                                label: '15 Detik/Soal',
                                color: theme.colorScheme.secondary,
                              ),
                            ],
                          ),
                          SizedBox(height: spacingLg * 1.2),

                          // ── Label input ────────────────────────────────
                          Text(
                            'Siapa namamu?',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: screenH < 600 ? 15 : null,
                            ),
                          ),
                          SizedBox(height: spacingSm),

                          // ── CustomTextField ────────────────────────────
                          CustomTextField(
                            controller: _nameController,
                            hintText: 'Contoh: Budi Santoso',
                            prefixIcon: Icons.person_outline_rounded,
                            textCapitalization: TextCapitalization.words,
                            maxLength: 30,
                            autofocus: false,
                            onFieldSubmitted: (_) => _startQuiz(),
                            // Validasi: tidak boleh kosong, min 2 karakter
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nama tidak boleh kosong';
                              }
                              if (value.trim().length < 2) {
                                return 'Nama minimal 2 karakter';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: spacingLg),

                          // ── CustomButton ───────────────────────────────
                          CustomButton(
                            label: 'Mulai Kuis',
                            icon: Icons.play_arrow_rounded,
                            onPressed: _startQuiz,
                            height: screenH < 600 ? 46 : 54,
                          ),
                          SizedBox(height: spacingSm * 1.5),

                          // ── Disclaimer kecil ───────────────────────────
                          Text(
                            'Pastikan nama sudah benar sebelum memulai.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Chip info kecil (jumlah soal / durasi) ───────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
