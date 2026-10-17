import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';

/// [OptionCard] — Kartu pilihan jawaban reusable pengganti OptionTile.
///
/// Fitur:
///   - Animasi scale press saat ditekan (GestureDetector + ScaleTransition).
///   - AnimatedContainer reveal warna: hijau (benar) / merah (salah dipilih) /
///     abu redup (salah tidak dipilih) setelah soal dijawab.
///   - Haptic feedback ringan saat dipilih.
///   - Badge huruf opsi (A/B/C/D) ikut berganti warna.
///   - Ikon centang/silang muncul dengan FadeTransition setelah dijawab.
///   - Nonaktif otomatis setelah soal dijawab atau timer habis.
class OptionCard extends StatefulWidget {
  /// Teks pilihan jawaban.
  final String label;

  /// Indeks opsi ini (0–3).
  final int index;

  /// ID soal — untuk lookup jawaban di provider.
  final int questionId;

  /// Indeks jawaban yang benar.
  final int correctAnswerIndex;

  const OptionCard({
    super.key,
    required this.label,
    required this.index,
    required this.questionId,
    required this.correctAnswerIndex,
  });

  @override
  State<OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<OptionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressController.forward();
  void _onTapUp(TapUpDetails _) => _pressController.reverse();
  void _onTapCancel() => _pressController.reverse();

  // ── Tentukan state visual berdasarkan kondisi jawaban ──────────────────────
  _OptionState _resolveState(int? userAnswer) {
    if (userAnswer == null) return _OptionState.idle;
    if (widget.index == widget.correctAnswerIndex) return _OptionState.correct;
    if (userAnswer == widget.index) return _OptionState.wrong;
    return _OptionState.dimmed;
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final userAnswer = quiz.userAnswers[widget.questionId];
    final isAnswered = quiz.isCurrentAnswered;
    final state = _resolveState(userAnswer);

    // ── Palet warna per state ──────────────────────────────────────────────
    final colors = _resolveColors(state, theme, isDark);

    return GestureDetector(
      onTapDown: isAnswered ? null : _onTapDown,
      onTapUp: isAnswered ? null : _onTapUp,
      onTapCancel: isAnswered ? null : _onTapCancel,
      onTap: isAnswered
          ? null
          : () {
              HapticFeedback.lightImpact();
              quiz.answerQuestion(widget.index);
            },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border, width: colors.borderWidth),
            boxShadow: state == _OptionState.idle
                ? [
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              // ── Badge huruf opsi ─────────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.badgeBackground,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  String.fromCharCode(65 + widget.index), // A=65
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.badgeText,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // ── Teks opsi ────────────────────────────────────────────────
              Expanded(
                child: Text(
                  widget.label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.text,
                    fontWeight: state != _OptionState.idle
                        ? FontWeight.w600
                        : FontWeight.normal,
                    height: 1.3,
                  ),
                ),
              ),

              // ── Ikon hasil (muncul setelah dijawab) ──────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildResultIcon(state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultIcon(_OptionState state) {
    switch (state) {
      case _OptionState.correct:
        return Icon(
          Icons.check_circle_rounded,
          key: const ValueKey('correct'),
          color: AppTheme.correctColor,
          size: 22,
        );
      case _OptionState.wrong:
        return Icon(
          Icons.cancel_rounded,
          key: const ValueKey('wrong'),
          color: AppTheme.wrongColor,
          size: 22,
        );
      default:
        return const SizedBox.shrink(key: ValueKey('none'));
    }
  }

  _OptionColors _resolveColors(
    _OptionState state,
    ThemeData theme,
    bool isDark,
  ) {
    final surface = theme.cardTheme.color ?? theme.colorScheme.surface;
    final outline = theme.colorScheme.outline;

    switch (state) {
      case _OptionState.idle:
        return _OptionColors(
          background: surface,
          border: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          borderWidth: 1.2,
          text: theme.textTheme.bodyLarge?.color ?? Colors.black,
          badgeBackground: theme.colorScheme.primary.withValues(alpha: 0.10),
          badgeText: theme.colorScheme.primary,
        );

      case _OptionState.correct:
        return _OptionColors(
          background: AppTheme.correctColor.withValues(
            alpha: isDark ? 0.18 : 0.10,
          ),
          border: AppTheme.correctColor,
          borderWidth: 1.8,
          text: isDark ? AppTheme.correctColor : const Color(0xFF15803D),
          badgeBackground: AppTheme.correctColor.withValues(alpha: 0.20),
          badgeText: AppTheme.correctColor,
        );

      case _OptionState.wrong:
        return _OptionColors(
          background: AppTheme.wrongColor.withValues(
            alpha: isDark ? 0.18 : 0.10,
          ),
          border: AppTheme.wrongColor,
          borderWidth: 1.8,
          text: isDark ? AppTheme.wrongColor : const Color(0xFFB91C1C),
          badgeBackground: AppTheme.wrongColor.withValues(alpha: 0.20),
          badgeText: AppTheme.wrongColor,
        );

      case _OptionState.dimmed:
        return _OptionColors(
          background: surface,
          border: outline.withValues(alpha: 0.25),
          borderWidth: 1.0,
          text: (theme.textTheme.bodyLarge?.color ?? Colors.black).withValues(
            alpha: 0.35,
          ),
          badgeBackground: outline.withValues(alpha: 0.08),
          badgeText: outline.withValues(alpha: 0.40),
        );
    }
  }
}

// ─── Enum state visual opsi ────────────────────────────────────────────────
enum _OptionState { idle, correct, wrong, dimmed }

// ─── Data class warna ──────────────────────────────────────────────────────
class _OptionColors {
  final Color background;
  final Color border;
  final double borderWidth;
  final Color text;
  final Color badgeBackground;
  final Color badgeText;

  const _OptionColors({
    required this.background,
    required this.border,
    required this.borderWidth,
    required this.text,
    required this.badgeBackground,
    required this.badgeText,
  });
}
