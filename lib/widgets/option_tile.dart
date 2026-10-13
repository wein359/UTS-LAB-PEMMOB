import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';

/// Satu baris pilihan jawaban.
///
/// Setelah pengguna memilih jawaban:
///   - Pilihan BENAR → hijau
///   - Pilihan SALAH yang dipilih → merah
///   - Pilihan lain → abu-abu (nonaktif)
class OptionTile extends StatelessWidget {
  final String label;
  final int index;
  final int questionId;
  final int correctAnswerIndex;

  const OptionTile({
    super.key,
    required this.label,
    required this.index,
    required this.questionId,
    required this.correctAnswerIndex,
  });

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final theme = Theme.of(context);

    final userAnswer = quiz.userAnswers[questionId];
    final isAnswered = userAnswer != null;
    final isSelected = userAnswer == index;
    final isCorrect = index == correctAnswerIndex;

    // Tentukan warna latar tile berdasarkan kondisi jawaban
    Color tileColor;
    Color borderColor;
    Color textColor;

    if (!isAnswered) {
      // Belum dijawab → warna default kartu
      tileColor = theme.cardTheme.color ?? theme.colorScheme.surface;
      borderColor = theme.colorScheme.outline;
      textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    } else if (isCorrect) {
      tileColor = AppTheme.correctColor.withOpacity(0.15);
      borderColor = AppTheme.correctColor;
      textColor = AppTheme.correctColor;
    } else if (isSelected) {
      tileColor = AppTheme.wrongColor.withOpacity(0.15);
      borderColor = AppTheme.wrongColor;
      textColor = AppTheme.wrongColor;
    } else {
      tileColor = theme.cardTheme.color ?? theme.colorScheme.surface;
      borderColor = theme.colorScheme.outline.withOpacity(0.3);
      textColor = (theme.textTheme.bodyLarge?.color ?? Colors.black)
          .withOpacity(0.4);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        // Nonaktifkan tap setelah dijawab
        onTap: isAnswered ? null : () => quiz.answerQuestion(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Lingkaran huruf opsi (A, B, C, D)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: borderColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  String.fromCharCode(65 + index), // A=65
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: borderColor,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(color: textColor),
                ),
              ),
              if (isAnswered && isCorrect)
                Icon(Icons.check_circle, color: AppTheme.correctColor),
              if (isAnswered && isSelected && !isCorrect)
                Icon(Icons.cancel, color: AppTheme.wrongColor),
            ],
          ),
        ),
      ),
    );
  }
}
