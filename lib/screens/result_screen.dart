import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/question.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/result_illustration.dart';
import '../widgets/theme_toggle.dart';
import 'welcome_screen.dart';

/// [ResultScreen] — Halaman hasil kuis.
///
/// Struktur (atas → bawah):
///   1. AppBar  — judul + [ThemeToggle].
///   2. Ilustrasi kondisional ([ResultIllustration]) sesuai tier skor.
///   3. Ucapan selamat + nama pengguna.
///   4. [_ScoreSummaryCard] — skor, benar, salah, skip dalam satu baris.
///   5. [_AnswerReviewList] — ringkasan tiap soal (benar/salah/skip).
///   6. Tombol "Ulangi Kuis" — reset state → kembali ke [WelcomeScreen].
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);

    final percentage = (quiz.score / quiz.totalQuestions * 100).round();
    final tier = ResultIllustration.tierFromPercentage(percentage);
    // Hitung statistik jawaban
    final correctCount = quiz.liveScore;
    final skippedCount = quiz.totalQuestions - quiz.userAnswers.length;
    final wrongCountFinal = quiz.userAnswers.length - correctCount;

    // Padding horizontal responsif
    final hPad = mq.size.width > 600 ? mq.size.width * 0.12 : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Kuis'),
        automaticallyImplyLeading: false,
        actions: const [ThemeToggle()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Ilustrasi kondisional ──────────────────────────────────
              Center(
                child: ResultIllustration(
                  tier: tier,
                  size: (mq.size.height * 0.26).clamp(140.0, 220.0),
                ),
              ),
              const SizedBox(height: 20),

              // ── Ucapan + nama ──────────────────────────────────────────
              _GreetingSection(
                username: quiz.username,
                percentage: percentage,
                tier: tier,
                theme: theme,
              ),
              const SizedBox(height: 20),

              // ── Kartu ringkasan skor ───────────────────────────────────
              _ScoreSummaryCard(
                score: quiz.score,
                total: quiz.totalQuestions,
                correct: correctCount,
                wrong: wrongCountFinal,
                skipped: skippedCount,
                percentage: percentage,
                theme: theme,
              ),
              const SizedBox(height: 24),

              // ── Header review jawaban ──────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Ringkasan Jawaban', style: theme.textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 12),

              // ── Daftar review tiap soal ────────────────────────────────
              _AnswerReviewList(
                questions: quiz.questions,
                userAnswers: quiz.userAnswers,
                theme: theme,
              ),
              const SizedBox(height: 28),

              // ── Tombol Ulangi Kuis ─────────────────────────────────────
              CustomButton(
                label: 'Ulangi Kuis',
                icon: Icons.replay_rounded,
                onPressed: () {
                  quiz.resetQuiz();
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (_, animation, __) => const WelcomeScreen(),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(
                            opacity: CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeIn,
                            ),
                            child: child,
                          ),
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
                height: 54,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ucapan + motivasi berdasarkan tier
// ─────────────────────────────────────────────────────────────────────────────
class _GreetingSection extends StatelessWidget {
  final String username;
  final int percentage;
  final ResultTier tier;
  final ThemeData theme;

  const _GreetingSection({
    required this.username,
    required this.percentage,
    required this.tier,
    required this.theme,
  });

  String get _headline {
    switch (tier) {
      case ResultTier.perfect:
        return '🏆 Sempurna!';
      case ResultTier.great:
        return '🎉 Bagus Sekali!';
      case ResultTier.good:
        return '👍 Cukup Baik!';
      case ResultTier.tryAgain:
        return '💪 Jangan Menyerah!';
    }
  }

  String get _subtitle {
    switch (tier) {
      case ResultTier.perfect:
        return 'Kamu menjawab semua soal dengan benar. Luar biasa, $username!';
      case ResultTier.great:
        return 'Kerja keras kamu terbayar, $username! Sedikit lagi menuju sempurna.';
      case ResultTier.good:
        return 'Tidak buruk, $username! Terus berlatih dan kamu pasti bisa lebih baik.';
      case ResultTier.tryAgain:
        return 'Tetap semangat, $username! Setiap percobaan adalah langkah maju.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _headline,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          _subtitle,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kartu ringkasan skor: nilai besar + 3 chip (benar / salah / skip)
// ─────────────────────────────────────────────────────────────────────────────
class _ScoreSummaryCard extends StatelessWidget {
  final int score;
  final int total;
  final int correct;
  final int wrong;
  final int skipped;
  final int percentage;
  final ThemeData theme;

  const _ScoreSummaryCard({
    required this.score,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.percentage,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
              : [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        children: [
          // ── Skor besar di tengah ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  ' / $total',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Persentase + label
          Text(
            '$percentage%',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // ── Progress bar skor ─────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: score / total),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.20),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── 3 chip stat ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  icon: Icons.check_circle_rounded,
                  label: 'Benar',
                  value: '$correct',
                  color: AppTheme.correctColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatChip(
                  icon: Icons.cancel_rounded,
                  label: 'Salah',
                  value: '$wrong',
                  color: AppTheme.wrongColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatChip(
                  icon: Icons.remove_circle_rounded,
                  label: 'Dilewati',
                  value: '$skipped',
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Chip statistik kecil dalam kartu skor ────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daftar review jawaban per soal
// ─────────────────────────────────────────────────────────────────────────────
class _AnswerReviewList extends StatelessWidget {
  final List<Question> questions;
  final Map<int, int> userAnswers;
  final ThemeData theme;

  const _AnswerReviewList({
    required this.questions,
    required this.userAnswers,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: questions.map((q) {
        final userAnswer = userAnswers[q.id];
        final isSkipped = userAnswer == null;
        final isCorrect = userAnswer == q.correctAnswerIndex;

        final statusColor = isSkipped
            ? Colors.grey
            : isCorrect
            ? AppTheme.correctColor
            : AppTheme.wrongColor;

        final statusIcon = isSkipped
            ? Icons.remove_circle_outline_rounded
            : isCorrect
            ? Icons.check_circle_rounded
            : Icons.cancel_rounded;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.30),
              width: 1.2,
            ),
          ),
          child: Theme(
            // Hilangkan divider bawaan ExpansionTile
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              leading: Icon(statusIcon, color: statusColor, size: 22),
              title: Text(
                q.questionText,
                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  isSkipped
                      ? 'Dilewati (waktu habis)'
                      : isCorrect
                      ? 'Jawaban benar ✓'
                      : 'Jawaban salah',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
              // Detail yang muncul saat tile dibuka
              children: [
                const Divider(height: 1),
                const SizedBox(height: 10),
                // Semua opsi jawaban dengan highlight
                ...List.generate(q.options.length, (i) {
                  final isThisCorrect = i == q.correctAnswerIndex;
                  final isThisSelected = i == userAnswer;

                  Color bgColor;
                  Color borderColor;
                  IconData? trailingIcon;

                  if (isThisCorrect) {
                    bgColor = AppTheme.correctColor.withValues(alpha: 0.10);
                    borderColor = AppTheme.correctColor;
                    trailingIcon = Icons.check_circle_rounded;
                  } else if (isThisSelected) {
                    bgColor = AppTheme.wrongColor.withValues(alpha: 0.10);
                    borderColor = AppTheme.wrongColor;
                    trailingIcon = Icons.cancel_rounded;
                  } else {
                    bgColor = Colors.transparent;
                    borderColor = theme.colorScheme.outline.withValues(
                      alpha: 0.20,
                    );
                    trailingIcon = null;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Row(
                      children: [
                        // Badge huruf
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: borderColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            String.fromCharCode(65 + i),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: borderColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            q.options[i],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: isThisCorrect || isThisSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isThisCorrect
                                  ? AppTheme.correctColor
                                  : isThisSelected
                                  ? AppTheme.wrongColor
                                  : null,
                            ),
                          ),
                        ),
                        if (trailingIcon != null)
                          Icon(
                            trailingIcon,
                            color: isThisCorrect
                                ? AppTheme.correctColor
                                : AppTheme.wrongColor,
                            size: 18,
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
