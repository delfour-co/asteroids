import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart' show FontWeight, Shadow;

import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../core/leaderboard.dart';
import 'panel_renderer.dart';

/// Event emitted when initials entry is complete.
class InitialsEnteredEvent {
  final String initials;
  InitialsEnteredEvent(this.initials);
}

/// 3-letter initials entry overlay (A-Z cycling per slot).
///
/// Swipe up/down on each slot to cycle letters, tap DONE to confirm.
class InitialEntryOverlay extends PositionComponent
    with HasGameReference, DragCallbacks {
  final int score;
  final LeaderboardManager leaderboard;

  final List<int> _letters = [0, 0, 0]; // 0=A, 25=Z
  int _selectedSlot = 0;
  bool _done = false;
  double _cumulativeDragY = 0;

  // Layout
  late double _slotStartX;
  late double _slotY;
  late double _slotWidth;
  late ui.Rect _doneRect;

  InitialEntryOverlay({required this.score, required this.leaderboard});

  @override
  Future<void> onLoad() async {
    size = game.size;
    position = Vector2.zero();
    priority = 300;

    _slotWidth = 60.0;
    _slotStartX = size.x / 2 - (_slotWidth * 3) / 2;
    _slotY = size.y / 2 + 30;
    _doneRect = ui.Rect.fromCenter(
      center: ui.Offset(size.x / 2, size.y / 2 + 150),
      width: 160,
      height: 50,
    );
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (_done) return;

    final pos = event.localPosition;

    // Check DONE button
    if (_doneRect.contains(ui.Offset(pos.x, pos.y))) {
      _done = true;
      final initials = _letters.map((i) => String.fromCharCode(65 + i)).join();
      leaderboard.addEntry(initials, score);
      eventBus.emit(InitialsEnteredEvent(initials));
      removeFromParent();
      return;
    }

    // Check arrow taps and slot selection
    _cumulativeDragY = 0;
    for (int i = 0; i < 3; i++) {
      final slotCenterX = _slotStartX + i * _slotWidth + _slotWidth / 2;
      final arrowUpY = _slotY - 40;
      final arrowDownY = _slotY + 50;

      if ((pos.x - slotCenterX).abs() < 20) {
        if ((pos.y - arrowUpY).abs() < 20) {
          _selectedSlot = i;
          _letters[i] = (_letters[i] + 1) % 26;
          return;
        }
        if ((pos.y - arrowDownY).abs() < 20) {
          _selectedSlot = i;
          _letters[i] = (_letters[i] - 1 + 26) % 26;
          return;
        }
      }

      final slotX = _slotStartX + i * _slotWidth;
      if (pos.x >= slotX && pos.x < slotX + _slotWidth) {
        _selectedSlot = i;
        break;
      }
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (_done) return;

    // Vertical drag to cycle letters (cumulative tracking)
    _cumulativeDragY += event.localDelta.y;
    if (_cumulativeDragY < -20) {
      _letters[_selectedSlot] = (_letters[_selectedSlot] + 1) % 26;
      _cumulativeDragY += 20;
    } else if (_cumulativeDragY > 20) {
      _letters[_selectedSlot] = (_letters[_selectedSlot] - 1 + 26) % 26;
      _cumulativeDragY -= 20;
    }
  }

  @override
  void render(ui.Canvas canvas) {
    if (_done) return;

    final cx = size.x / 2;
    final cy = size.y / 2;

    // Background
    PanelRenderer.drawOverlayBackground(canvas, size.x, size.y);

    // Panel
    final panelRect = ui.Rect.fromCenter(
      center: ui.Offset(cx, cy),
      width: size.x * 0.5,
      height: size.y * 0.75,
    );
    PanelRenderer.drawPanel(canvas, panelRect, title: 'HIGH SCORE');
    PanelRenderer.drawScanlines(canvas, panelRect);

    // ── "NEW HIGH SCORE!" — monospace bold outline style ──
    PanelRenderer.drawTronTitle(
      canvas,
      'NEW HIGH SCORE!',
      cx,
      cy - 120,
      32,
      letterSpacing: 2.0,
    );

    // Score value
    PanelRenderer.drawTextCentered(
      canvas,
      '$score',
      cx,
      cy - 80,
      28,
      const ui.Color(0xFF00FFFF),
      weight: FontWeight.bold,
      letterSpacing: 2.0,
      shadows: [const Shadow(color: ui.Color(0x9900FFFF), blurRadius: 10)],
    );

    // Instruction
    PanelRenderer.drawTextCentered(
      canvas,
      'ENTER YOUR INITIALS',
      cx,
      cy - 50,
      16,
      const ui.Color(0xAA00FFFF),
      letterSpacing: 2.0,
    );

    // Letter slots
    for (int i = 0; i < 3; i++) {
      final letter = String.fromCharCode(65 + _letters[i]);
      final x = _slotStartX + i * _slotWidth + _slotWidth / 2;
      final isSelected = i == _selectedSlot;
      final color = isSelected
          ? GameConfig.arcadeYellow
          : const ui.Color(0xFFFFFFFF);

      PanelRenderer.drawTextCentered(
        canvas,
        letter,
        x,
        _slotY,
        48,
        color,
        weight: FontWeight.bold,
        letterSpacing: 2.0,
        shadows: isSelected
            ? [
                Shadow(
                  color: GameConfig.arcadeYellow.withValues(alpha: 0.6),
                  blurRadius: 10,
                ),
              ]
            : [],
      );

      // Underline selected
      if (isSelected) {
        final underlinePaint = ui.Paint()
          ..color = GameConfig.arcadeYellow
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3);
        canvas.drawRect(
          ui.Rect.fromCenter(
            center: ui.Offset(x, _slotY + 30),
            width: 30,
            height: 2,
          ),
          underlinePaint,
        );
        canvas.drawRect(
          ui.Rect.fromCenter(
            center: ui.Offset(x, _slotY + 30),
            width: 30,
            height: 2,
          ),
          ui.Paint()..color = GameConfig.arcadeYellow,
        );
      }

      // Up/down arrows with glow
      final arrowColor = isSelected
          ? GameConfig.arcadeYellow
          : const ui.Color(0xAAFFFFFF);
      PanelRenderer.drawTextCentered(
        canvas,
        '▲',
        x,
        _slotY - 40,
        16,
        arrowColor,
        letterSpacing: 2.0,
      );
      PanelRenderer.drawTextCentered(
        canvas,
        '▼',
        x,
        _slotY + 50,
        16,
        arrowColor,
        letterSpacing: 2.0,
      );
    }

    // DONE glow button
    PanelRenderer.drawGlowButton(
      canvas,
      _doneRect,
      'DONE',
      GameConfig.arcadeGreen,
      fontSize: 18,
      letterSpacing: 2.0,
    );
  }
}
