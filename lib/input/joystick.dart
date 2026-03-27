import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../core/game_state.dart';

/// Event emitted when joystick direction changes.
class JoystickDirectionEvent {
  /// Direction angle in radians (0 = up, clockwise).
  final double angle;

  /// Whether the joystick is actively being used (outside dead zone).
  final bool isActive;

  /// Joystick intensity (0.0 to 1.0).
  final double intensity;

  JoystickDirectionEvent({
    required this.angle,
    required this.isActive,
    required this.intensity,
  });
}

/// Custom joystick background with sci-fi ring design.
class _JoystickRingBackground extends CircleComponent {
  bool hidden = false;

  _JoystickRingBackground()
    : super(radius: 75, paint: Paint()..color = const Color(0x00000000));

  @override
  void render(Canvas canvas) {
    if (hidden) return;
    final cx = size.x / 2;
    final cy = size.y / 2;
    final center = Offset(cx, cy);
    const radius = 75.0;

    // Very subtle fill
    canvas.drawCircle(center, radius, Paint()..color = const Color(0x0D00FFFF));

    // Outer segmented ring — 4 arcs
    final ringPaint = Paint()
      ..color = const Color(0x5500FFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    for (int i = 0; i < 4; i++) {
      final start = -pi / 2 + i * (pi / 2) + 0.15;
      const sweep = 1.12;
      canvas.drawArc(rect, start, sweep, false, ringPaint);
    }

    // Inner ring — thinner, more segments
    final innerRect = Rect.fromCircle(center: center, radius: radius * 0.65);
    final innerPaint = Paint()
      ..color = const Color(0x3300FFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (int i = 0; i < 8; i++) {
      final start = i * (pi / 4) + 0.1;
      const sweep = 0.55;
      canvas.drawArc(innerRect, start, sweep, false, innerPaint);
    }

    // Cardinal tick marks (N/S/E/W — longer)
    final tickPaint = Paint()
      ..color = const Color(0x4400FFFF)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final a = i * pi / 2;
      canvas.drawLine(
        Offset(cx + cos(a) * (radius - 8), cy + sin(a) * (radius - 8)),
        Offset(cx + cos(a) * (radius + 2), cy + sin(a) * (radius + 2)),
        tickPaint,
      );
    }
    // Intermediate ticks (shorter)
    final smallTickPaint = Paint()
      ..color = const Color(0x2200FFFF)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final a = i * pi / 4 + pi / 8;
      canvas.drawLine(
        Offset(cx + cos(a) * (radius - 4), cy + sin(a) * (radius - 4)),
        Offset(cx + cos(a) * (radius + 1), cy + sin(a) * (radius + 1)),
        smallTickPaint,
      );
    }
  }
}

/// Custom joystick knob with glow.
class _JoystickKnob extends CircleComponent {
  bool hidden = false;

  _JoystickKnob()
    : super(radius: 30, paint: Paint()..color = const Color(0x00000000));

  @override
  void render(Canvas canvas) {
    if (hidden) return;
    final center = Offset(size.x / 2, size.y / 2);
    // Glow
    canvas.drawCircle(
      center,
      22,
      Paint()
        ..color = const Color(0x3300FFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // Solid knob
    canvas.drawCircle(center, 14, Paint()..color = GameConfig.shipColor);
    // Inner highlight
    canvas.drawCircle(
      Offset(center.dx - 3, center.dy - 3),
      5,
      Paint()..color = const Color(0x44FFFFFF),
    );
  }
}

/// Virtual joystick for ship steering with sci-fi HUD ring.
class ShipJoystick extends JoystickComponent {
  late final void Function(GameOverEvent) _gameOverListener;
  late final void Function(RestartGameEvent) _restartListener;
  late final void Function(PauseEvent) _pauseListener;
  late final void Function(ResumeEvent) _resumeListener;

  ShipJoystick()
    : super(
        knob: _JoystickKnob(),
        background: _JoystickRingBackground(),
        margin: const EdgeInsets.only(left: 40, bottom: 40),
      );

  void _setHidden(bool value) {
    (knob as _JoystickKnob?)?.hidden = value;
    (background as _JoystickRingBackground?)?.hidden = value;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _gameOverListener = (_) => _setHidden(true);
    _restartListener = (_) => _setHidden(false);
    _pauseListener = (_) => _setHidden(true);
    _resumeListener = (_) => _setHidden(false);
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

    final isActive = !delta.isZero();

    if (isActive) {
      // Flame joystick: delta is relative (x right, y down)
      // Convert to angle where 0 = up, clockwise
      final angle = atan2(delta.x, -delta.y);
      eventBus.emit(
        JoystickDirectionEvent(
          angle: angle,
          isActive: true,
          intensity: delta.length.clamp(0.0, 1.0),
        ),
      );
    } else {
      eventBus.emit(
        JoystickDirectionEvent(angle: 0, isActive: false, intensity: 0),
      );
    }
  }
}
