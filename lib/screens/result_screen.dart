import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import 'welcome_screen.dart';

/// Halaman hasil kuis — menampilkan skor akhir dan ringkasan jawaban.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final theme = Theme.of(context);
    final percentage = (quiz.score / quiz.totalQuestions * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Kuis')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Kartu Skor ───────────────────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Halo, ${quiz.username}!',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      // Lingkaran skor
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 130,
                            height: 130,
                            child: CircularProgressIndicator(
                              value: quiz.score / quiz.totalQuestions,
                              strokeWidth: 10,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                percentage >= 70
                                    ? AppTheme.correctColor
                                    : AppTheme.wrongColor,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '${quiz.score}/${quiz.totalQuestions}',
                                style: theme.textTheme.headlineMedium,
                              ),
                              Text(
                                '$percentage%',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _feedbackMessage(percentage),
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Ringkasan Jawaban ─────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ringkasan Jawaban',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              ...quiz.questions.map((q) {
                final userAnswer = quiz.userAnswers[q.id];
                final isCorrect = userAnswer == q.correctAnswerIndex;
                final isSkipped = userAnswer == null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Icon(
                      isSkipped
                          ? Icons.remove_circle_outline
                          : isCorrect
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                      color: isSkipped
                          ? Colors.grey
                          : isCorrect
                              ? AppTheme.correctColor
                              : AppTheme.wrongColor,
                    ),
                    title: Text(
                      q.questionText,
                      style: theme.textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      isSkipped
                          ? 'Tidak dijawab · Benar: ${q.correctAnswer}'
                          : isCorrect
                              ? 'Benar ✓'
                              : 'Kamu: ${q.options[userAnswer!]} · Benar: ${q.correctAnswer}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSkipped
                            ? Colors.grey
                            : isCorrect
                                ? AppTheme.correctColor
                                : AppTheme.wrongColor,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // ── Tombol Ulangi ────────────────────────────────────────────
              ElevatedButton.icon(
                onPressed: () {
                  quiz.resetQuiz();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  );
                },
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _feedbackMessage(int percentage) {
    if (percentage == 100) return '🏆 Sempurna! Kamu luar biasa!';
    if (percentage >= 80) return '🎉 Bagus sekali! Hampir sempurna!';
    if (percentage >= 60) return '👍 Cukup baik! Terus belajar!';
    if (percentage >= 40) return '📖 Perlu lebih banyak belajar ya!';
    return '💪 Jangan menyerah, coba lagi!';
  }
}
