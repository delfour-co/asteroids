import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

import '../core/event_bus.dart';
import '../core/game_config.dart';

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

/// Virtual joystick for ship steering.
///
/// Positioned on the left side of the screen.
/// Emits JoystickDirectionEvent via EventBus — no direct ship reference.
class ShipJoystick extends JoystickComponent {
  ShipJoystick()
      : super(
          knob: CircleComponent(
            radius: 30,
            paint: GameConfig.joystickKnobPaint,
          ),
          background: CircleComponent(
            radius: 75,
            paint: GameConfig.joystickBackgroundPaint,
          ),
          margin: const EdgeInsets.only(left: 40, bottom: 40),
        );

  @override
  void update(double dt) {
    super.update(dt);

    final isActive = !delta.isZero();

    if (isActive) {
      // Flame joystick: delta is relative (x right, y down)
      // Convert to angle where 0 = up, clockwise
      final angle = atan2(delta.x, -delta.y);
      eventBus.emit(JoystickDirectionEvent(
        angle: angle,
        isActive: true,
        intensity: delta.length.clamp(0.0, 1.0),
      ));
    } else {
      eventBus.emit(JoystickDirectionEvent(
        angle: 0,
        isActive: false,
        intensity: 0,
      ));
    }
  }
}
