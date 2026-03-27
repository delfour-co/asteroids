import 'dart:ui' as ui;

import 'package:d4_dark_ds/d4_dark_ds.dart';
import 'package:flutter/material.dart';

/// Full-screen animated neon "D4 Games" splash (skippable on tap).
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 2500),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _finish();
          }
        });
    _controller.forward();
  }

  void _finish() {
    if (_done) return;
    _done = true;
    widget.onComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _finish,
      child: Container(
        color: Colors.black,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: Size.infinite,
              painter: _NeonLogoPainter(progress: _controller.value),
            );
          },
        ),
      ),
    );
  }
}

/// Paints the "D4" logo and "Games" text with neon glow animation.
class _NeonLogoPainter extends CustomPainter {
  final double progress;

  static const _cyan = D4DsColors.cyan;

  _NeonLogoPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // --- Phase timing ---
    // Phase 1: 0.0–0.32  (0–0.8s)   D4 draws on
    // Phase 2: 0.32–0.60 (0.8–1.5s) "Games" fades in
    // Phase 3: 0.60–1.0  (1.5–2.5s) hold then fade out

    final double d4DrawProgress = (progress / 0.32).clamp(0.0, 1.0);
    final double gamesFadeIn = ((progress - 0.32) / 0.28).clamp(0.0, 1.0);

    // Fade out in the last 0.6s (progress 0.76–1.0)
    final double fadeOut = progress > 0.76
        ? ((progress - 0.76) / 0.24).clamp(0.0, 1.0)
        : 0.0;
    final double masterAlpha = 1.0 - fadeOut;

    if (masterAlpha <= 0) return;

    // --- Sizing ---
    final double logoHeight = size.height * 0.22;
    final double strokeW = logoHeight * 0.08;
    final double glowRadius = strokeW * 1.8;

    // "D4" is centered, slightly above middle
    final double d4Y = cy - logoHeight * 0.3;

    // --- Draw "D" ---
    _drawD(
      canvas,
      cx - logoHeight * 0.65,
      d4Y - logoHeight / 2,
      logoHeight,
      strokeW,
      glowRadius,
      d4DrawProgress,
      masterAlpha,
    );

    // --- Draw "4" ---
    _draw4(
      canvas,
      cx + logoHeight * 0.1,
      d4Y - logoHeight / 2,
      logoHeight,
      strokeW,
      glowRadius,
      d4DrawProgress,
      masterAlpha,
    );

    // --- Draw "Games" ---
    if (gamesFadeIn > 0) {
      _drawGamesText(
        canvas,
        cx,
        d4Y + logoHeight / 2 + logoHeight * 0.25,
        logoHeight * 0.22,
        strokeW * 0.5,
        glowRadius * 0.6,
        gamesFadeIn * masterAlpha,
      );
    }
  }

  void _drawD(
    Canvas canvas,
    double x,
    double y,
    double h,
    double strokeW,
    double glowR,
    double drawProgress,
    double alpha,
  ) {
    // "D" consists of: vertical line left (0–0.4) + arc on right (0.4–1.0)
    final path = Path();

    final double w = h * 0.55;

    // Vertical line: from bottom to top
    final vertP = (drawProgress / 0.4).clamp(0.0, 1.0);
    if (vertP > 0) {
      path.moveTo(x, y + h);
      path.lineTo(x, y + h - h * vertP);
    }

    // Arc: top horizontal + smooth D curve + bottom horizontal
    final arcP = ((drawProgress - 0.4) / 0.6).clamp(0.0, 1.0);
    if (arcP > 0) {
      final arcPath = Path();
      arcPath.moveTo(x, y);
      arcPath.lineTo(x + w * 0.3, y);
      // Single smooth cubic for the entire right-side arc
      arcPath.cubicTo(
        x + w * 1.15,
        y, // control 1 — far right at top
        x + w * 1.15,
        y + h, // control 2 — far right at bottom
        x + w * 0.3,
        y + h, // end — bottom horizontal start
      );
      arcPath.lineTo(x, y + h);

      // Extract partial arc based on progress
      final metrics = arcPath.computeMetrics().first;
      final partialArc = metrics.extractPath(0, metrics.length * arcP);
      path.addPath(partialArc, Offset.zero);
    }

    _drawNeonPath(canvas, path, strokeW, glowR, alpha);
  }

  void _draw4(
    Canvas canvas,
    double x,
    double y,
    double h,
    double strokeW,
    double glowR,
    double drawProgress,
    double alpha,
  ) {
    final double w = h * 0.55;

    // "4" consists of: diagonal down-right (0–0.35),
    // horizontal crossbar right (0.35–0.6),
    // vertical full height at ~70% x (0.6–1.0)

    final path = Path();

    // Diagonal: from top of vertical stem down-left to crossbar level
    final diagP = (drawProgress / 0.35).clamp(0.0, 1.0);
    final crossY = y + h * 0.6; // crossbar Y position
    final stemX = x + w * 0.7; // vertical stem X position
    if (diagP > 0) {
      path.moveTo(stemX, y);
      path.lineTo(stemX + (x - stemX) * diagP, y + (crossY - y) * diagP);
    }

    // Horizontal crossbar
    final crossP = ((drawProgress - 0.35) / 0.25).clamp(0.0, 1.0);
    if (crossP > 0) {
      final crossPath = Path();
      crossPath.moveTo(x, crossY);
      crossPath.lineTo(x + w * crossP, crossY);
      path.addPath(crossPath, Offset.zero);
    }

    // Vertical line (full height) at ~70% width
    final vertP = ((drawProgress - 0.6) / 0.4).clamp(0.0, 1.0);
    if (vertP > 0) {
      final vx = x + w * 0.7;
      final vertPath = Path();
      vertPath.moveTo(vx, y);
      vertPath.lineTo(vx, y + h * vertP);
      path.addPath(vertPath, Offset.zero);
    }

    _drawNeonPath(canvas, path, strokeW, glowR, alpha);
  }

  void _drawGamesText(
    Canvas canvas,
    double cx,
    double y,
    double fontSize,
    double strokeW,
    double glowR,
    double alpha,
  ) {
    final textStyle = ui.TextStyle(
      color: _cyan.withValues(alpha: alpha * 0.85),
      fontSize: fontSize,
      fontFamily: D4DsTypography.monoFont,
      letterSpacing: fontSize * 0.3,
    );

    final paragraphBuilder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(
              textAlign: TextAlign.left,
              fontFamily: D4DsTypography.monoFont,
            ),
          )
          ..pushStyle(textStyle)
          ..addText('Games');

    final paragraph = paragraphBuilder.build()
      ..layout(const ui.ParagraphConstraints(width: double.infinity));

    final textW = paragraph.longestLine;
    final textX = cx - textW / 2;
    final textY = y;

    // Glow layer
    canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, alpha));

    // Draw text as glow by painting it offset multiple times
    for (final offset in [
      const Offset(-1, 0),
      const Offset(1, 0),
      const Offset(0, -1),
      const Offset(0, 1),
    ]) {
      canvas.drawParagraph(
        paragraph,
        Offset(textX + offset.dx, textY + offset.dy),
      );
    }

    canvas.restore();

    // Solid text on top
    final solidStyle = ui.TextStyle(
      color: _cyan.withValues(alpha: alpha),
      fontSize: fontSize,
      fontFamily: D4DsTypography.monoFont,
      letterSpacing: fontSize * 0.3,
      shadows: [
        Shadow(
          color: _cyan.withValues(alpha: 0.6 * alpha),
          blurRadius: glowR,
        ),
        Shadow(
          color: _cyan.withValues(alpha: 0.3 * alpha),
          blurRadius: glowR * 2,
        ),
      ],
    );

    final solidBuilder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(
              textAlign: TextAlign.left,
              fontFamily: D4DsTypography.monoFont,
            ),
          )
          ..pushStyle(solidStyle)
          ..addText('Games');

    final solidParagraph = solidBuilder.build()
      ..layout(const ui.ParagraphConstraints(width: double.infinity));

    canvas.drawParagraph(solidParagraph, Offset(textX, textY));
  }

  void _drawNeonPath(
    Canvas canvas,
    Path path,
    double strokeW,
    double glowR,
    double alpha,
  ) {
    if (alpha <= 0) return;

    // Glow layer
    final glowPaint = Paint()
      ..color = _cyan.withValues(alpha: 0.6 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW + 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowR);

    // Solid core
    final solidPaint = Paint()
      ..color = _cyan.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, solidPaint);
  }

  @override
  bool shouldRepaint(_NeonLogoPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
