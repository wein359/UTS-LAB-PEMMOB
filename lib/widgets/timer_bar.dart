import 'package:flutter/material.dart';

/// [TimerBar] — Progress bar countdown dengan animasi warna dan shake.
///
/// Perilaku warna:
///   > 8 detik  → hijau   (#22C55E)
///   4–8 detik  → oranye  (#F59E0B)
///   ≤ 4 detik  → merah   (#EF4444) + animasi shake horizontal
///
/// Cara pakai:
/// ```dart
/// TimerBar(
///   remainingSeconds: quiz.remainingSeconds,
///   totalSeconds: QuizProvider.secondsPerQuestion,
/// )
/// ```
class TimerBar extends StatefulWidget {
  final int remainingSeconds;
  final int totalSeconds;

  const TimerBar({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  @override
  State<TimerBar> createState() => _TimerBarState();
}

class _TimerBarState extends State<TimerBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnim;

  int _prevSeconds = -1;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    // Shake: getaran kiri-kanan ±4px, 2 siklus
    _shakeAnim =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -4.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 4.0, end: -4.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );
  }

  @override
  void didUpdateWidget(TimerBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger shake setiap detik saat ≤ 4 dan angka berubah
    if (widget.remainingSeconds <= 4 &&
        widget.remainingSeconds != _prevSeconds &&
        widget.remainingSeconds > 0) {
      _shakeController.forward(from: 0);
    }
    _prevSeconds = widget.remainingSeconds;
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Color _barColor() {
    if (widget.remainingSeconds > 8) return const Color(0xFF22C55E);
    if (widget.remainingSeconds > 4) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (widget.remainingSeconds / widget.totalSeconds).clamp(
      0.0,
      1.0,
    );
    final color = _barColor();
    final isCritical = widget.remainingSeconds <= 4;

    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(isCritical ? _shakeAnim.value : 0, 0),
          child: child,
        );
      },
      child: Row(
        children: [
          // ── Progress bar ─────────────────────────────────────────────────
          Expanded(
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              clipBehavior: Clip.hardEdge,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        width: constraints.maxWidth * progress,
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: color,
                          // Glow tipis saat critical
                          boxShadow: isCritical
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.55),
                                    blurRadius: 6,
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Angka detik ───────────────────────────────────────────────────
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: isCritical ? 18 : 15,
              fontFamily: Theme.of(context).textTheme.titleLarge?.fontFamily,
            ),
            child: SizedBox(
              width: 28,
              child: Text(
                '${widget.remainingSeconds}',
                textAlign: TextAlign.right,
              ),
            ),
          ),

          const SizedBox(width: 4),
          Icon(Icons.timer_outlined, size: 16, color: color),
        ],
      ),
    );
  }
}
