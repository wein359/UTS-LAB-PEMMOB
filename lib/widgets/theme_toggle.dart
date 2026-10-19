import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

/// [ThemeToggle] — Icon button untuk toggle Light ↔ Dark mode.
///
/// Pasang di AppBar actions atau di mana saja:
/// ```dart
/// AppBar(actions: [ThemeToggle()])
/// ```
///
/// Tampilan:
///   - Mode gelap aktif  → ikon matahari ☀️ (klik untuk ke Light)
///   - Mode terang aktif → ikon bulan 🌙 (klik untuk ke Dark)
/// Animasi rotate + fade saat ikon berganti.
class ThemeToggle extends StatefulWidget {
  /// Warna ikon. Default: putih (cocok di AppBar gelap).
  final Color? iconColor;

  const ThemeToggle({super.key, this.iconColor});

  @override
  State<ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<ThemeToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _rotateAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _rotateAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _fadeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    _ctrl.forward(from: 0);
    context.read<ThemeProvider>().toggleTheme(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark(context);
    final color = widget.iconColor ?? Colors.white;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return IconButton(
          tooltip: isDark ? 'Ganti ke Light Mode' : 'Ganti ke Dark Mode',
          icon: FadeTransition(
            opacity: _fadeAnim,
            child: RotationTransition(
              turns: _rotateAnim,
              child: Icon(
                isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
                color: color,
              ),
            ),
          ),
          onPressed: _toggle,
        );
      },
    );
  }
}
