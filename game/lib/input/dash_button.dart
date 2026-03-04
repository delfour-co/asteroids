import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../core/event_bus.dart';
import '../core/game_config.dart';

/// Event emitted when dash is triggered.
class DashEvent {}

/// Dash button with cooldown indicator.
///
/// Positioned between fire and thrust buttons.
/// Shows cooldown arc that fills up as dash recharges.
class DashButton extends PositionComponent
    with HasGameReference, DragCallbacks {
  static const Color _color = Color(0xFF00FF88); // Green neon
  double _cooldownRemaining = 0;

  @override
  Future<void> onLoad() async {
    final gameSize = game.size;
    size = Vector2(70, 70);
    anchor = Anchor.center;
    // Above fire/thrust buttons, centered between them
    position = Vector2(gameSize.x - 110, gameSize.y - 160);
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
    if (_cooldownRemaining <= 0) {
      _cooldownRemaining = GameConfig.dashCooldown;
      eventBus.emit(DashEvent());
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    const radius = 30.0;

    final bool ready = _cooldownRemaining <= 0;
    final opacity = ready ? 1.0 : 0.3;

    // Filled background
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = _color.withValues(alpha: 0.2 * opacity),
    );
    // Outer ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = _color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Cooldown arc overlay
    if (!ready) {
      final progress = 1.0 - (_cooldownRemaining / GameConfig.dashCooldown);
      final arcPaint = Paint()
        ..color = _color.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 2),
        -pi / 2, // Start from top
        progress * 2 * pi,
        false,
        arcPaint,
      );
    }

    // Lightning bolt icon
    final boltPaint = Paint()
      ..color = _color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    final bolt = Path()
      ..moveTo(size.x / 2 + 2, size.y / 2 - 14)
      ..lineTo(size.x / 2 - 6, size.y / 2 + 2)
      ..lineTo(size.x / 2 - 1, size.y / 2 + 2)
      ..lineTo(size.x / 2 - 2, size.y / 2 + 14)
      ..lineTo(size.x / 2 + 6, size.y / 2 - 2)
      ..lineTo(size.x / 2 + 1, size.y / 2 - 2)
      ..close();
    canvas.drawPath(bolt, boltPaint);
  }

}
