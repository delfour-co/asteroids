import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart'
    show TextPainter, TextDirection, TextStyle, TextSpan, FontWeight;

import 'fragment_data.dart';

/// Full-screen overlay showing a single narrative fragment in retro terminal style.
///
/// Uses DateTime.now() for pulse animation (game might be paused).
/// DragCallbacks + containsLocalPoint => true to block inputs below.
class FragmentOverlay extends PositionComponent
    with HasGameReference<FlameGame>, DragCallbacks {
  final NarrativeFragment fragment;
  final void Function() onDismiss;

  FragmentOverlay({required this.fragment, required this.onDismiss});

  static const _titleY = 80.0;
  static const _fragmentTitleY = 130.0;
  static const _contentTop = 180.0;
  static const _lineHeight = 28.0;
  static const _footerOffset = 50.0;

  @override
  Future<void> onLoad() async {
    size = game.size;
    position = Vector2.zero();
    priority = 350;
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

    // Dark green-tinted background
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, w, h),
      ui.Paint()..color = const ui.Color(0xEE001100),
    );

    final cx = w / 2;

    // "MEMORY FRAGMENT" title in green
    _drawTextCentered(canvas, 'MEMORY FRAGMENT', cx, _titleY, 32,
        const ui.Color(0xFF00FF66), FontWeight.bold);

    // Fragment title in cyan
    _drawTextCentered(canvas, fragment.title, cx, _fragmentTitleY, 24,
        const ui.Color(0xFF00FFFF), FontWeight.bold);

    // Fragment text line by line in green monospace
    final lines = fragment.text.split('\n');
    double y = _contentTop;
    for (final line in lines) {
      _drawTextCentered(canvas, line, cx, y, 18,
          const ui.Color(0xFF00FF66), FontWeight.normal);
      y += _lineHeight;
    }

    // Pulsing "TAP TO CONTINUE" at bottom
    final ms = DateTime.now().millisecondsSinceEpoch;
    final pulse = 0.5 + sin(ms / 300.0) * 0.5;
    final pulseColor = ui.Color.fromARGB(
      (pulse * 255).toInt(), 0, 255, 102,
    );
    _drawTextCentered(canvas, 'TAP TO CONTINUE', cx, h - _footerOffset, 18,
        pulseColor, FontWeight.normal);
  }

  void _drawTextCentered(ui.Canvas canvas, String text, double x, double y,
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
