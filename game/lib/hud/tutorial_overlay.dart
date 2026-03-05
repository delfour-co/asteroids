import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart'
    show TextPainter, TextDirection, TextStyle, TextSpan, FontWeight;

import '../core/game_config.dart';

/// Full-screen tutorial overlay showing control positions with glow circles.
///
/// Shown on first launch. Tap anywhere to dismiss.
/// Uses DragCallbacks (same pattern as PauseOverlay) for multi-touch compat.
class TutorialOverlay extends PositionComponent
    with HasGameReference<FlameGame>, DragCallbacks {
  final void Function() onDismiss;

  TutorialOverlay({required this.onDismiss});

  @override
  Future<void> onLoad() async {
    size = game.size;
    position = Vector2.zero();
    priority = 250;
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    onDismiss();
    removeFromParent();
  }

  @override
  void render(ui.Canvas canvas) {
    final w = size.x;
    final h = size.y;

    // Semi-transparent background
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, w, h),
      ui.Paint()..color = const ui.Color(0xDD000011),
    );

    // "CONTROLS" title
    _drawText(canvas, 'CONTROLS', w / 2, 80, 48,
        GameConfig.shipColor, FontWeight.bold);

    // Control positions (same formulas as actual buttons)
    // Joystick: left:40, bottom:40, radius 75
    final joystickX = 40.0 + 75.0;
    final joystickY = h - 40.0 - 75.0;
    _drawGlowCircle(canvas, joystickX, joystickY, 80);
    _drawText(canvas, 'STEER', joystickX, joystickY - 100, 22,
        GameConfig.arcadeWhite, FontWeight.bold);

    // Thrust button: x - 60, y - 80
    final thrustX = w - 60;
    final thrustY = h - 80;
    _drawGlowCircle(canvas, thrustX, thrustY, 48);
    _drawText(canvas, 'THRUST', thrustX, thrustY + 55, 20,
        GameConfig.arcadeWhite, FontWeight.bold);

    // Fire button: x - 160, y - 80
    final fireX = w - 160;
    final fireY = h - 80;
    _drawGlowCircle(canvas, fireX, fireY, 48);
    _drawText(canvas, 'SHOOT', fireX, fireY + 55, 20,
        GameConfig.arcadeWhite, FontWeight.bold);

    // Dash button: x - 110, y - 160
    final dashX = w - 110;
    final dashY = h - 160;
    _drawGlowCircle(canvas, dashX, dashY, 38);
    _drawText(canvas, 'DASH', dashX, dashY - 50, 20,
        GameConfig.arcadeWhite, FontWeight.bold);

    // Pause button: x - 60, 40
    final pauseX = w - 60;
    const pauseY = 40.0 + 22.0;
    _drawGlowCircle(canvas, pauseX, pauseY, 28);
    _drawText(canvas, 'PAUSE', pauseX, pauseY + 40, 18,
        GameConfig.arcadeWhite, FontWeight.bold);

    // Pulsing "TAP TO PLAY"
    final ms = DateTime.now().millisecondsSinceEpoch;
    final pulse = 0.5 + sin(ms / 300.0) * 0.5;
    final tapColor = ui.Color.fromARGB(
      (pulse * 255).toInt(), 255, 255, 255,
    );
    _drawText(canvas, 'TAP TO PLAY', w / 2, h / 2 + 40, 28,
        tapColor, FontWeight.normal);
  }

  void _drawGlowCircle(ui.Canvas canvas, double x, double y, double radius) {
    // Outer glow
    canvas.drawCircle(
      ui.Offset(x, y),
      radius,
      ui.Paint()
        ..color = GameConfig.shipColor.withValues(alpha: 0.15)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 20),
    );
    // Ring
    canvas.drawCircle(
      ui.Offset(x, y),
      radius,
      ui.Paint()
        ..color = GameConfig.shipColor.withValues(alpha: 0.7)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
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
