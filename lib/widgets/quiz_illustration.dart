import 'package:flutter/material.dart';

/// [QuizIllustration] — Ilustrasi kuis yang digambar murni dengan CustomPainter.
///
/// Tidak membutuhkan file gambar eksternal sama sekali.
/// Ukuran mengikuti [size] yang diberikan parent (responsif).
///
/// Cara pakai:
/// ```dart
/// QuizIllustration(size: 220)
/// ```
class QuizIllustration extends StatefulWidget {
  final double size;

  const QuizIllustration({super.key, this.size = 220});

  @override
  State<QuizIllustration> createState() => _QuizIllustrationState();
}

class _QuizIllustrationState extends State<QuizIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    // Naik-turun ±6px
    _floatAnimation = Tween<double>(
      begin: -6.0,
      end: 6.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Lingkaran latar berdenyut 0.94–1.06
    _pulseAnimation = Tween<double>(
      begin: 0.94,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // ── Lingkaran latar berdenyut ──────────────────────────────
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withValues(alpha: isDark ? 0.12 : 0.08),
                  ),
                ),
              ),

              // ── Lingkaran tengah ───────────────────────────────────────
              Container(
                width: widget.size * 0.78,
                height: widget.size * 0.78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: isDark ? 0.18 : 0.12),
                ),
              ),

              // ── Ilustrasi utama (mengambang) ───────────────────────────
              Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: CustomPaint(
                  size: Size(widget.size * 0.62, widget.size * 0.62),
                  painter: _QuizCardPainter(
                    primaryColor: primary,
                    secondaryColor: secondary,
                    isDark: isDark,
                  ),
                ),
              ),

              // ── Badge kecil — tanda tanya ──────────────────────────────
              Positioned(
                top: widget.size * 0.08,
                right: widget.size * 0.10,
                child: Transform.translate(
                  offset: Offset(0, -_floatAnimation.value * 0.6),
                  child: _FloatingBadge(
                    size: widget.size * 0.16,
                    color: secondary,
                    child: Text(
                      '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.size * 0.085,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Badge kecil — bintang ──────────────────────────────────
              Positioned(
                bottom: widget.size * 0.10,
                left: widget.size * 0.08,
                child: Transform.translate(
                  offset: Offset(0, _floatAnimation.value * 0.8),
                  child: _FloatingBadge(
                    size: widget.size * 0.14,
                    color: const Color(0xFFF59E0B),
                    child: Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: widget.size * 0.075,
                    ),
                  ),
                ),
              ),

              // ── Badge kecil — centang ──────────────────────────────────
              Positioned(
                bottom: widget.size * 0.12,
                right: widget.size * 0.06,
                child: Transform.translate(
                  offset: Offset(0, -_floatAnimation.value * 0.5),
                  child: _FloatingBadge(
                    size: widget.size * 0.13,
                    color: const Color(0xFF22C55E),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: widget.size * 0.07,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Badge bulat kecil ─────────────────────────────────────────────────────
class _FloatingBadge extends StatelessWidget {
  final double size;
  final Color color;
  final Widget child;

  const _FloatingBadge({
    required this.size,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.40),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

// ─── CustomPainter — kartu soal kuis ──────────────────────────────────────
class _QuizCardPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;

  const _QuizCardPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ── Shadow kartu ──────────────────────────────────────────────────────
    final cardShadowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    // ── Latar kartu ───────────────────────────────────────────────────────
    final cardPaint = Paint()
      ..color = isDark ? const Color(0xFF1F2937) : Colors.white
      ..style = PaintingStyle.fill;

    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy + size.height * 0.03),
        width: size.width * 0.82,
        height: size.height * 0.72,
      ),
      const Radius.circular(18),
    );

    canvas.drawRRect(cardRect, cardShadowPaint);
    canvas.drawRRect(cardRect, cardPaint);

    // ── Header kartu (primary) ────────────────────────────────────────────
    final headerRect = RRect.fromLTRBAndCorners(
      cardRect.left,
      cardRect.top,
      cardRect.right,
      cardRect.top + size.height * 0.22,
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
    );
    canvas.drawRRect(
      headerRect,
      Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill,
    );

    // ── Lingkaran putih di header ─────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cardRect.top + size.height * 0.11),
      size.width * 0.10,
      Paint()..color = Colors.white.withValues(alpha: 0.90),
    );

    // ── Tanda tanya di dalam lingkaran ────────────────────────────────────
    final qPath = Path();
    qPath.moveTo(cx - size.width * 0.035, cardRect.top + size.height * 0.075);
    qPath.quadraticBezierTo(
      cx - size.width * 0.035,
      cardRect.top + size.height * 0.050,
      cx,
      cardRect.top + size.height * 0.050,
    );
    qPath.quadraticBezierTo(
      cx + size.width * 0.038,
      cardRect.top + size.height * 0.050,
      cx + size.width * 0.038,
      cardRect.top + size.height * 0.080,
    );
    qPath.quadraticBezierTo(
      cx + size.width * 0.038,
      cardRect.top + size.height * 0.105,
      cx,
      cardRect.top + size.height * 0.108,
    );
    qPath.lineTo(cx, cardRect.top + size.height * 0.125);
    canvas.drawPath(
      qPath,
      Paint()
        ..color = primaryColor
        ..strokeWidth = size.width * 0.025
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    // Titik bawah "?"
    canvas.drawCircle(
      Offset(cx, cardRect.top + size.height * 0.140),
      size.width * 0.013,
      Paint()..color = primaryColor,
    );

    // ── Garis konten (simulasi teks soal) ─────────────────────────────────
    final lineColor = isDark ? Colors.grey.shade600 : Colors.grey.shade300;
    final lineX = cardRect.left + size.width * 0.09;
    final lineMaxX = cardRect.right - size.width * 0.09;
    final lineH = size.height * 0.040;

    // Baris 1 — penuh
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          lineX,
          cardRect.top + size.height * 0.30,
          lineMaxX - lineX,
          lineH,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = lineColor,
    );
    // Baris 2 — 70%
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          lineX,
          cardRect.top + size.height * 0.38,
          (lineMaxX - lineX) * 0.70,
          lineH,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = lineColor,
    );

    // ── 4 opsi jawaban ─────────────────────────────────────────────────────
    final optColors = [
      secondaryColor.withValues(alpha: 0.25),
      secondaryColor.withValues(alpha: 0.25),
      const Color(0xFF22C55E).withValues(alpha: 0.25), // opsi benar
      secondaryColor.withValues(alpha: 0.25),
    ];
    final optBorders = [
      secondaryColor.withValues(alpha: 0.50),
      secondaryColor.withValues(alpha: 0.50),
      const Color(0xFF22C55E),
      secondaryColor.withValues(alpha: 0.50),
    ];

    for (int i = 0; i < 4; i++) {
      final row = i ~/ 2;
      final col = i % 2;
      final optX =
          cardRect.left +
          size.width * 0.08 +
          col * (size.width * 0.38 + size.width * 0.06);
      final optY =
          cardRect.top +
          size.height * 0.48 +
          row * (size.height * 0.10 + size.height * 0.04);

      final optRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(optX, optY, size.width * 0.38, size.height * 0.09),
        const Radius.circular(7),
      );

      canvas.drawRRect(optRect, Paint()..color = optColors[i]);
      canvas.drawRRect(
        optRect,
        Paint()
          ..color = optBorders[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = i == 2 ? 1.8 : 1.0,
      );

      // Label huruf opsi (A, B, C, D)
      final tp = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(65 + i),
          style: TextStyle(
            fontSize: size.width * 0.055,
            fontWeight: FontWeight.bold,
            color: i == 2
                ? const Color(0xFF22C55E)
                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(optX + size.width * 0.06, optY + size.height * 0.025),
      );
    }

    // ── Dekorasi dot sudut kanan bawah ────────────────────────────────────
    final dotPaint = Paint()..color = primaryColor.withValues(alpha: 0.20);
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(
          cardRect.right - size.width * 0.05 - i * size.width * 0.045,
          cardRect.bottom - size.height * 0.04,
        ),
        size.width * 0.015,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_QuizCardPainter old) =>
      old.primaryColor != primaryColor ||
      old.secondaryColor != secondaryColor ||
      old.isDark != isDark;
}
