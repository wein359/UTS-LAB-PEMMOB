import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Kategori hasil kuis — menentukan ilustrasi yang ditampilkan.
enum ResultTier {
  perfect,   // 100%          → trofi + bintang
  great,     // 70% – 99%     → medali + confetti
  good,      // 40% – 69%     → buku + pensil
  tryAgain,  // 0%  – 39%     → roket kecil "terus semangat"
}

/// [ResultIllustration] — Ilustrasi hasil kuis digambar dengan [CustomPainter].
///
/// Tidak butuh file gambar eksternal.
/// Pilih tier berdasarkan persentase skor:
/// ```dart
/// ResultIllustration(
///   tier: ResultTier.fromPercentage(percentage),
///   size: 200,
/// )
/// ```
class ResultIllustration extends StatefulWidget {
  final ResultTier tier;
  final double size;

  const ResultIllustration({
    super.key,
    required this.tier,
    this.size = 200,
  });

  /// Factory helper — konversi persentase ke [ResultTier].
  static ResultTier tierFromPercentage(int percentage) {
    if (percentage == 100) return ResultTier.perfect;
    if (percentage >= 70)  return ResultTier.great;
    if (percentage >= 40)  return ResultTier.good;
    return ResultTier.tryAgain;
  }

  @override
  State<ResultIllustration> createState() => _ResultIllustrationState();
}

class _ResultIllustrationState extends State<ResultIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _floatAnim;
  late final Animation<double> _rotateAnim;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -7.0, end: 7.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _rotateAnim = Tween<double>(begin: -0.04, end: 0.04).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Stack(
          alignment: Alignment.center,
          children: [
            // Lingkaran latar berdenyut
            Transform.scale(
              scale: _pulseAnim.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _tierColor(widget.tier)
                      .withValues(alpha: isDark ? 0.13 : 0.09),
                ),
              ),
            ),
            // Lingkaran tengah
            Container(
              width: widget.size * 0.76,
              height: widget.size * 0.76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _tierColor(widget.tier)
                    .withValues(alpha: isDark ? 0.20 : 0.13),
              ),
            ),
            // Ilustrasi utama mengambang
            Transform.translate(
              offset: Offset(0, _floatAnim.value),
              child: Transform.rotate(
                angle: _rotateAnim.value,
                child: CustomPaint(
                  size: Size(widget.size * 0.60, widget.size * 0.60),
                  painter: _TierPainter(
                    tier: widget.tier,
                    primary: primary,
                    isDark: isDark,
                    animValue: _ctrl.value,
                  ),
                ),
              ),
            ),
            // Partikel dekorasi (bintang / confetti kecil)
            ..._buildParticles(widget.tier, widget.size, isDark),
          ],
        ),
      ),
    );
  }

  // ── Partikel melayang di sekitar ilustrasi ─────────────────────────────
  List<Widget> _buildParticles(ResultTier tier, double size, bool isDark) {
    if (tier == ResultTier.tryAgain || tier == ResultTier.good) return [];

    final particleData = tier == ResultTier.perfect
        ? [
            _Particle(top: 0.06, left: 0.14, icon: Icons.star_rounded,    iconSize: 0.10, color: const Color(0xFFFBBF24)),
            _Particle(top: 0.08, right: 0.12, icon: Icons.star_rounded,   iconSize: 0.08, color: const Color(0xFFF59E0B)),
            _Particle(bottom: 0.10, left: 0.10, icon: Icons.star_rounded, iconSize: 0.07, color: const Color(0xFFFCD34D)),
            _Particle(bottom: 0.08, right: 0.10, icon: Icons.star_rounded,iconSize: 0.09, color: const Color(0xFFFBBF24)),
          ]
        : [
            _Particle(top: 0.06, left: 0.12,    icon: Icons.circle,        iconSize: 0.06, color: const Color(0xFF4F46E5)),
            _Particle(top: 0.10, right: 0.10,   icon: Icons.circle,        iconSize: 0.05, color: const Color(0xFF06B6D4)),
            _Particle(bottom: 0.08, left: 0.08, icon: Icons.change_history,iconSize: 0.07, color: const Color(0xFFF59E0B)),
            _Particle(bottom: 0.06, right: 0.08,icon: Icons.circle,        iconSize: 0.06, color: const Color(0xFF22C55E)),
          ];

    return particleData.map((p) {
      final offset = Offset(
        math.sin(_ctrl.value * math.pi * 2 + p.phase) * size * 0.03,
        math.cos(_ctrl.value * math.pi * 2 + p.phase) * size * 0.04,
      );
      return Positioned(
        top:    p.top    != null ? size * p.top!    : null,
        bottom: p.bottom != null ? size * p.bottom! : null,
        left:   p.left   != null ? size * p.left!   : null,
        right:  p.right  != null ? size * p.right!  : null,
        child: Transform.translate(
          offset: offset,
          child: Icon(p.icon, size: size * p.iconSize, color: p.color),
        ),
      );
    }).toList();
  }

  Color _tierColor(ResultTier tier) {
    switch (tier) {
      case ResultTier.perfect:   return const Color(0xFFFBBF24);
      case ResultTier.great:     return const Color(0xFF22C55E);
      case ResultTier.good:      return const Color(0xFF06B6D4);
      case ResultTier.tryAgain:  return const Color(0xFF4F46E5);
    }
  }
}

// ─── Data partikel ────────────────────────────────────────────────────────
class _Particle {
  final double? top, bottom, left, right;
  final IconData icon;
  final double iconSize;
  final Color color;
  final double phase;

  _Particle({
    this.top, this.bottom, this.left, this.right,
    required this.icon,
    required this.iconSize,
    required this.color,
    double? phase,
  }) : phase = phase ?? (top ?? 0) + (left ?? 0);
}

// ─── CustomPainter per tier ───────────────────────────────────────────────
class _TierPainter extends CustomPainter {
  final ResultTier tier;
  final Color primary;
  final bool isDark;
  final double animValue;

  const _TierPainter({
    required this.tier,
    required this.primary,
    required this.isDark,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (tier) {
      case ResultTier.perfect:
        _drawTrophy(canvas, size);
      case ResultTier.great:
        _drawMedal(canvas, size);
      case ResultTier.good:
        _drawBook(canvas, size);
      case ResultTier.tryAgain:
        _drawRocket(canvas, size);
    }
  }

  // ── Trofi ─────────────────────────────────────────────────────────────
  void _drawTrophy(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final goldDark  = const Color(0xFFD97706);
    final goldLight = const Color(0xFFFBBF24);
    final goldPaint = Paint()..color = goldLight..style = PaintingStyle.fill;
    final borderPaint = Paint()..color = goldDark..style = PaintingStyle.stroke..strokeWidth = size.width * 0.022;

    // Badan trofi
    final bodyPath = Path()
      ..moveTo(cx - size.width * 0.28, size.height * 0.18)
      ..lineTo(cx - size.width * 0.28, size.height * 0.52)
      ..quadraticBezierTo(cx - size.width * 0.28, size.height * 0.72, cx, size.height * 0.72)
      ..quadraticBezierTo(cx + size.width * 0.28, size.height * 0.72, cx + size.width * 0.28, size.height * 0.52)
      ..lineTo(cx + size.width * 0.28, size.height * 0.18)
      ..close();
    canvas.drawPath(bodyPath, goldPaint);
    canvas.drawPath(bodyPath, borderPaint);

    // Gagang kiri-kanan
    final handlePaint = Paint()..color = goldDark..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.040..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx - size.width * 0.28, size.height * 0.35), width: size.width * 0.20, height: size.height * 0.26),
      math.pi / 2, math.pi, false, handlePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx + size.width * 0.28, size.height * 0.35), width: size.width * 0.20, height: size.height * 0.26),
      math.pi / 2, -math.pi, false, handlePaint,
    );

    // Kaki + alas
    final basePaint = Paint()..color = goldLight;
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, size.height * 0.84), width: size.width * 0.44, height: size.height * 0.075),
      const Radius.circular(4),
    ), basePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, size.height * 0.78), width: size.width * 0.12, height: size.height * 0.10),
      const Radius.circular(4),
    ), basePaint..color = goldDark);

    // Bintang di tengah trofi
    _drawStar(canvas, Offset(cx, size.height * 0.44), size.width * 0.12,
        const Color(0xFFFCD34D), const Color(0xFFD97706));
  }

  // ── Medali ────────────────────────────────────────────────────────────
  void _drawMedal(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final green  = const Color(0xFF22C55E);
    final greenD = const Color(0xFF15803D);

    // Pita
    final ribbonPath = Path()
      ..moveTo(cx - size.width * 0.10, size.height * 0.10)
      ..lineTo(cx - size.width * 0.10, size.height * 0.45)
      ..lineTo(cx, size.height * 0.38)
      ..lineTo(cx + size.width * 0.10, size.height * 0.45)
      ..lineTo(cx + size.width * 0.10, size.height * 0.10)
      ..close();
    canvas.drawPath(ribbonPath, Paint()..color = const Color(0xFF4F46E5));
    canvas.drawLine(Offset(cx, size.height * 0.10), Offset(cx, size.height * 0.45),
        Paint()..color = const Color(0xFF6366F1)..strokeWidth = size.width * 0.015);

    // Lingkaran medali
    canvas.drawCircle(Offset(cx, size.height * 0.65), size.width * 0.28,
        Paint()..color = greenD..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, size.height * 0.65), size.width * 0.24,
        Paint()..color = green..style = PaintingStyle.fill);

    // Angka "1" di medali
    final tp = TextPainter(
      text: TextSpan(text: '1',
          style: TextStyle(color: Colors.white, fontSize: size.width * 0.22, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, size.height * 0.54));
  }

  // ── Buku + pensil ─────────────────────────────────────────────────────
  void _drawBook(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cyan  = const Color(0xFF06B6D4);
    final cyanD = const Color(0xFF0891B2);

    // Buku kanan (halaman)
    final pageR = RRect.fromRectAndCorners(
      Rect.fromLTWH(cx, size.height * 0.20, size.width * 0.36, size.height * 0.58),
      topRight: const Radius.circular(10), bottomRight: const Radius.circular(10),
    );
    canvas.drawRRect(pageR, Paint()..color = Colors.white.withValues(alpha: isDark ? 0.88 : 1.0));
    // Garis halaman
    for (int i = 1; i <= 4; i++) {
      canvas.drawLine(
        Offset(cx + size.width * 0.06, size.height * (0.30 + i * 0.08)),
        Offset(cx + size.width * 0.30, size.height * (0.30 + i * 0.08)),
        Paint()..color = Colors.grey.shade300..strokeWidth = size.width * 0.015,
      );
    }

    // Buku kiri (cover)
    final coverR = RRect.fromRectAndCorners(
      Rect.fromLTWH(size.width * 0.14, size.height * 0.18, size.width * 0.38, size.height * 0.62),
      topLeft: const Radius.circular(10), bottomLeft: const Radius.circular(10),
    );
    canvas.drawRRect(coverR, Paint()..color = cyan);
    // Stripe cover
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.18, size.height * 0.28, size.width * 0.26, size.height * 0.042),
      const Radius.circular(4),
    ), Paint()..color = Colors.white.withValues(alpha: 0.30));
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.18, size.height * 0.36, size.width * 0.18, size.height * 0.030),
      const Radius.circular(4),
    ), Paint()..color = Colors.white.withValues(alpha: 0.20));

    // Spine buku
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - size.width * 0.025, size.height * 0.18, size.width * 0.05, size.height * 0.62),
      const Radius.circular(3),
    ), Paint()..color = cyanD);

    // Pensil
    final penPath = Path()
      ..moveTo(size.width * 0.68, size.height * 0.22)
      ..lineTo(size.width * 0.80, size.height * 0.10)
      ..lineTo(size.width * 0.86, size.height * 0.16)
      ..lineTo(size.width * 0.74, size.height * 0.28)
      ..close();
    canvas.drawPath(penPath, Paint()..color = const Color(0xFFFBBF24));
    // Ujung pensil
    final tipPath = Path()
      ..moveTo(size.width * 0.68, size.height * 0.22)
      ..lineTo(size.width * 0.64, size.height * 0.30)
      ..lineTo(size.width * 0.74, size.height * 0.28)
      ..close();
    canvas.drawPath(tipPath, Paint()..color = const Color(0xFFD97706));
    // Mata pensil
    canvas.drawCircle(Offset(size.width * 0.66, size.height * 0.28),
        size.width * 0.022, Paint()..color = const Color(0xFF1E1B4B));
  }

  // ── Roket ─────────────────────────────────────────────────────────────
  void _drawRocket(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final indigo  = const Color(0xFF4F46E5);
    final indigoD = const Color(0xFF3730A3);

    // Api roket (animasi berkedip dengan animValue)
    final flamePulse = 0.75 + math.sin(animValue * math.pi * 4) * 0.25;
    final flamePath = Path()
      ..moveTo(cx - size.width * 0.09, size.height * 0.76)
      ..quadraticBezierTo(cx - size.width * 0.05, size.height * (0.86 + 0.06 * flamePulse),
          cx, size.height * (0.90 + 0.04 * flamePulse))
      ..quadraticBezierTo(cx + size.width * 0.05, size.height * (0.86 + 0.06 * flamePulse),
          cx + size.width * 0.09, size.height * 0.76)
      ..close();
    canvas.drawPath(flamePath, Paint()..color = const Color(0xFFF97316));
    // Inner flame
    final innerFlamePath = Path()
      ..moveTo(cx - size.width * 0.050, size.height * 0.76)
      ..quadraticBezierTo(cx, size.height * (0.84 + 0.04 * flamePulse), cx + size.width * 0.050, size.height * 0.76)
      ..close();
    canvas.drawPath(innerFlamePath, Paint()..color = const Color(0xFFFBBF24));

    // Badan roket
    final bodyPath = Path()
      ..moveTo(cx, size.height * 0.10)
      ..quadraticBezierTo(cx + size.width * 0.22, size.height * 0.28,
          cx + size.width * 0.20, size.height * 0.76)
      ..lineTo(cx - size.width * 0.20, size.height * 0.76)
      ..quadraticBezierTo(cx - size.width * 0.22, size.height * 0.28,
          cx, size.height * 0.10)
      ..close();
    canvas.drawPath(bodyPath, Paint()..color = indigo);

    // Sayap kiri
    final wingL = Path()
      ..moveTo(cx - size.width * 0.20, size.height * 0.56)
      ..lineTo(cx - size.width * 0.40, size.height * 0.76)
      ..lineTo(cx - size.width * 0.20, size.height * 0.76)
      ..close();
    canvas.drawPath(wingL, Paint()..color = indigoD);
    // Sayap kanan
    final wingR = Path()
      ..moveTo(cx + size.width * 0.20, size.height * 0.56)
      ..lineTo(cx + size.width * 0.40, size.height * 0.76)
      ..lineTo(cx + size.width * 0.20, size.height * 0.76)
      ..close();
    canvas.drawPath(wingR, Paint()..color = indigoD);

    // Jendela roket
    canvas.drawCircle(Offset(cx, size.height * 0.42), size.width * 0.10,
        Paint()..color = const Color(0xFF0EA5E9));
    canvas.drawCircle(Offset(cx, size.height * 0.42), size.width * 0.10,
        Paint()..color = Colors.white.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke..strokeWidth = size.width * 0.018);
    // Kilap jendela
    canvas.drawCircle(Offset(cx - size.width * 0.04, size.height * 0.38),
        size.width * 0.025, Paint()..color = Colors.white.withValues(alpha: 0.60));

    // Garis stripe badan
    canvas.drawLine(
      Offset(cx, size.height * 0.56), Offset(cx, size.height * 0.76),
      Paint()..color = indigoD..strokeWidth = size.width * 0.016..strokeCap = StrokeCap.round,
    );
  }

  // ── Helper: gambar bintang ─────────────────────────────────────────────
  void _drawStar(Canvas canvas, Offset center, double radius, Color fill, Color stroke) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final r = i.isEven ? radius : radius * 0.45;
      final angle = (i * math.pi / 5) - math.pi / 2;
      final pt = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(path, Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(_TierPainter old) =>
      old.tier != tier || old.isDark != isDark || old.animValue != animValue;
}
