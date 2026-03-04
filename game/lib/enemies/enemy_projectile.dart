import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../core/event_bus.dart';
import '../effects/neon_renderer.dart';
import '../ship/ship.dart';

/// A projectile fired by UFOs towards the player.
class EnemyProjectile extends PositionComponent
    with HasGameReference, CollisionCallbacks {
  late final Paint _glowPaint;
  late final Paint _solidPaint;

  final Vector2 _direction = Vector2.zero();
  static const double _speed = 250.0;
  static const double _length = 10.0;
  static const Color _color = Color(0xFFFF4400); // Orange-red

  double _lifetime = 0;
  static const double _maxLifetime = 3.0;

  EnemyProjectile() {
    size = Vector2(4, _length);
    anchor = Anchor.center;
  }

  /// Initialize with position and target direction.
  void init({required Vector2 pos, required Vector2 target}) {
    position.setFrom(pos);
    final dir = target - pos;
    if (dir.length > 0) {
      dir.normalize();
    }
    _direction.setFrom(dir);
    angle = atan2(dir.x, -dir.y);
  }

  @override
  Future<void> onLoad() async {
    final paints = NeonRenderer.createNeonPaints(
      color: _color,
      glowRadius: 5.0,
      glowOpacity: 0.7,
      strokeWidth: 1.5,
    );
    _glowPaint = paints.glow;
    _solidPaint = paints.solid;

    await add(RectangleHitbox());
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Ship && !other.invulnerable) {
      eventBus.emit(ShipDestroyedEvent(other.position.clone()));
      other.removeFromParent();
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

    position.x += _direction.x * _speed * dt;
    position.y += _direction.y * _speed * dt;

    // Remove if off screen (no wrap for enemy projectiles)
    final gameSize = findGame()!.size;
    if (position.x < -20 ||
        position.x > gameSize.x + 20 ||
        position.y < -20 ||
        position.y > gameSize.y + 20) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    final path = Path()
      ..moveTo(0, -_length / 2)
      ..lineTo(0, _length / 2);
    NeonRenderer.drawNeonPath(canvas, path, _glowPaint, _solidPaint);
    canvas.restore();
  }
}
