import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_state.dart';

/// Pause button (⏸) with sci-fi ring design.
class PauseButton extends PositionComponent
    with HasGameReference, DragCallbacks {
  bool _visible = true;

  late final void Function(GameOverEvent) _gameOverListener;
  late final void Function(RestartGameEvent) _restartListener;

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

    final cx = size.x / 2;
    final cy = size.y / 2;
    final center = Offset(cx, cy);
    const ringRadius = 20.0;

    // Subtle ring glow
    final ringGlow = Paint()
      ..color = const Color(0x2200FFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Ring — 2 arcs with gaps (top and bottom open)
    final ringPaint = Paint()
      ..color = const Color(0x6600FFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: ringRadius);
    // Left arc
    canvas.drawArc(rect, 0.4, 2.34, false, ringGlow);
    canvas.drawArc(rect, 0.4, 2.34, false, ringPaint);
    // Right arc
    canvas.drawArc(rect, -2.74, 2.34, false, ringGlow);
    canvas.drawArc(rect, -2.74, 2.34, false, ringPaint);

    // Small tick marks at cardinal points
    final tickPaint = Paint()
      ..color = const Color(0x4400FFFF)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final a = i * pi / 2;
      canvas.drawLine(
        Offset(cx + cos(a) * (ringRadius + 1), cy + sin(a) * (ringRadius + 1)),
        Offset(cx + cos(a) * (ringRadius + 4), cy + sin(a) * (ringRadius + 4)),
        tickPaint,
      );
    }

    // Pause bars (⏸) — same white color as before
    final barPaint = Paint()
      ..color = const Color(0xAAFFFFFF)
      ..style = PaintingStyle.fill;

    const barWidth = 5.0;
    const barHeight = 16.0;
    const gap = 5.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx - gap / 2 - barWidth / 2, cy),
          width: barWidth,
          height: barHeight,
        ),
        const Radius.circular(1.5),
      ),
      barPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + gap / 2 + barWidth / 2, cy),
          width: barWidth,
          height: barHeight,
        ),
        const Radius.circular(1.5),
      ),
      barPaint,
    );
  }
}
