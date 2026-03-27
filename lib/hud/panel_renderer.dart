import 'dart:ui' as ui;

import 'package:d4_dark_ds/d4_dark_ds.dart';
import 'package:flutter/painting.dart'
    show TextPainter, TextDirection, TextStyle, TextSpan, FontWeight, Shadow;

/// Shared rendering utilities for overlay panels, buttons, and text.
///
/// Centralises the Design System values so every overlay draws consistently.
abstract class PanelRenderer {
  // ── Overlay background ──────────────────────────────────────────────

  static void drawOverlayBackground(ui.Canvas canvas, double w, double h) {
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, w, h),
      ui.Paint()..color = D4DsColors.overlay,
    );
  }

  // ── Panel ───────────────────────────────────────────────────────────

  static void drawPanel(
    ui.Canvas canvas,
    ui.Rect rect, {
    String title = 'SYSTEM',
  }) {
    final rrect = ui.RRect.fromRectAndRadius(
      rect,
      ui.Radius.circular(D4DsRadius.dialog),
    );

    // Cyan glow (design system: blur 12, alpha 0.4)
    canvas.drawRRect(
      rrect,
      ui.Paint()
        ..color = D4DsColors.glowCyan
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = ui.MaskFilter.blur(
          ui.BlurStyle.normal,
          D4DsGlow.card.blurRadius,
        ),
    );

    // Body fill — surface color
    canvas.drawRRect(rrect, ui.Paint()..color = D4DsColors.surface);

    // Border — cyan 20%
    canvas.drawRRect(
      rrect,
      ui.Paint()
        ..color = D4DsColors.borderCyan
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Top edge highlight
    canvas.drawLine(
      ui.Offset(rect.left + 20, rect.top),
      ui.Offset(rect.right - 20, rect.top),
      ui.Paint()
        ..color = const ui.Color.fromARGB(60, 0, 255, 255)
        ..strokeWidth = 2.0
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3),
    );

    // Corner brackets (L-shapes — sci-fi FUI signature)
    final cornerPaint = ui.Paint()
      ..color = const ui.Color.fromARGB(140, 0, 255, 255)
      ..strokeWidth = 1.5
      ..strokeCap = ui.StrokeCap.square;
    const arm = 14.0;
    final l = rect.left;
    final r = rect.right;
    final t = rect.top;
    final b = rect.bottom;
    canvas.drawLine(ui.Offset(l, t), ui.Offset(l + arm, t), cornerPaint);
    canvas.drawLine(ui.Offset(l, t), ui.Offset(l, t + arm), cornerPaint);
    canvas.drawLine(ui.Offset(r, t), ui.Offset(r - arm, t), cornerPaint);
    canvas.drawLine(ui.Offset(r, t), ui.Offset(r, t + arm), cornerPaint);
    canvas.drawLine(ui.Offset(l, b), ui.Offset(l + arm, b), cornerPaint);
    canvas.drawLine(ui.Offset(l, b), ui.Offset(l, b - arm), cornerPaint);
    canvas.drawLine(ui.Offset(r, b), ui.Offset(r - arm, b), cornerPaint);
    canvas.drawLine(ui.Offset(r, b), ui.Offset(r, b - arm), cornerPaint);

    // Tick marks along edges
    final tickPaint = ui.Paint()
      ..color = const ui.Color.fromARGB(40, 0, 255, 255)
      ..strokeWidth = 1.0;
    for (double x = rect.left + 30; x < rect.right - 30; x += 20) {
      canvas.drawLine(
        ui.Offset(x, rect.top),
        ui.Offset(x, rect.top + 4),
        tickPaint,
      );
    }
    for (double x = rect.left + 30; x < rect.right - 30; x += 20) {
      canvas.drawLine(
        ui.Offset(x, rect.bottom),
        ui.Offset(x, rect.bottom - 4),
        tickPaint,
      );
    }

    // Title label — small, top-center, floating above the top edge
    final tp = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: ui.Color.fromARGB(70, 0, 255, 255),
          fontSize: 10,
          fontFamily: D4DsTypography.monoFont,
          letterSpacing: 2.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final titleBgRect = ui.Rect.fromCenter(
      center: ui.Offset(rect.center.dx, rect.top),
      width: tp.width + 16,
      height: 14,
    );
    canvas.drawRect(titleBgRect, ui.Paint()..color = D4DsColors.surface);
    tp.paint(
      canvas,
      ui.Offset(rect.center.dx - tp.width / 2, rect.top - tp.height / 2),
    );
  }

  // ── Scanlines ───────────────────────────────────────────────────────

  static void drawScanlines(ui.Canvas canvas, ui.Rect rect) {
    final paint = ui.Paint()..color = const ui.Color.fromARGB(5, 0, 255, 255);
    for (double y = rect.top; y < rect.bottom; y += 3) {
      canvas.drawLine(ui.Offset(rect.left, y), ui.Offset(rect.right, y), paint);
    }
  }

  // ── Glow button ─────────────────────────────────────────────────────

  static void drawGlowButton(
    ui.Canvas canvas,
    ui.Rect rect,
    String label,
    ui.Color textColor, {
    double fontSize = 15,
    double letterSpacing = 1.5,
  }) {
    final rrect = ui.RRect.fromRectAndRadius(
      rect,
      ui.Radius.circular(D4DsRadius.button),
    );

    // Glow (design system: blur 16, alpha 0.4)
    canvas.drawRRect(
      rrect,
      ui.Paint()
        ..color = D4DsColors.glowCyan
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..maskFilter = ui.MaskFilter.blur(
          ui.BlurStyle.normal,
          D4DsGlow.button.blurRadius,
        ),
    );

    // Fill — cyan 10%
    canvas.drawRRect(rrect, ui.Paint()..color = const ui.Color(0x1A00FFFF));

    // Border — 1.2px solid cyan
    canvas.drawRRect(
      rrect,
      ui.Paint()
        ..color = const ui.Color(0xFF00FFFF)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Text
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontFamily: D4DsTypography.monoFont,
          fontWeight: FontWeight.bold,
          letterSpacing: letterSpacing,
          shadows: [
            Shadow(color: textColor.withValues(alpha: 0.6), blurRadius: 8),
            Shadow(color: textColor.withValues(alpha: 0.3), blurRadius: 16),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      ui.Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2),
    );
  }

  // ── Outline button (secondary) ──────────────────────────────────────

  static void drawOutlineButton(
    ui.Canvas canvas,
    ui.Rect rect,
    String label,
    ui.Color textColor, {
    double fontSize = 13,
    double letterSpacing = 1.5,
  }) {
    final rrect = ui.RRect.fromRectAndRadius(
      rect,
      ui.Radius.circular(D4DsRadius.button),
    );

    canvas.drawRRect(
      rrect,
      ui.Paint()
        ..color = D4DsColors.borderCyan
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontFamily: D4DsTypography.monoFont,
          fontWeight: FontWeight.bold,
          letterSpacing: letterSpacing,
          shadows: [
            Shadow(color: textColor.withValues(alpha: 0.6), blurRadius: 8),
            Shadow(color: textColor.withValues(alpha: 0.3), blurRadius: 16),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      ui.Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2),
    );
  }

  // ── Tron title (multi-layer glow text) ──────────────────────────────

  static void drawTronTitle(
    ui.Canvas canvas,
    String text,
    double cx,
    double cy,
    double fontSize, {
    double letterSpacing = 4.0,
  }) {
    // Layer 1: Wide glow
    _drawForegroundText(
      canvas,
      text,
      cx,
      cy,
      fontSize,
      letterSpacing,
      ui.Paint()
        ..color = const ui.Color.fromARGB(50, 0, 255, 255)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 16),
    );
    // Layer 2: Medium glow
    _drawForegroundText(
      canvas,
      text,
      cx,
      cy,
      fontSize,
      letterSpacing,
      ui.Paint()
        ..color = const ui.Color.fromARGB(100, 0, 255, 255)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6),
    );
    // Layer 3: Dark fill
    _drawForegroundText(
      canvas,
      text,
      cx,
      cy,
      fontSize,
      letterSpacing,
      ui.Paint()..color = const ui.Color(0xFF003844),
    );
    // Layer 4: Bright outline
    _drawForegroundText(
      canvas,
      text,
      cx,
      cy,
      fontSize,
      letterSpacing,
      ui.Paint()
        ..color = const ui.Color(0xDD00FFFF)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  static void _drawForegroundText(
    ui.Canvas canvas,
    String text,
    double cx,
    double cy,
    double fontSize,
    double letterSpacing,
    ui.Paint paint,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          foreground: paint,
          fontSize: fontSize,
          fontFamily: D4DsTypography.monoFont,
          fontWeight: FontWeight.bold,
          letterSpacing: letterSpacing,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, ui.Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  // ── Text helpers ────────────────────────────────────────────────────

  static void drawTextCentered(
    ui.Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    ui.Color color, {
    FontWeight weight = FontWeight.normal,
    bool glow = false,
    double letterSpacing = 0,
    List<Shadow>? shadows,
  }) {
    final tp = layoutText(
      text,
      fontSize,
      color,
      weight,
      glow: glow,
      letterSpacing: letterSpacing,
      shadows: shadows,
    );
    tp.paint(canvas, ui.Offset(x - tp.width / 2, y - tp.height / 2));
  }

  static void drawTextLeft(
    ui.Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    ui.Color color, {
    FontWeight weight = FontWeight.normal,
    bool glow = false,
    double letterSpacing = 0,
  }) {
    final tp = layoutText(
      text,
      fontSize,
      color,
      weight,
      glow: glow,
      letterSpacing: letterSpacing,
    );
    tp.paint(canvas, ui.Offset(x, y - tp.height / 2));
  }

  static TextPainter layoutText(
    String text,
    double fontSize,
    ui.Color color,
    FontWeight weight, {
    bool glow = false,
    double letterSpacing = 0,
    List<Shadow>? shadows,
  }) {
    final effectiveShadows =
        shadows ??
        (glow
            ? <Shadow>[
                Shadow(color: color.withValues(alpha: 0.6), blurRadius: 8),
                Shadow(color: color.withValues(alpha: 0.3), blurRadius: 16),
              ]
            : <Shadow>[]);
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          fontFamily: D4DsTypography.monoFont,
          letterSpacing: letterSpacing,
          shadows: effectiveShadows,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  // ── Separator line ──────────────────────────────────────────────────

  static void drawSeparator(
    ui.Canvas canvas,
    double left,
    double right,
    double y,
  ) {
    canvas.drawLine(
      ui.Offset(left, y),
      ui.Offset(right, y),
      ui.Paint()
        ..color = const ui.Color.fromARGB(26, 0, 255, 255)
        ..strokeWidth = 1.0,
    );
  }
}
