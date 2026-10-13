import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/quiz_provider.dart';
import '../widgets/question_card.dart';
import '../widgets/option_tile.dart';
import '../widgets/timer_bar.dart';
import 'result_screen.dart';

/// Halaman utama kuis — menampilkan soal aktif, pilihan jawaban, dan timer.
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();

    // Jika kuis selesai, langsung navigasi ke ResultScreen
    if (quiz.status == QuizStatus.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ResultScreen()),
        );
      });
    }

    final theme = Theme.of(context);
    final question = quiz.currentQuestion;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Soal ${quiz.currentQuestionIndex + 1} / ${quiz.totalQuestions}',
        ),
        automaticallyImplyLeading: false,
        actions: [
          // Indikator skor sementara
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '⭐ ${quiz.userAnswers.values.where((i) {
                  final q = quiz.questions
                      .firstWhere((q) => quiz.userAnswers[q.id] == i, orElse: () => quiz.questions.first);
                  return quiz.userAnswers[q.id] == q.correctAnswerIndex;
                }).length}',
                style: theme.appBarTheme.titleTextStyle,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Progress Bar ──────────────────────────────────────────────
              LinearProgressIndicator(
                value: (quiz.currentQuestionIndex + 1) / quiz.totalQuestions,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 12),

              // ── Timer Bar ────────────────────────────────────────────────
              TimerBar(
                remainingSeconds: quiz.remainingSeconds,
                totalSeconds: 15,
              ),
              const SizedBox(height: 16),

              // ── Kartu Pertanyaan ─────────────────────────────────────────
              QuestionCard(question: question),
              const SizedBox(height: 20),

              // ── Pilihan Jawaban ──────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  itemCount: question.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return OptionTile(
                      label: question.options[index],
                      index: index,
                      questionId: question.id,
                      correctAnswerIndex: question.correctAnswerIndex,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
