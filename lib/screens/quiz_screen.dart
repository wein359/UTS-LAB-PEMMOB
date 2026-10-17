import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/quiz_provider.dart';
import '../widgets/quiz_header.dart';
import '../widgets/question_card.dart';
import '../widgets/option_card.dart';
import '../widgets/timer_bar.dart';
import '../widgets/custom_button.dart';
import 'result_screen.dart';

/// [QuizScreen] — Halaman utama kuis.
///
/// Layout (atas → bawah):
///   1. [QuizHeader]    – nama user, skor live, progress bar soal.
///   2. [TimerBar]      – countdown 15 detik per soal dengan animasi warna + shake.
///   3. [QuestionCard]  – teks pertanyaan dengan animasi slide antar soal.
///   4. Daftar [OptionCard] – 4 pilihan jawaban A–D.
///   5. Tombol "Selanjutnya" / "Selesai" – aktif hanya setelah soal dijawab.
///
/// Responsivitas:
///   - [OrientationBuilder] membedakan layout portrait vs landscape.
///   - Semua widget scrollable via [SingleChildScrollView] → tidak overflow
///     di layar kecil atau saat keyboard muncul.
///   - Padding horizontal menggunakan [MediaQuery] untuk layar lebar (tablet).
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  /// Navigasi ke ResultScreen sekali saja (cegah double-push).
  bool _navigatedToResult = false;

  void _goToResult(BuildContext context) {
    if (_navigatedToResult) return;
    _navigatedToResult = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const ResultScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();

    // Navigasi ke hasil setelah frame selesai render
    if (quiz.status == QuizStatus.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _goToResult(context);
      });
    }

    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final isLandscape = mq.orientation == Orientation.landscape;

    // Padding horizontal lebih lebar di tablet / landscape
    final hPad = isLandscape
        ? mq.size.width * 0.12
        : (mq.size.width > 600 ? mq.size.width * 0.08 : 16.0);

    return Scaffold(
      // Hindari resize saat keyboard muncul (bukan input screen, tidak diperlukan)
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.scaffoldBackgroundColor,

      body: SafeArea(
        child: isLandscape
            ? _LandscapeLayout(
                hPad: hPad,
                quiz: quiz,
                onFinish: () => _goToResult(context),
              )
            : _PortraitLayout(
                hPad: hPad,
                quiz: quiz,
                onFinish: () => _goToResult(context),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Layout Portrait (default)
// ─────────────────────────────────────────────────────────────────────────────
class _PortraitLayout extends StatelessWidget {
  final double hPad;
  final QuizProvider quiz;
  final VoidCallback onFinish;

  const _PortraitLayout({
    required this.hPad,
    required this.quiz,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header + Timer (area atas, tidak di-scroll) ───────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 0),
          child: Column(
            children: [
              const QuizHeader(),
              const SizedBox(height: 12),
              TimerBar(
                remainingSeconds: quiz.remainingSeconds,
                totalSeconds: QuizProvider.secondsPerQuestion,
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),

        // ── Konten scrollable: soal + opsi ────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kartu pertanyaan
                QuestionCard(
                  question: quiz.currentQuestion,
                  questionNumber: quiz.currentQuestionIndex + 1,
                  totalQuestions: quiz.totalQuestions,
                ),
                const SizedBox(height: 16),

                // Daftar opsi
                _OptionList(quiz: quiz),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // ── Tombol navigasi (area bawah, tetap terlihat) ──────────────────
        _NavButton(hPad: hPad, quiz: quiz, onFinish: onFinish),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Layout Landscape (rotasi)
// ─────────────────────────────────────────────────────────────────────────────
class _LandscapeLayout extends StatelessWidget {
  final double hPad;
  final QuizProvider quiz;
  final VoidCallback onFinish;

  const _LandscapeLayout({
    required this.hPad,
    required this.quiz,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Kolom kiri: header + soal ──────────────────────────────────────
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(hPad, 14, 12, 16),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const QuizHeader(),
                const SizedBox(height: 10),
                TimerBar(
                  remainingSeconds: quiz.remainingSeconds,
                  totalSeconds: QuizProvider.secondsPerQuestion,
                ),
                const SizedBox(height: 12),
                QuestionCard(
                  question: quiz.currentQuestion,
                  questionNumber: quiz.currentQuestionIndex + 1,
                  totalQuestions: quiz.totalQuestions,
                ),
              ],
            ),
          ),
        ),

        // Divider vertikal
        VerticalDivider(
          width: 1,
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),

        // ── Kolom kanan: opsi + tombol ──────────────────────────────────────
        Expanded(
          flex: 5,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 14, 0, 8),
                  physics: const BouncingScrollPhysics(),
                  child: _OptionList(quiz: quiz),
                ),
              ),
              _NavButton(hPad: 12, quiz: quiz, onFinish: onFinish),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daftar 4 OptionCard
// ─────────────────────────────────────────────────────────────────────────────
class _OptionList extends StatelessWidget {
  final QuizProvider quiz;

  const _OptionList({required this.quiz});

  @override
  Widget build(BuildContext context) {
    final question = quiz.currentQuestion;

    // AnimatedSwitcher agar seluruh daftar opsi diganti dengan animasi
    // saat soal berganti (ValueKey berubah → widget di-rebuild)
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Column(
        key: ValueKey(question.id),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(question.options.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OptionCard(
              label: question.options[i],
              index: i,
              questionId: question.id,
              correctAnswerIndex: question.correctAnswerIndex,
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tombol Selanjutnya / Selesai
// ─────────────────────────────────────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  final double hPad;
  final QuizProvider quiz;
  final VoidCallback onFinish;

  const _NavButton({
    required this.hPad,
    required this.quiz,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = quiz.isLastQuestion;
    final canNext = quiz.canGoNext;

    return Container(
      padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 14),
      // Garis tipis pemisah dari konten di atas
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.40),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // ── Teks hint saat belum dijawab ──────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: canNext
                  ? const SizedBox.shrink(key: ValueKey('empty'))
                  : Row(
                      key: const ValueKey('hint'),
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 14,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pilih jawaban terlebih dahulu',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Tombol aksi ───────────────────────────────────────────────────
          CustomButton(
            label: isLast ? 'Selesai' : 'Selanjutnya',
            icon: isLast ? Icons.flag_rounded : Icons.arrow_forward_rounded,
            onPressed: canNext
                ? () {
                    if (isLast) {
                      quiz.goToNextQuestion(); // trigger status = finished
                    } else {
                      quiz.goToNextQuestion();
                    }
                  }
                : null,
            width: 160,
            height: 48,
            color: isLast ? const Color(0xFF22C55E) : null,
          ),
        ],
      ),
    );
  }
}
