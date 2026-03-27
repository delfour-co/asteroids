import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart'
    show TextPainter, TextDirection, TextStyle, TextSpan, FontWeight, Shadow;

import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../core/game_state.dart';

/// MENU button shown during game over — glow style matching home screen.
class MenuButton extends PositionComponent
    with HasGameReference, DragCallbacks {
  bool _visible = false;

  late final void Function(GameOverEvent) _gameOverListener;
  late final void Function(RestartGameEvent) _restartListener;

  @override
  Future<void> onLoad() async {
    size = Vector2(200, 42);
    final gameSize = game.size;
    position = Vector2(gameSize.x / 2 - 100, gameSize.y / 2 + 155);
    priority = 100;

    _gameOverListener = (_) => _visible = true;
    _restartListener = (_) => _visible = false;
    eventBus.on<GameOverEvent>(_gameOverListener);
    eventBus.on<RestartGameEvent>(_restartListener);
  }

  @override
  void onRemove() {
    eventBus.off<GameOverEvent>(_gameOverListener);
    eventBus.off<RestartGameEvent>(_restartListener);
    super.onRemove();
  }

  @override
  bool containsLocalPoint(Vector2 point) =>
      _visible && super.containsLocalPoint(point);

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (_visible) {
      eventBus.emit(ReturnToMenuEvent());
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_visible) return;

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));

    // Wide outer glow
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0x3000FFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Medium glow
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0x4000FFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Fill
    canvas.drawRRect(rrect, Paint()..color = const Color(0x1800FFFF));

    // Solid border
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xAA00FFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Text with glow
    final tp = TextPainter(
      text: TextSpan(
        text: 'MENU',
        style: TextStyle(
          color: GameConfig.arcadeYellow,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          fontFamily: 'JetBrainsMono',
          letterSpacing: 1.5,
          shadows: [
            Shadow(
              color: GameConfig.arcadeYellow.withValues(alpha: 0.6),
              blurRadius: 8,
            ),
            Shadow(
              color: GameConfig.arcadeYellow.withValues(alpha: 0.3),
              blurRadius: 16,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(size.x / 2 - tp.width / 2, size.y / 2 - tp.height / 2),
    );
  }
}
