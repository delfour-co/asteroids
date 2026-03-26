import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../core/game_state.dart';

/// Event emitted when thrust state changes.
class ThrustEvent {
  final bool isThrusting;
  ThrustEvent(this.isThrusting);
}

/// Thrust button — bottom-right corner.
///
/// Filled semi-transparent cyan circle with arrow icon.
/// Uses DragCallbacks for reliable multi-touch.
class ThrustButton extends PositionComponent
    with HasGameReference, DragCallbacks {
  bool _visible = true;

  late final void Function(GameOverEvent) _gameOverListener;
  late final void Function(RestartGameEvent) _restartListener;
  late final void Function(PauseEvent) _pauseListener;
  late final void Function(ResumeEvent) _resumeListener;

  @override
  Future<void> onLoad() async {
    final gameSize = game.size;
    size = Vector2(90, 90);
    anchor = Anchor.center;
    position = Vector2(gameSize.x - 70, gameSize.y - 80);

    _gameOverListener = (_) => _visible = false;
    _restartListener = (_) => _visible = true;
    _pauseListener = (_) => _visible = false;
    _resumeListener = (_) => _visible = true;
    eventBus.on<GameOverEvent>(_gameOverListener);
    eventBus.on<RestartGameEvent>(_restartListener);
    eventBus.on<PauseEvent>(_pauseListener);
    eventBus.on<ResumeEvent>(_resumeListener);
  }

  @override
  void onRemove() {
    eventBus.off<GameOverEvent>(_gameOverListener);
    eventBus.off<RestartGameEvent>(_restartListener);
    eventBus.off<PauseEvent>(_pauseListener);
    eventBus.off<ResumeEvent>(_resumeListener);
    super.onRemove();
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!_visible) return;
    eventBus.emit(ThrustEvent(true));
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    eventBus.emit(ThrustEvent(false));
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    eventBus.emit(ThrustEvent(false));
  }

  @override
  bool containsLocalPoint(Vector2 point) =>
      _visible && super.containsLocalPoint(point);

  @override
  void render(Canvas canvas) {
    if (!_visible) return;
    final cx = size.x / 2;
    final cy = size.y / 2;
    final center = Offset(cx, cy);
    const radius = 40.0;
    const color = GameConfig.shipColor;

    // Glow fill
    canvas.drawCircle(center, radius, Paint()..color = const Color(0x1500FFFF));

    // Outer segmented ring — 3 arcs with gaps (top open for arrow emphasis)
    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final ringGlow = Paint()
      ..color = const Color(0x4400FFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final rect = Rect.fromCircle(center: center, radius: radius);
    // 4 arcs with gaps (like fire button)
    for (int i = 0; i < 4; i++) {
      final start = -pi / 2 + i * (pi / 2) + 0.13;
      const sweep = 1.18;
      canvas.drawArc(rect, start, sweep, false, ringGlow);
      canvas.drawArc(rect, start, sweep, false, ringPaint);
    }

    // Small tick marks (6 around the ring)
    final tickPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 6; i++) {
      final a = i * pi / 3 + pi / 6;
      canvas.drawLine(
        Offset(cx + cos(a) * (radius + 1), cy + sin(a) * (radius + 1)),
        Offset(cx + cos(a) * (radius + 5), cy + sin(a) * (radius + 5)),
        tickPaint,
      );
    }

    // Arrow (triangle pointing up)
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final arrow = Path()
      ..moveTo(cx, cy - 16)
      ..lineTo(cx - 12, cy + 10)
      ..lineTo(cx + 12, cy + 10)
      ..close();
    canvas.drawPath(arrow, arrowPaint);
  }
}
