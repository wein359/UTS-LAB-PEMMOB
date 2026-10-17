import 'package:flutter/material.dart';

import '../models/question.dart';

/// [QuestionCard] — Kartu yang menampilkan nomor soal dan teks pertanyaan.
///
/// Fitur:
///   - Nomor soal + total (misal: "3 / 10") di badge atas.
///   - Animasi slide + fade saat berpindah ke soal baru (key-based).
///   - Tinggi minimum agar layout tidak loncat saat teks pendek/panjang.
///
/// Cara pakai:
/// ```dart
/// QuestionCard(
///   question: quiz.currentQuestion,
///   questionNumber: quiz.currentQuestionIndex + 1,
///   totalQuestions: quiz.totalQuestions,
/// )
/// ```
class QuestionCard extends StatelessWidget {
  final Question question;
  final int questionNumber;
  final int totalQuestions;

  const QuestionCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        // Slide dari kanan + fade
        final slide =
            Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      // ValueKey berdasarkan id soal memicu AnimatedSwitcher saat soal berganti
      child: _CardContent(
        key: ValueKey(question.id),
        question: question,
        questionNumber: questionNumber,
        totalQuestions: totalQuestions,
        theme: theme,
        isDark: isDark,
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final Question question;
  final int questionNumber;
  final int totalQuestions;
  final ThemeData theme;
  final bool isDark;

  const _CardContent({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 130),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
              : [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Badge nomor soal ──────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Soal $questionNumber / $totalQuestions',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Spacer(),
              // Ikon dekorasi
              Icon(
                Icons.quiz_rounded,
                color: Colors.white.withValues(alpha: 0.50),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Teks pertanyaan ───────────────────────────────────────────────
          Text(
            question.questionText,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
