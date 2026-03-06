import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart'
    show TextPainter, TextDirection, TextStyle, TextSpan, FontWeight;

import '../core/game_config.dart';

/// Credits screen. Tap to dismiss.
class CreditsOverlay extends PositionComponent
    with HasGameReference, DragCallbacks {
  final void Function() onDismiss;

  CreditsOverlay({required this.onDismiss});

  @override
  Future<void> onLoad() async {
    size = game.size;
    position = Vector2.zero();
    priority = 300;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    onDismiss();
    removeFromParent();
  }

  @override
  void render(ui.Canvas canvas) {
    // Background
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, size.x, size.y),
      ui.Paint()..color = const ui.Color(0xEE000011),
    );

    final cx = size.x / 2;

    _drawText(canvas, 'CREDITS', cx, 100, 40,
        GameConfig.arcadeYellow, FontWeight.bold);

    _drawText(canvas, 'NEON ASTEROIDS', cx, 180, 28,
        GameConfig.shipColor, FontWeight.bold);

    _drawText(canvas, 'Made with', cx, 240, 20,
        GameConfig.arcadeWhite, FontWeight.normal);
    _drawText(canvas, 'Flutter & Flame', cx, 270, 24,
        const ui.Color(0xFF00AAFF), FontWeight.bold);

    _drawText(canvas, 'Kevin Delfour', cx, 350, 26,
        GameConfig.arcadeWhite, FontWeight.bold);
    _drawText(canvas, 'TAP TO RETURN', cx, size.y - 60, 18,
        const ui.Color(0x88FFFFFF), FontWeight.normal);

    _drawText(canvas, 'Code by human + AI', cx, size.y - 100, 12,
        const ui.Color(0x66FFFFFF), FontWeight.normal);
  }

  void _drawText(ui.Canvas canvas, String text, double x, double y,
      double fontSize, ui.Color color, FontWeight weight) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, ui.Offset(x - tp.width / 2, y - tp.height / 2));
  }
}
