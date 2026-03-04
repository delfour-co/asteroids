import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart'
    show TextPainter, TextDirection, TextStyle, TextSpan, FontWeight;

import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../core/leaderboard.dart';

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
    _slotY = size.y / 2 - 20;
    _doneRect = ui.Rect.fromCenter(
      center: ui.Offset(size.x / 2, size.y / 2 + 100),
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

    // Check slot selection
    for (int i = 0; i < 3; i++) {
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

    // Vertical drag to cycle letters
    if (event.localDelta.y < -8) {
      _letters[_selectedSlot] = (_letters[_selectedSlot] + 1) % 26;
    } else if (event.localDelta.y > 8) {
      _letters[_selectedSlot] = (_letters[_selectedSlot] - 1 + 26) % 26;
    }
  }

  @override
  void render(ui.Canvas canvas) {
    if (_done) return;

    // Semi-transparent background
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, size.x, size.y),
      ui.Paint()..color = const ui.Color(0xDD000011),
    );

    // Title
    _drawText(canvas, 'NEW HIGH SCORE!', size.x / 2, size.y / 2 - 120, 32,
        GameConfig.arcadeYellow, FontWeight.bold);
    _drawText(canvas, '$score', size.x / 2, size.y / 2 - 80, 28,
        GameConfig.arcadeWhite, FontWeight.normal);
    _drawText(canvas, 'ENTER YOUR INITIALS', size.x / 2, size.y / 2 - 50, 18,
        GameConfig.shipColor, FontWeight.normal);

    // Letter slots
    for (int i = 0; i < 3; i++) {
      final letter = String.fromCharCode(65 + _letters[i]);
      final x = _slotStartX + i * _slotWidth + _slotWidth / 2;
      final isSelected = i == _selectedSlot;
      final color =
          isSelected ? GameConfig.arcadeYellow : GameConfig.arcadeWhite;
      _drawText(canvas, letter, x, _slotY, 48, color, FontWeight.bold);

      // Underline selected
      if (isSelected) {
        canvas.drawRect(
          ui.Rect.fromCenter(
            center: ui.Offset(x, _slotY + 30),
            width: 30,
            height: 3,
          ),
          ui.Paint()..color = GameConfig.arcadeYellow,
        );
      }

      // Up/down arrows
      _drawText(canvas, '▲', x, _slotY - 40, 16, color, FontWeight.normal);
      _drawText(canvas, '▼', x, _slotY + 50, 16, color, FontWeight.normal);
    }

    // DONE button
    _drawText(canvas, 'DONE', size.x / 2, size.y / 2 + 100, 24,
        GameConfig.arcadeGreen, FontWeight.bold);
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
