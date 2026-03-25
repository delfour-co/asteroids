import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart' show FontWeight;

import '../core/game_config.dart';
import '../core/leaderboard.dart';
import 'panel_renderer.dart';

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
    PanelRenderer.drawOverlayBackground(canvas, size.x, size.y);

    // Panel
    final panelRect = ui.Rect.fromCenter(
      center: ui.Offset(size.x / 2, size.y / 2),
      width: size.x * 0.7,
      height: size.y * 0.75,
    );
    PanelRenderer.drawPanel(canvas, panelRect, title: 'LEADERBOARD');
    PanelRenderer.drawScanlines(canvas, panelRect);

    final panelTop = panelRect.top;
    final panelBottom = panelRect.bottom;

    PanelRenderer.drawTextCentered(canvas, 'LEADERBOARD', size.x / 2,
        panelTop + 40, 36, GameConfig.arcadeYellow,
        weight: FontWeight.bold, glow: true);

    final entries = leaderboard.entries;
    if (entries.isEmpty) {
      PanelRenderer.drawTextCentered(canvas, 'NO SCORES YET', size.x / 2,
          size.y / 2, 22, GameConfig.arcadeWhite);
    } else {
      for (int i = 0; i < entries.length; i++) {
        final e = entries[i];
        final y = panelTop + 90.0 + i * 42.0;
        final rank = '${i + 1}.'.padLeft(3);
        final name = e.name.padRight(4);
        final score = e.score.toString().padLeft(8);
        final text = '$rank $name $score';
        final color =
            i == 0 ? GameConfig.arcadeYellow : GameConfig.arcadeWhite;
        PanelRenderer.drawTextCentered(
            canvas, text, size.x / 2, y, 22, color);
      }
    }

    // Separator line above footer
    PanelRenderer.drawSeparator(
        canvas, size.x * 0.3, size.x * 0.7, panelBottom - 40);

    PanelRenderer.drawTextCentered(canvas, 'TAP TO CLOSE', size.x / 2,
        panelBottom - 20, 18, const ui.Color(0x88FFFFFF));
  }
}
