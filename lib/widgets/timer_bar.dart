import 'package:flutter/material.dart';

/// Widget bar countdown timer dengan animasi warna.
///
/// Warna berubah:
///   > 8 detik  → hijau
///   4–8 detik  → oranye
///   < 4 detik  → merah (berkedip)
class TimerBar extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;

  const TimerBar({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  Color _barColor() {
    if (remainingSeconds > 8) return const Color(0xFF22C55E); // hijau
    if (remainingSeconds > 4) return const Color(0xFFF59E0B); // oranye
    return const Color(0xFFEF4444); // merah
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = remainingSeconds / totalSeconds;

    return Row(
      children: [
        // Bar
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor()),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Angka detik
        SizedBox(
          width: 36,
          child: Text(
            '$remainingSeconds',
            style: theme.textTheme.titleLarge?.copyWith(
              color: _barColor(),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
