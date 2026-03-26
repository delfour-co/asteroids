import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../core/game_state.dart';

/// Event emitted when dash is triggered.
class DashEvent {}

/// Dash button with cooldown indicator.
class DashButton extends PositionComponent
    with HasGameReference, DragCallbacks {
  static const Color _color = Color(0xFF00FF88);
  double _cooldownRemaining = 0;
  bool _visible = true;

  late final void Function(GameOverEvent) _gameOverListener;
  late final void Function(RestartGameEvent) _restartListener;
  late final void Function(PauseEvent) _pauseListener;
  late final void Function(ResumeEvent) _resumeListener;

  @override
  Future<void> onLoad() async {
    final gameSize = game.size;
    size = Vector2(70, 70);
    anchor = Anchor.center;
    position = Vector2(gameSize.x - 120, gameSize.y - 160);

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
  void update(double dt) {
    super.update(dt);
    if (_cooldownRemaining > 0) {
      _cooldownRemaining -= dt;
      if (_cooldownRemaining < 0) _cooldownRemaining = 0;
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!_visible) return;
    if (_cooldownRemaining <= 0) {
      _cooldownRemaining = GameConfig.dashCooldown;
      eventBus.emit(DashEvent());
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_visible) return;
    final cx = size.x / 2;
    final cy = size.y / 2;
    final center = Offset(cx, cy);
    const radius = 30.0;

    final bool ready = _cooldownRemaining <= 0;
    final opacity = ready ? 1.0 : 0.3;

    // Glow fill
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = _color.withValues(alpha: 0.12 * opacity),
    );

    // Outer segmented ring — 3 segments with gaps
    final ringPaint = Paint()
      ..color = _color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final ringGlow = Paint()
      ..color = _color.withValues(alpha: 0.3 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final rect = Rect.fromCircle(center: center, radius: radius);
    // 3 segments of ~100° with 20° gaps
    for (int i = 0; i < 3; i++) {
      final start = -pi / 2 + i * (2 * pi / 3) + 0.18;
      const sweep = 1.57; // ~90°
      canvas.drawArc(rect, start, sweep, false, ringGlow);
      canvas.drawArc(rect, start, sweep, false, ringPaint);
    }

    // Tick marks (6 around)
    final tickPaint = Paint()
      ..color = _color.withValues(alpha: 0.5 * opacity)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 6; i++) {
      final a = i * pi / 3;
      canvas.drawLine(
        Offset(cx + cos(a) * (radius + 1), cy + sin(a) * (radius + 1)),
        Offset(cx + cos(a) * (radius + 4), cy + sin(a) * (radius + 4)),
        tickPaint,
      );
    }

    // Cooldown: segmented arc that fills up
    if (!ready) {
      final progress = 1.0 - (_cooldownRemaining / GameConfig.dashCooldown);
      // Draw segmented progress arc (12 segments)
      const segCount = 12;
      final filledSegs = (progress * segCount).floor();
      final segSweep = (2 * pi) / segCount - 0.08; // small gap between segments

      for (int i = 0; i < segCount; i++) {
        final segStart = -pi / 2 + i * (2 * pi / segCount) + 0.04;
        final filled = i < filledSegs;
        final segPaint = Paint()
          ..color = _color.withValues(alpha: filled ? 0.7 : 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.butt;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius - 5),
          segStart,
          segSweep,
          false,
          segPaint,
        );
      }
    }

    // Lightning bolt icon
    final boltPaint = Paint()
      ..color = _color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    final bolt = Path()
      ..moveTo(cx + 2, cy - 14)
      ..lineTo(cx - 6, cy + 2)
      ..lineTo(cx - 1, cy + 2)
      ..lineTo(cx - 2, cy + 14)
      ..lineTo(cx + 6, cy - 2)
      ..lineTo(cx + 1, cy - 2)
      ..close();
    canvas.drawPath(bolt, boltPaint);
  }
}
