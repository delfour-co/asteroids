import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../asteroids/asteroid.dart';
import '../asteroids/explosive_asteroid.dart';
import '../asteroids/magnetic_asteroid.dart';
import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../effects/neon_renderer.dart';

/// A laser projectile that travels in a straight line and despawns off-screen.
class Projectile extends PositionComponent
    with HasGameReference, CollisionCallbacks {
  // Pre-allocated paints
  late final Paint _glowPaint;
  late final Paint _solidPaint;

  // Direction and speed
  final Vector2 _direction = Vector2.zero();
  static const double _speed = 500.0;
  static const double _length = 12.0;

  // Lifetime
  double _lifetime = 0;
  static const double _maxLifetime = 2.0; // seconds

  // Trail
  static const int _trailMaxPoints = 8;
  final List<Vector2> _trailPoints = [];
  late final Paint _trailPaint;

  Projectile() {
    size = Vector2(4, _length);
    anchor = Anchor.center;
  }

  /// Initialize projectile with position, angle, and direction.
  void init({required Vector2 pos, required double shipAngle}) {
    position.setFrom(pos);
    angle = shipAngle;
    _direction
      ..x = sin(shipAngle)
      ..y = -cos(shipAngle);
    _lifetime = 0;
  }

  @override
  Future<void> onLoad() async {
    final paints = NeonRenderer.createNeonPaints(
      color: GameConfig.shipColor,
      glowRadius: 6.0,
      glowOpacity: 0.8,
      strokeWidth: 1.5,
    );
    _glowPaint = paints.glow;
    _solidPaint = paints.solid;

    _trailPaint = Paint()
      ..color = GameConfig.shipColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    await add(RectangleHitbox());
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Asteroid) {
      eventBus.emit(ProjectileHitEvent(position.clone()));
      other.destroy();
      removeFromParent();
    } else if (other is ExplosiveAsteroid) {
      eventBus.emit(ProjectileHitEvent(position.clone()));
      other.destroy();
      removeFromParent();
    } else if (other is MagneticAsteroid) {
      eventBus.emit(ProjectileHitEvent(position.clone()));
      other.destroy();
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    _lifetime += dt;
    if (_lifetime >= _maxLifetime) {
      removeFromParent();
      return;
    }

    // Record trail point before moving
    _trailPoints.insert(0, position.clone());
    if (_trailPoints.length > _trailMaxPoints) {
      _trailPoints.removeLast();
    }

    // Move in direction
    position.x += _direction.x * _speed * dt;
    position.y += _direction.y * _speed * dt;

    // Remove when off-screen
    _removeIfOffScreen();
  }

  void _removeIfOffScreen() {
    final gameSize = findGame()!.size;

    if (position.x < -_length ||
        position.x > gameSize.x + _length ||
        position.y < -_length ||
        position.y > gameSize.y + _length) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw fading trail in world coordinates (undo component transform)
    if (_trailPoints.length >= 2) {
      for (int i = 0; i < _trailPoints.length - 1; i++) {
        final alpha = ((1.0 - i / _trailPoints.length) * 0.4 * 255).toInt();
        _trailPaint.color = GameConfig.shipColor.withAlpha(alpha);
        final a = _trailPoints[i] - position;
        final b = _trailPoints[i + 1] - position;
        canvas.drawLine(
          Offset(a.x + size.x / 2, a.y + size.y / 2),
          Offset(b.x + size.x / 2, b.y + size.y / 2),
          _trailPaint,
        );
      }
    }

    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    // Draw as a short line (laser core)
    final path = Path()
      ..moveTo(0, -_length / 2)
      ..lineTo(0, _length / 2);
    NeonRenderer.drawNeonPath(canvas, path, _glowPaint, _solidPaint);
    canvas.restore();
  }
}
