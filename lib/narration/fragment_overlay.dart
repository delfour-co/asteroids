import 'dart:math';
import 'dart:ui' as ui;

import 'package:d4_dark_ds/d4_dark_ds.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart' show FontWeight, Shadow, TextStyle, TextSpan, TextPainter, TextDirection;

import '../hud/panel_renderer.dart';
import 'fragment_data.dart';

/// Full-screen overlay showing a single narrative fragment in Tron terminal style.
///
/// Uses DateTime.now() for pulse animation (game might be paused).
/// DragCallbacks + containsLocalPoint => true to block inputs below.
class FragmentOverlay extends PositionComponent
    with HasGameReference<FlameGame>, DragCallbacks {
  final NarrativeFragment fragment;
  final void Function() onDismiss;

  FragmentOverlay({required this.fragment, required this.onDismiss});

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

    PanelRenderer.drawOverlayBackground(canvas, w, h);

    final cx = w / 2;

    // Panel
    final panelW = w * 0.7;
    final panelH = h * 0.75;
    final panelRect = ui.Rect.fromCenter(
      center: ui.Offset(cx, h / 2),
      width: panelW,
      height: panelH,
    );
    PanelRenderer.drawPanel(canvas, panelRect, title: 'SHIP LOG');
    PanelRenderer.drawScanlines(canvas, panelRect);

    final contentLeft = panelRect.left + 32;
    final contentRight = panelRect.right - 32;
    final contentWidth = contentRight - contentLeft;

    // ── Fragment title — left-aligned, cyan, bold ──
    double y = panelRect.top + 36;
    PanelRenderer.drawTextLeft(
      canvas,
      fragment.title.toUpperCase(),
      contentLeft,
      y,
      20,
      D4DsColors.cyan,
      weight: FontWeight.bold,
      glow: true,
      letterSpacing: 1.5,
    );

    // ── Wave label — left-aligned, dimmed ──
    y += 28;
    PanelRenderer.drawTextLeft(
      canvas,
      'WAVE ${fragment.waveRequired}',
      contentLeft,
      y,
      12,
      D4DsColors.textDimmed,
      letterSpacing: 1.0,
    );

    // ── Separator ──
    y += 18;
    PanelRenderer.drawSeparator(canvas, contentLeft, contentRight, y);

    // ── Narrative text — left-aligned, white, wrapped ──
    y += 20;
    final tp = TextPainter(
      text: TextSpan(
        text: fragment.text,
        style: TextStyle(
          color: D4DsColors.textSecondary,
          fontSize: 15,
          fontFamily: D4DsTypography.monoFont,
          height: 1.6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: contentWidth);
    tp.paint(canvas, ui.Offset(contentLeft, y));

    // ── Pulsing "TAP TO CONTINUE" ──
    final ms = DateTime.now().millisecondsSinceEpoch;
    final pulse = 0.5 + sin(ms / 300.0) * 0.5;
    final pulseColor = ui.Color.fromARGB((pulse * 255).toInt(), 0, 255, 255);
    PanelRenderer.drawTextCentered(
      canvas,
      'TAP TO CONTINUE',
      cx,
      h - _footerOffset,
      14,
      pulseColor,
      letterSpacing: 1.5,
      shadows: [
        Shadow(
          color: ui.Color.fromARGB((pulse * 153).toInt(), 0, 255, 255),
          blurRadius: 8,
        ),
      ],
    );
  }
}
