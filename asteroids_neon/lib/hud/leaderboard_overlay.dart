import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart'
    show TextPainter, TextDirection, TextStyle, TextSpan, FontWeight;

import '../core/game_config.dart';
import '../core/leaderboard.dart';

/// Displays the top 10 leaderboard. Tap to dismiss.
class LeaderboardOverlay extends PositionComponent
    with HasGameReference, DragCallbacks {
  final LeaderboardManager leaderboard;
  final void Function() onDismiss;

  LeaderboardOverlay({required this.leaderboard, required this.onDismiss});

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

    _drawText(canvas, 'LEADERBOARD', size.x / 2, 80, 36,
        GameConfig.arcadeYellow, FontWeight.bold);

    final entries = leaderboard.entries;
    if (entries.isEmpty) {
      _drawText(canvas, 'NO SCORES YET', size.x / 2, size.y / 2, 22,
          GameConfig.arcadeWhite, FontWeight.normal);
    } else {
      for (int i = 0; i < entries.length; i++) {
        final e = entries[i];
        final y = 140.0 + i * 42.0;
        final rank = '${i + 1}.'.padLeft(3);
        final name = e.name.padRight(4);
        final score = e.score.toString().padLeft(8);
        final text = '$rank $name $score';
        final color =
            i == 0 ? GameConfig.arcadeYellow : GameConfig.arcadeWhite;
        _drawText(canvas, text, size.x / 2, y, 22, color, FontWeight.normal);
      }
    }

    _drawText(canvas, 'TAP TO CLOSE', size.x / 2, size.y - 60, 18,
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
