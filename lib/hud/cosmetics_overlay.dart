import 'dart:math';
import 'dart:ui' as ui;

import 'package:d4_dark_ds/d4_dark_ds.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart' show FontWeight;

import '../core/cosmetics_manager.dart';
import '../core/game_config.dart';
import 'panel_renderer.dart';

/// Ship color selection overlay. DragCallbacks + containsLocalPoint => true
/// to block inputs below.
class CosmeticsOverlay extends PositionComponent
    with HasGameReference, DragCallbacks {
  final CosmeticsManager cosmetics;
  final void Function() onDismiss;

  static const double _circleRadius = 24.0;

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
    PanelRenderer.drawOverlayBackground(canvas, size.x, size.y);

    final panelRect = ui.Rect.fromCenter(
      center: ui.Offset(size.x / 2, size.y / 2),
      width: size.x * 0.7,
      height: size.y * 0.75,
    );
    PanelRenderer.drawPanel(canvas, panelRect, title: 'COSMETICS');
    PanelRenderer.drawScanlines(canvas, panelRect);

    final cx = size.x / 2;
    final contentLeft = panelRect.left + 32;
    final contentRight = panelRect.right - 32;
    final panelBottom = panelRect.bottom;

    // ── Title ──
    double y = panelRect.top + 36;
    PanelRenderer.drawTextLeft(
      canvas,
      'SHIP COLOR',
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

    // ── Color swatches — centered row ──
    final colors = GameConfig.shipColors;
    final names = GameConfig.shipColorNames;
    final count = colors.length;
    final rowY = panelRect.top + panelRect.height * 0.45;
    final totalWidth = count * (_circleRadius * 2) + (count - 1) * 40;
    final startX = cx - totalWidth / 2 + _circleRadius;

    _circleRects.clear();

    for (int i = 0; i < count; i++) {
      final x = startX + i * (_circleRadius * 2 + 40);
      final color = colors[i];
      final unlocked = cosmetics.isUnlocked(i);
      final selected = cosmetics.selectedIndex == i;

      _circleRects.add(
        ui.Rect.fromCircle(
          center: ui.Offset(x, rowY),
          radius: _circleRadius + 10,
        ),
      );

      if (unlocked) {
        // ── Unlocked swatch ──

        // Neon glow behind selected
        if (selected) {
          canvas.drawCircle(
            ui.Offset(x, rowY),
            _circleRadius + 8,
            ui.Paint()
              ..color = color.withValues(alpha: 0.3)
              ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 12),
          );
          // Selection ring
          canvas.drawCircle(
            ui.Offset(x, rowY),
            _circleRadius + 4,
            ui.Paint()
              ..color = color
              ..style = ui.PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
        }

        // Color fill
        canvas.drawCircle(
          ui.Offset(x, rowY),
          _circleRadius,
          ui.Paint()..color = color,
        );

        // Name
        PanelRenderer.drawTextCentered(
          canvas,
          names[i],
          x,
          rowY + _circleRadius + 18,
          11,
          selected ? color : D4DsColors.textSecondary,
          weight: selected ? FontWeight.bold : FontWeight.normal,
        );

        // "EQUIPPED" tag under selected
        if (selected) {
          PanelRenderer.drawTextCentered(
            canvas,
            'EQUIPPED',
            x,
            rowY + _circleRadius + 34,
            9,
            D4DsColors.textDimmed,
            letterSpacing: 1.0,
          );
        }
      } else {
        // ── Locked swatch ──

        // Dim circle with border
        canvas.drawCircle(
          ui.Offset(x, rowY),
          _circleRadius,
          ui.Paint()..color = color.withValues(alpha: 0.12),
        );
        canvas.drawCircle(
          ui.Offset(x, rowY),
          _circleRadius,
          ui.Paint()
            ..color = D4DsColors.borderCyan
            ..style = ui.PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );

        // Lock icon (small padlock shape)
        final lx = x;
        final ly = rowY - 4;
        final lockPaint = ui.Paint()
          ..color = D4DsColors.textDimmed
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = ui.StrokeCap.round;
        // Lock body
        canvas.drawRRect(
          ui.RRect.fromRectAndRadius(
            ui.Rect.fromCenter(
              center: ui.Offset(lx, ly + 5),
              width: 12,
              height: 9,
            ),
            const ui.Radius.circular(2),
          ),
          ui.Paint()..color = D4DsColors.textDimmed,
        );
        // Lock shackle
        canvas.drawArc(
          ui.Rect.fromCenter(
            center: ui.Offset(lx, ly - 1),
            width: 10,
            height: 10,
          ),
          pi,
          pi,
          false,
          lockPaint,
        );

        // Color name — dimmed
        PanelRenderer.drawTextCentered(
          canvas,
          names[i],
          x,
          rowY + _circleRadius + 18,
          11,
          D4DsColors.textDimmed,
        );

        // Unlock requirement
        if (i - 1 < GameConfig.cosmeticUnlockWaves.length) {
          PanelRenderer.drawTextCentered(
            canvas,
            'WAVE ${GameConfig.cosmeticUnlockWaves[i - 1]}',
            x,
            rowY + _circleRadius + 34,
            9,
            D4DsColors.textDimmed,
            letterSpacing: 1.0,
          );
        }
      }
    }

    // ── Footer ──
    PanelRenderer.drawSeparator(
      canvas,
      size.x * 0.3,
      size.x * 0.7,
      panelBottom - 40,
    );

    PanelRenderer.drawTextCentered(
      canvas,
      'TAP TO CLOSE',
      cx,
      panelBottom - 20,
      12,
      D4DsColors.textDimmed,
    );
  }
}
