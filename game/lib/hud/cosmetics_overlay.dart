import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart'
    show TextPainter, TextDirection, TextStyle, TextSpan, FontWeight;

import '../core/cosmetics_manager.dart';
import '../core/game_config.dart';

/// Ship color selection overlay. DragCallbacks + containsLocalPoint => true
/// to block inputs below.
class CosmeticsOverlay extends PositionComponent
    with HasGameReference, DragCallbacks {
  final CosmeticsManager cosmetics;
  final void Function() onDismiss;

  static const double _circleRadius = 30.0;

  /// Hit-test rects for each color circle (set in render).
  final List<ui.Rect> _circleRects = [];

  CosmeticsOverlay({required this.cosmetics, required this.onDismiss});

  @override
  Future<void> onLoad() async {
    size = game.size;
    position = Vector2.zero();
    priority = 300;
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final pos = event.localPosition;

    // Check if tap is on a color circle
    for (int i = 0; i < _circleRects.length; i++) {
      if (_circleRects[i].contains(ui.Offset(pos.x, pos.y))) {
        if (cosmetics.isUnlocked(i)) {
          cosmetics.select(i);
        }
        return; // Tapped on a circle — don't dismiss
      }
    }

    // Tap outside circles — dismiss
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
    final cy = size.y / 2;
    final colors = GameConfig.shipColors;
    final names = GameConfig.shipColorNames;
    final count = colors.length;
    final spacing = size.x / (count + 1);

    // Title
    _drawText(canvas, 'SHIP COLOR', cx, cy - 140, 36,
        GameConfig.shipColor, FontWeight.bold);

    // Rebuild circle rects each frame
    _circleRects.clear();

    for (int i = 0; i < count; i++) {
      final x = spacing * (i + 1);
      final y = cy;
      final color = colors[i];
      final unlocked = cosmetics.isUnlocked(i);
      final selected = cosmetics.selectedIndex == i;

      // Store hit-test rect
      _circleRects.add(ui.Rect.fromCircle(
        center: ui.Offset(x, y),
        radius: _circleRadius + 8,
      ));

      // Selected: outer ring
      if (selected) {
        canvas.drawCircle(
          ui.Offset(x, y),
          _circleRadius + 6,
          ui.Paint()
            ..color = const ui.Color(0xFFFFFFFF)
            ..style = ui.PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
      }

      // Color circle
      final opacity = unlocked ? 1.0 : 0.2;
      canvas.drawCircle(
        ui.Offset(x, y),
        _circleRadius,
        ui.Paint()
          ..color = color.withValues(alpha: opacity)
          ..style = ui.PaintingStyle.fill,
      );

      // Color name
      _drawText(canvas, names[i], x, y + _circleRadius + 20, 14,
          color.withValues(alpha: opacity), FontWeight.bold);

      // Locked label
      if (!unlocked && i - 1 < GameConfig.cosmeticUnlockWaves.length) {
        final wave = GameConfig.cosmeticUnlockWaves[i - 1];
        _drawText(canvas, 'WAVE $wave', x, y + _circleRadius + 42, 12,
            const ui.Color(0x88FFFFFF), FontWeight.normal);
      }
    }

    // Footer
    _drawText(canvas, 'TAP TO CLOSE', cx, size.y - 60, 18,
        const ui.Color(0x88FFFFFF), FontWeight.normal);
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
