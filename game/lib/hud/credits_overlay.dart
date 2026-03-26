import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart' show FontWeight;

import '../core/game_config.dart';
import 'panel_renderer.dart';

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
    PanelRenderer.drawOverlayBackground(canvas, size.x, size.y);

    // Panel
    final panelRect = ui.Rect.fromCenter(
      center: ui.Offset(size.x / 2, size.y / 2),
      width: size.x * 0.7,
      height: size.y * 0.75,
    );
    PanelRenderer.drawPanel(canvas, panelRect, title: 'CREDITS');
    PanelRenderer.drawScanlines(canvas, panelRect);

    final cx = size.x / 2;
    final panelTop = size.y * 0.125;
    final panelBottom = size.y * 0.875;

    PanelRenderer.drawTextCentered(
      canvas,
      'CREDITS',
      cx,
      panelTop + 40,
      40,
      GameConfig.arcadeYellow,
      weight: FontWeight.bold,
      glow: true,
    );

    PanelRenderer.drawTextCentered(
      canvas,
      'NEON ASTEROIDS',
      cx,
      panelTop + 120,
      28,
      GameConfig.shipColor,
      weight: FontWeight.bold,
      glow: true,
    );

    PanelRenderer.drawTextCentered(
      canvas,
      'Made with',
      cx,
      panelTop + 180,
      20,
      GameConfig.arcadeWhite,
    );
    PanelRenderer.drawTextCentered(
      canvas,
      'Flutter & Flame',
      cx,
      panelTop + 210,
      24,
      const ui.Color(0xFF00AAFF),
      weight: FontWeight.bold,
    );

    PanelRenderer.drawTextCentered(
      canvas,
      'Kevin Delfour',
      cx,
      panelTop + 280,
      26,
      GameConfig.arcadeWhite,
      weight: FontWeight.bold,
    );

    PanelRenderer.drawTextCentered(
      canvas,
      'Code by human + AI',
      cx,
      panelBottom - 60,
      12,
      const ui.Color(0x66FFFFFF),
    );

    // Separator line above footer
    PanelRenderer.drawSeparator(
      canvas,
      size.x * 0.3,
      size.x * 0.7,
      panelBottom - 40,
    );

    PanelRenderer.drawTextCentered(
      canvas,
      'TAP TO RETURN',
      cx,
      panelBottom - 20,
      18,
      const ui.Color(0x88FFFFFF),
    );
  }
}
