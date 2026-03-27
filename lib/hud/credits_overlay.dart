import 'dart:ui' as ui;

import 'package:d4_dark_ds/d4_dark_ds.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart' show FontWeight;

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

  /// Draws a small uppercase section label in dimmed cyan.
  static void _drawLabel(
    ui.Canvas canvas,
    double x,
    double y,
    String text,
  ) {
    PanelRenderer.drawTextLeft(
      canvas,
      text,
      x,
      y,
      10,
      D4DsColors.textDimmed,
      letterSpacing: 1.5,
    );
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
    final contentLeft = panelRect.left + 32;
    final contentRight = panelRect.right - 32;
    final panelBottom = panelRect.bottom;
    final colMid = cx + 8; // right column start

    double y = panelRect.top + 36;

    // ── Title ──
    PanelRenderer.drawTextLeft(
      canvas,
      'CREDITS',
      contentLeft,
      y,
      20,
      D4DsColors.cyan,
      weight: FontWeight.bold,
      glow: true,
      letterSpacing: 1.5,
    );

    y += 40;
    PanelRenderer.drawSeparator(canvas, contentLeft, contentRight, y);
    y += 24;

    // ── Left column ──
    final colY = y;

    // Game
    _drawLabel(canvas, contentLeft, y, 'GAME');
    y += 16;
    PanelRenderer.drawTextLeft(
      canvas,
      'Neon Asteroids',
      contentLeft,
      y,
      15,
      D4DsColors.textPrimary,
      weight: FontWeight.bold,
    );
    y += 18;
    PanelRenderer.drawTextLeft(
      canvas,
      'Arcade space shooter',
      contentLeft,
      y,
      11,
      D4DsColors.textSecondary,
    );

    y += 30;

    // Developer
    _drawLabel(canvas, contentLeft, y, 'DEVELOPER');
    y += 16;
    PanelRenderer.drawTextLeft(
      canvas,
      'Kevin Delfour',
      contentLeft,
      y,
      15,
      D4DsColors.textPrimary,
      weight: FontWeight.bold,
    );
    y += 18;
    PanelRenderer.drawTextLeft(
      canvas,
      'Design, code & art',
      contentLeft,
      y,
      11,
      D4DsColors.textSecondary,
    );
    y += 14;
    PanelRenderer.drawTextLeft(
      canvas,
      'Human + AI collaboration',
      contentLeft,
      y,
      11,
      D4DsColors.textSecondary,
    );

    // ── Right column ──
    y = colY;

    // Built with
    _drawLabel(canvas, colMid, y, 'BUILT WITH');
    y += 16;
    for (final tech in [
      'Flutter + Flame engine',
      'Firebase Crashlytics',
      'Google Play Games',
      'D4 Dark Design System',
    ]) {
      PanelRenderer.drawTextLeft(
        canvas,
        tech,
        colMid,
        y,
        11,
        D4DsColors.textSecondary,
      );
      y += 14;
    }

    y += 16;

    // Assets
    _drawLabel(canvas, colMid, y, 'ASSETS');
    y += 16;
    for (final asset in [
      'JetBrains Mono (OFL)',
      'Tron font',
      'Original audio',
    ]) {
      PanelRenderer.drawTextLeft(
        canvas,
        asset,
        colMid,
        y,
        11,
        D4DsColors.textSecondary,
      );
      y += 14;
    }

    // ── Version ──
    PanelRenderer.drawTextLeft(
      canvas,
      'v1.8.0 (build 23)',
      contentLeft,
      panelBottom - 58,
      11,
      D4DsColors.textDimmed,
    );

    // ── Footer ──
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
      12,
      D4DsColors.textDimmed,
    );
  }
}
