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

/// Scout UFO — traverses screen on semi-random path, fires inaccurately.
///
/// Green neon diamond shape. Moves in a sinusoidal wave pattern.
/// Fires at player with low accuracy (random spread).
class UfoScout extends PositionComponent
    with HasGameReference, CollisionCallbacks {
  static const double _radius = 18.0;
  static const double _speed = 80.0;
  static const Color _color = Color(0xFF00FF44); // Green neon
  static const double _fireInterval = 2.5;
  static const double _inaccuracy = 0.6; // radians of spread

  late final Path _shape;
  late final Paint _glowPaint;
  late final Paint _solidPaint;

  final Vector2 _velocity = Vector2.zero();
  double _fireTimer = 0;
  double _waveTime = 0;
  final double _waveAmplitude;
  final Vector2 _baseDirection = Vector2.zero();

  static final Random _random = Random();

  UfoScout()
      : _waveAmplitude = 30.0 + _random.nextDouble() * 40.0 {
    size = Vector2.all(_radius * 2);
    anchor = Anchor.center;
  }

  /// Set the travel direction (normalized).
  void setDirection(Vector2 dir) {
    _baseDirection.setFrom(dir);
    _velocity
      ..setFrom(dir)
      ..scale(_speed);
  }

  @override
  Future<void> onLoad() async {
    // Diamond shape
    _shape = Path()
      ..moveTo(0, -_radius) // Top
      ..lineTo(-_radius * 0.7, 0) // Left
      ..lineTo(0, _radius * 0.6) // Bottom
      ..lineTo(_radius * 0.7, 0) // Right
      ..close();

    final paints = NeonRenderer.createNeonPaints(
      color: _color,
      glowRadius: 6.0,
      glowOpacity: 0.5,
      strokeWidth: 1.5,
    );
    _glowPaint = paints.glow;
    _solidPaint = paints.solid;

    await add(CircleHitbox(radius: _radius));

    // Random initial fire delay
    _fireTimer = _random.nextDouble() * _fireInterval;
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

    _waveTime += dt;

    // Sinusoidal wave perpendicular to travel direction
    final perpX = -_baseDirection.y;
    final perpY = _baseDirection.x;
    final wave = sin(_waveTime * 2.5) * _waveAmplitude * dt;

    final sm = GameConfig.enemySpeedMultiplier;
    position.x += (_velocity.x * dt + perpX * wave) * sm;
    position.y += (_velocity.y * dt + perpY * wave) * sm;

    // Fire at player
    _fireTimer -= dt;
    if (_fireTimer <= 0) {
      _fireTimer = _fireInterval + _random.nextDouble() * 1.0;
      _fireAtPlayer();
    }

    // Remove if far off screen
    final gameSize = game.size;
    if (position.x < -80 ||
        position.x > gameSize.x + 80 ||
        position.y < -80 ||
        position.y > gameSize.y + 80) {
      removeFromParent();
    }
  }

  void _fireAtPlayer() {
    // Find ship position via children of parent's parent (GameLayer)
    final gameLayer = parent?.parent;
    if (gameLayer == null) return;

    Ship? ship;
    for (final child in gameLayer.children) {
      if (child is Ship) {
        ship = child;
        break;
      }
    }
    // Also check sibling components
    if (ship == null && parent != null) {
      for (final child in parent!.children) {
        if (child is Ship) {
          ship = child;
          break;
        }
      }
    }

    if (ship == null) return;

    // Fire with inaccuracy
    final projectile = EnemyProjectile();
    final spread = (_random.nextDouble() - 0.5) * _inaccuracy * 2;
    final dir = ship.position - position;
    if (dir.length > 0) dir.normalize();
    final rotatedDir = Vector2(
      dir.x * cos(spread) - dir.y * sin(spread),
      dir.x * sin(spread) + dir.y * cos(spread),
    );
    projectile.init(pos: position.clone(), target: position + rotatedDir * 100);
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
