import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_state.dart';

/// Pause button (⏸) in the top-right area.
///
/// Uses DragCallbacks for multi-touch compatibility.
/// Hidden during game over.
class PauseButton extends PositionComponent
    with HasGameReference, DragCallbacks {
  bool _visible = true;

  late final void Function(GameOverEvent) _gameOverListener;
  late final void Function(RestartGameEvent) _restartListener;

  static final Paint _paint = Paint()
    ..color = const Color(0xAAFFFFFF)
    ..style = PaintingStyle.fill;

  @override
  Future<void> onLoad() async {
    size = Vector2(44, 44);
    position = Vector2(game.size.x - 60, 40);
    priority = 100;

    _gameOverListener = (_) => _visible = false;
    _restartListener = (_) => _visible = true;
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
      eventBus.emit(PauseEvent());
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_visible) return;

    // Draw two vertical bars (⏸)
    const barWidth = 6.0;
    const barHeight = 22.0;
    const gap = 6.0;
    final cx = size.x / 2;
    final cy = size.y / 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx - gap / 2 - barWidth / 2, cy),
          width: barWidth,
          height: barHeight,
        ),
        const Radius.circular(2),
      ),
      _paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + gap / 2 + barWidth / 2, cy),
          width: barWidth,
          height: barHeight,
        ),
        const Radius.circular(2),
      ),
      _paint,
    );
  }
}
