import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_state.dart';

/// Event emitted when fire state changes.
class FireEvent {
  final bool isFiring;
  FireEvent(this.isFiring);
}

/// Fire button — bottom-right, left of thrust button.
///
/// Filled semi-transparent magenta circle with crosshair icon.
/// Uses DragCallbacks for reliable multi-touch.
class FireButton extends PositionComponent
    with HasGameReference, DragCallbacks {
  static const Color _magenta = Color(0xFFFF00FF);
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
    position = Vector2(gameSize.x - 170, gameSize.y - 80);

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
    eventBus.emit(FireEvent(true));
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    eventBus.emit(FireEvent(false));
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    eventBus.emit(FireEvent(false));
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
    const innerR = 28.0;

    // Glow fill
    canvas.drawCircle(
        center, radius, Paint()..color = const Color(0x1AFF00FF));

    // Outer segmented ring — 4 arcs with gaps
    final ringPaint = Paint()
      ..color = _magenta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final ringGlow = Paint()
      ..color = const Color(0x55FF00FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final rect = Rect.fromCircle(center: center, radius: radius);
    // 4 segments of ~75° each with 15° gaps
    for (int i = 0; i < 4; i++) {
      final start = -pi / 2 + i * (pi / 2) + 0.13; // offset + gap
      const sweep = 1.18; // ~68°
      canvas.drawArc(rect, start, sweep, false, ringGlow);
      canvas.drawArc(rect, start, sweep, false, ringPaint);
    }

    // Tick marks on outer ring (8 small ticks at 45° intervals)
    final tickPaint = Paint()
      ..color = _magenta
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final a = i * pi / 4;
      final outerX = cx + cos(a) * (radius + 5);
      final outerY = cy + sin(a) * (radius + 5);
      final innerX = cx + cos(a) * (radius + 1);
      final innerY = cy + sin(a) * (radius + 1);
      canvas.drawLine(
          Offset(innerX, innerY), Offset(outerX, outerY), tickPaint);
    }

    // Inner scope ring
    final innerRect = Rect.fromCircle(center: center, radius: innerR);
    canvas.drawArc(
        innerRect,
        -0.4,
        0.8,
        false,
        Paint()
          ..color = _magenta
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round);
    canvas.drawArc(
        innerRect,
        pi - 0.4,
        0.8,
        false,
        Paint()
          ..color = _magenta
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round);

    // Crosshair lines (4 ticks pointing inward)
    final crossPaint = Paint()
      ..color = _magenta
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy - 20), Offset(cx, cy - 12), crossPaint);
    canvas.drawLine(Offset(cx, cy + 12), Offset(cx, cy + 20), crossPaint);
    canvas.drawLine(Offset(cx - 20, cy), Offset(cx - 12, cy), crossPaint);
    canvas.drawLine(Offset(cx + 12, cy), Offset(cx + 20, cy), crossPaint);

    // Center dot
    canvas.drawCircle(center, 2.0, Paint()..color = _magenta);
  }

}
