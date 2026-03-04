import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../effects/neon_renderer.dart';
import '../projectiles/projectile.dart';
import '../ship/ship.dart';
import 'enemy_projectile.dart';
import 'ufo_events.dart';

/// Hunter UFO — actively pursues the player, fires precisely.
///
/// Orange neon hexagonal shape. Steers towards player position.
/// Fires aimed shots with minimal spread. Faster than scout.
class UfoHunter extends PositionComponent
    with HasGameReference, CollisionCallbacks {
  static const double _radius = 16.0;
  static const double _speed = 100.0;
  static const Color _color = Color(0xFFFF8800); // Orange neon
  static const double _fireInterval = 1.8;
  static const double _inaccuracy = 0.15; // Very precise

  late final Path _shape;
  late final Paint _glowPaint;
  late final Paint _solidPaint;

  final Vector2 _velocity = Vector2.zero();
  double _fireTimer = 0;
  double _dodgeTimer = 0;
  final Vector2 _dodgeOffset = Vector2.zero();

  static final Random _random = Random();

  UfoHunter() {
    size = Vector2.all(_radius * 2);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    // Hexagonal shape
    _shape = Path();
    for (int i = 0; i < 6; i++) {
      final a = (i * pi / 3) - pi / 2;
      final x = cos(a) * _radius;
      final y = sin(a) * _radius;
      if (i == 0) {
        _shape.moveTo(x, y);
      } else {
        _shape.lineTo(x, y);
      }
    }
    _shape.close();

    final paints = NeonRenderer.createNeonPaints(
      color: _color,
      glowRadius: 6.0,
      glowOpacity: 0.5,
      strokeWidth: 1.5,
    );
    _glowPaint = paints.glow;
    _solidPaint = paints.solid;

    await add(CircleHitbox(radius: _radius));

    _fireTimer = 1.0 + _random.nextDouble() * _fireInterval;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Projectile) {
      _destroy();
      other.removeFromParent();
    } else if (other is Ship && !other.invulnerable) {
      eventBus.emit(ShipDestroyedEvent(other.position.clone()));
      other.removeFromParent();
      _destroy();
    }
  }

  void _destroy() {
    eventBus.emit(UfoDestroyedEvent(position.clone(), GameConfig.ufoPoints));
    removeFromParent();
  }

  @override
  void update(double dt) {
    super.update(dt);

    final ship = _findShip();

    if (ship != null) {
      // Steer towards player
      final toShip = ship.position - position;
      if (toShip.length > 0) {
        toShip.normalize();
        // Keep some distance (don't ram directly)
        final dist = (ship.position - position).length;
        if (dist < 120) {
          // Orbit instead of approach
          final orbitDir = Vector2(-toShip.y, toShip.x);
          _velocity.setFrom(orbitDir * _speed);
        } else {
          _velocity.setFrom(toShip * _speed);
        }
      }
    }

    // Dodge nearby projectiles
    _dodgeTimer -= dt;
    if (_dodgeTimer <= 0) {
      _dodgeTimer = 0.3;
      _dodgeOffset.setZero();
      _checkDodge();
    }

    final sm = GameConfig.enemySpeedMultiplier;
    position.x += (_velocity.x + _dodgeOffset.x) * dt * sm;
    position.y += (_velocity.y + _dodgeOffset.y) * dt * sm;

    // Wrap around
    _wrapAround();

    // Fire at player
    _fireTimer -= dt;
    if (_fireTimer <= 0 && ship != null) {
      _fireTimer = _fireInterval + _random.nextDouble() * 0.5;
      _fireAtPlayer(ship);
    }
  }

  void _wrapAround() {
    final gameSize = game.size;
    if (position.x < -_radius) position.x = gameSize.x + _radius;
    if (position.x > gameSize.x + _radius) position.x = -_radius;
    if (position.y < -_radius) position.y = gameSize.y + _radius;
    if (position.y > gameSize.y + _radius) position.y = -_radius;
  }

  Ship? _findShip() {
    // Search in GameLayer (parent of UfoManager -> parent is GameLayer)
    final gameLayer = parent?.parent;
    if (gameLayer == null) return null;
    for (final child in gameLayer.children) {
      if (child is Ship) return child;
    }
    return null;
  }

  void _checkDodge() {
    // Check for nearby player projectiles and dodge
    final gameLayer = parent?.parent;
    if (gameLayer == null) return;

    for (final child in gameLayer.children) {
      if (child is Projectile) {
        final dist = (child.position - position).length;
        if (dist < 80) {
          // Dodge perpendicular to projectile direction
          final away = position - child.position;
          if (away.length > 0) {
            away.normalize();
            _dodgeOffset.setFrom(away * 200);
          }
          break;
        }
      }
    }
  }

  void _fireAtPlayer(Ship ship) {
    final spread = (_random.nextDouble() - 0.5) * _inaccuracy * 2;
    final dir = ship.position - position;
    if (dir.length > 0) dir.normalize();
    final rotatedDir = Vector2(
      dir.x * cos(spread) - dir.y * sin(spread),
      dir.x * sin(spread) + dir.y * cos(spread),
    );

    final projectile = EnemyProjectile();
    projectile.init(
        pos: position.clone(), target: position + rotatedDir * 100);
    parent?.add(projectile);
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    NeonRenderer.drawNeonPath(canvas, _shape, _glowPaint, _solidPaint);
    canvas.restore();
  }
}
