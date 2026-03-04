import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../core/event_bus.dart';
import '../effects/neon_renderer.dart';
import '../ship/ship.dart';

/// Types of power-ups.
enum PowerUpType {
  shield(color: Color(0xFF00AAFF), label: 'S'), // Blue
  multiShot(color: Color(0xFFFFFF00), label: 'M'), // Yellow
  slowMo(color: Color(0xFFAA00FF), label: '~'); // Purple

  final Color color;
  final String label;
  const PowerUpType({required this.color, required this.label});
}

/// Event emitted when a power-up is collected.
class PowerUpCollectedEvent {
  final PowerUpType type;
  PowerUpCollectedEvent(this.type);
}

/// Floating power-up pickup that pulses with neon glow.
class PowerUp extends PositionComponent
    with HasGameReference, CollisionCallbacks {
  final PowerUpType type;
  static const double _radius = 14.0;
  static const double _lifetime = 8.0;

  late final Paint _glowPaint;
  late final Paint _solidPaint;
  late final Paint _fillPaint;

  double _age = 0;
  double _pulseTime = 0;

  PowerUp({required this.type}) {
    size = Vector2.all(_radius * 2);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    final paints = NeonRenderer.createNeonPaints(
      color: type.color,
      glowRadius: 8.0,
      glowOpacity: 0.6,
      strokeWidth: 2.0,
    );
    _glowPaint = paints.glow;
    _solidPaint = paints.solid;
    _fillPaint = Paint()..color = type.color.withValues(alpha: 0.15);

    await add(CircleHitbox(radius: _radius));
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Ship) {
      eventBus.emit(PowerUpCollectedEvent(type));
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    _age += dt;
    _pulseTime += dt;

    // Blink faster when about to expire
    if (_age >= _lifetime) {
      removeFromParent();
      return;
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);

    // Pulse scale
    final pulse = 1.0 + sin(_pulseTime * 4) * 0.15;
    final r = _radius * pulse;

    // Blink when expiring (last 2 seconds)
    if (_age > _lifetime - 2.0) {
      final blink = ((_age * 6).toInt() % 2 == 0);
      if (!blink) return;
    }

    // Fill
    canvas.drawCircle(center, r, _fillPaint);
    // Glow ring
    canvas.drawCircle(center, r, _glowPaint);
    // Solid ring
    canvas.drawCircle(center, r, _solidPaint);

    // Icon
    final labelPaint = Paint()
      ..color = type.color
      ..style = PaintingStyle.fill;

    // Draw simple symbol
    switch (type) {
      case PowerUpType.shield:
        // Shield icon (arc)
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: r * 0.5),
          -pi * 0.8,
          pi * 1.6,
          false,
          Paint()
            ..color = type.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
      case PowerUpType.multiShot:
        // Three dots (triple shot)
        for (int i = -1; i <= 1; i++) {
          canvas.drawCircle(
            Offset(center.dx + i * 5.0, center.dy),
            2.5,
            labelPaint,
          );
        }
      case PowerUpType.slowMo:
        // Hourglass shape
        final path = Path()
          ..moveTo(center.dx - 5, center.dy - 6)
          ..lineTo(center.dx + 5, center.dy - 6)
          ..lineTo(center.dx - 5, center.dy + 6)
          ..lineTo(center.dx + 5, center.dy + 6);
        canvas.drawPath(
          path,
          Paint()
            ..color = type.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
    }
  }
}
