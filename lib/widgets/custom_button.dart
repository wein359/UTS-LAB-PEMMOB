import 'package:flutter/material.dart';

/// [CustomButton] — Tombol reusable dengan animasi scale saat ditekan.
///
/// Parameter:
///   [label]        – teks yang ditampilkan di tombol.
///   [onPressed]    – callback saat tombol ditekan. Jika null, tombol disabled.
///   [icon]         – ikon opsional di sebelah kiri label.
///   [isLoading]    – tampilkan spinner, nonaktifkan interaksi.
///   [color]        – warna latar kustom (default: primary theme).
///   [textColor]    – warna teks kustom (default: putih).
///   [width]        – lebar kustom (default: double.infinity / full-width).
///   [height]       – tinggi kustom (default: 52).
///   [borderRadius] – radius sudut kustom (default: 14).
///
/// Contoh pemakaian:
/// ```dart
/// CustomButton(
///   label: 'Mulai Kuis',
///   icon: Icons.play_arrow_rounded,
///   onPressed: () => _startQuiz(),
/// )
/// ```
class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.color,
    this.textColor,
    this.width,
    this.height = 52,
    this.borderRadius = 14,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Controller dengan durasi sangat singkat untuk efek snap
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
    // Scale turun ke 0.95 saat ditekan, balik ke 1.0 saat dilepas
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = widget.onPressed == null || widget.isLoading;

    final bgColor = widget.color ?? theme.colorScheme.primary;
    final effectiveBgColor = isDisabled
        ? bgColor.withValues(alpha: 0.45)
        : bgColor;

    final fgColor = widget.textColor ?? Colors.white;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: (widget.onPressed != null && !widget.isLoading)
          ? widget.onPressed
          : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: effectiveBgColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            // Shadow lebih dalam saat tidak ditekan
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: effectiveBgColor.withValues(alpha: 0.40),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: fgColor, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: fgColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
