import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart' show TextPainter, TextDirection, TextStyle, TextSpan, FontWeight;

import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../core/game_state.dart';

/// MENU button shown during game over.
///
/// Uses DragCallbacks. Hidden during active gameplay.
class MenuButton extends PositionComponent
    with HasGameReference, DragCallbacks {
  bool _visible = false;

  late final void Function(GameOverEvent) _gameOverListener;
  late final void Function(RestartGameEvent) _restartListener;

  @override
  Future<void> onLoad() async {
    size = Vector2(120, 40);
    final gameSize = game.size;
    position = Vector2(gameSize.x / 2 - 60, gameSize.y / 2 + 90);
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

    final tp = TextPainter(
      text: const TextSpan(
        text: 'MENU',
        style: TextStyle(
          color: GameConfig.arcadeYellow,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.x / 2 - tp.width / 2, size.y / 2 - tp.height / 2));
  }
}
