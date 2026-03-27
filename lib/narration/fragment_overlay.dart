import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart' show FontWeight, Shadow;

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

    // Tron black background
    PanelRenderer.drawOverlayBackground(canvas, w, h);

    final cx = w / 2;

    // Panel dimensions
    final panelW = w * 0.7;
    final panelH = h * 0.75;
    final panelRect = ui.Rect.fromCenter(
      center: ui.Offset(cx, h / 2),
      width: panelW,
      height: panelH,
    );
    PanelRenderer.drawPanel(canvas, panelRect, title: 'MEMORY FRAGMENT');

    // Scanlines over the panel
    PanelRenderer.drawScanlines(canvas, panelRect);

    // "MEMORY FRAGMENT" title in cyan with glow
    PanelRenderer.drawTextCentered(
      canvas,
      'MEMORY FRAGMENT',
      cx,
      _titleY,
      32,
      const ui.Color(0xFF00FFFF),
      weight: FontWeight.bold,
      letterSpacing: 2.0,
      shadows: const [
        Shadow(color: ui.Color(0x9900FFFF), blurRadius: 8),
        Shadow(color: ui.Color(0x4400FFFF), blurRadius: 16),
      ],
    );

    // Separator line in cyan
    PanelRenderer.drawSeparator(canvas, cx - 120, cx + 120, _titleY + 22);

    // Fragment title in cyan with glow
    PanelRenderer.drawTextCentered(
      canvas,
      fragment.title,
      cx,
      _fragmentTitleY,
      24,
      const ui.Color(0xFF00FFFF),
      weight: FontWeight.bold,
      letterSpacing: 2.0,
      shadows: const [
        Shadow(color: ui.Color(0x9900FFFF), blurRadius: 8),
        Shadow(color: ui.Color(0x4400FFFF), blurRadius: 16),
      ],
    );

    // Fragment text line by line in cyan monospace
    final lines = fragment.text.split('\n');
    double y = _contentTop;
    for (final line in lines) {
      PanelRenderer.drawTextCentered(
        canvas,
        line,
        cx,
        y,
        18,
        const ui.Color(0xFF00FFFF),
        letterSpacing: 2.0,
      );
      y += _lineHeight;
    }

    // Pulsing "TAP TO CONTINUE" at bottom with glow
    final ms = DateTime.now().millisecondsSinceEpoch;
    final pulse = 0.5 + sin(ms / 300.0) * 0.5;
    final pulseColor = ui.Color.fromARGB((pulse * 255).toInt(), 0, 255, 255);
    PanelRenderer.drawTextCentered(
      canvas,
      'TAP TO CONTINUE',
      cx,
      h - _footerOffset,
      18,
      pulseColor,
      letterSpacing: 2.0,
      shadows: [
        Shadow(
          color: ui.Color.fromARGB((pulse * 153).toInt(), 0, 255, 255),
          blurRadius: 8,
        ),
        Shadow(
          color: ui.Color.fromARGB((pulse * 68).toInt(), 0, 255, 255),
          blurRadius: 16,
        ),
      ],
    );
  }
}
