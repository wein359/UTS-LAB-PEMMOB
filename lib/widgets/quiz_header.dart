import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/quiz_provider.dart';

/// [QuizHeader] — Header halaman kuis.
///
/// Menampilkan:
///   - Salam + nama pengguna (baris atas kiri).
///   - Skor live (jawaban benar sampai saat ini) di kanan.
///   - Progress bar soal yang lebih tebal (baris bawah).
///   - Chip "Soal X/Y" di tengah bawah progress.
///
/// Dipisahkan dari QuizScreen agar mudah diuji dan dikomposisikan ulang.
class QuizHeader extends StatelessWidget {
  const QuizHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final progress =
        (quiz.currentQuestionIndex + 1) / quiz.totalQuestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Baris atas: nama + skor ─────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar inisial
            _InitialAvatar(name: quiz.username, theme: theme),
            const SizedBox(width: 10),

            // Nama & keterangan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.username,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Semangat mengerjakan!',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),

            // Skor live
            _ScoreBadge(
              score: quiz.liveScore,
              total: quiz.totalQuestions,
              theme: theme,
              isDark: isDark,
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── Progress bar soal ───────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Label soal di atas bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pertanyaan ${quiz.currentQuestionIndex + 1} / ${quiz.totalQuestions}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 8,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Avatar lingkaran dengan inisial nama ─────────────────────────────────
class _InitialAvatar extends StatelessWidget {
  final String name;
  final ThemeData theme;

  const _InitialAvatar({required this.name, required this.theme});

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

// ─── Badge skor live ──────────────────────────────────────────────────────
class _ScoreBadge extends StatelessWidget {
  final int score;
  final int total;
  final ThemeData theme;
  final bool isDark;

  const _ScoreBadge({
    required this.score,
    required this.total,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.20 : 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.50),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF59E0B)),
          const SizedBox(width: 4),
          // AnimatedSwitcher agar angka berganti dengan animasi
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: Text(
              '$score',
              key: ValueKey(score),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFFF59E0B),
              ),
            ),
          ),
          Text(
            ' / $total',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFFF59E0B).withValues(alpha: 0.70),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
