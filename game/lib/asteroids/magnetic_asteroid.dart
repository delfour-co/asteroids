import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../effects/neon_renderer.dart';
import '../ship/ship.dart';
import 'asteroid.dart';
import 'asteroid_generator.dart';

/// A magnetic asteroid that curves its trajectory toward the player ship.
///
/// Visually distinguished by a purple neon color and a faint pulsing
/// ring showing its magnetic pull radius. When a [Ship] is within
/// [GameConfig.magneticPullRadius], the asteroid adjusts its own
/// velocity toward the ship, making it harder to avoid.
class MagneticAsteroid extends PositionComponent
    with HasGameReference, CollisionCallbacks {
  final AsteroidSize asteroidSize;
  final Vector2 _velocity = Vector2.zero();
  final double _rotationSpeed;

  // Rendering
  late final Path _shape;
  late final Paint _glowPaint;
  late final Paint _solidPaint;
  late final Paint _fieldRingPaint;

  // Pulse tracking
  double _elapsed = 0.0;

  static final Random _random = Random();

  MagneticAsteroid({
    required this.asteroidSize,
    Vector2? velocity,
  }) : _rotationSpeed = (_random.nextDouble() - 0.5) * 2.0 {
    final r = asteroidSize.radius;
    size = Vector2.all(r * 2);
    anchor = Anchor.center;
    if (velocity != null) {
      _velocity.setFrom(velocity);
    }
  }

  /// Set velocity (used by AsteroidManager for spawning/splitting).
  void setVelocity(Vector2 velocity) {
    _velocity.setFrom(velocity);
  }

  @override
  Future<void> onLoad() async {
    _shape = AsteroidGenerator.generateShape(asteroidSize.radius);

    const color = GameConfig.magneticAsteroidColor;

    final paints = NeonRenderer.createNeonPaints(
      color: color,
      glowRadius: 6.0,
      glowOpacity: 0.5,
      strokeWidth: 1.5,
    );
    _glowPaint = paints.glow;
    _solidPaint = paints.solid;

    // Faint purple ring showing magnetic field
    _fieldRingPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    await add(CircleHitbox(radius: asteroidSize.radius));
  }

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;

    // Magnetic attraction — curve toward nearby ship
    _applyMagneticPull(dt);

    // Move (affected by slow-mo)
    final sm = GameConfig.enemySpeedMultiplier;
    position.x += _velocity.x * dt * sm;
    position.y += _velocity.y * dt * sm;

    // Rotate
    angle += _rotationSpeed * dt;

    // Wrap around
    _wrapAround();
  }

  /// Adjust own velocity toward ship if within magnetic pull radius.
  void _applyMagneticPull(double dt) {
    // Ship is a sibling of AsteroidManager in GameLayer
    final ships = parent?.parent?.children.whereType<Ship>();
    if (ships == null || ships.isEmpty) return;

    final ship = ships.first;
    final direction = ship.position - position;
    final dist = direction.length;

    if (dist < GameConfig.magneticPullRadius && dist > 1.0) {
      // Stronger pull when closer (linear falloff)
      final strength = 1.0 - (dist / GameConfig.magneticPullRadius);
      final pull = direction.normalized()
        ..scale(GameConfig.magneticPullForce * strength * dt);
      _velocity.add(pull);
    }
  }

  void _wrapAround() {
    final gameSize = game.size;
    final r = asteroidSize.radius;

    if (position.x < -r) {
      position.x = gameSize.x + r;
    } else if (position.x > gameSize.x + r) {
      position.x = -r;
    }

    if (position.y < -r) {
      position.y = gameSize.y + r;
    } else if (position.y > gameSize.y + r) {
      position.y = -r;
    }
  }

  /// Destroy this asteroid, emitting event.
  void destroy({bool byDash = false}) {
    eventBus.emit(AsteroidDestroyedEvent(
      position.clone(),
      asteroidSize,
      byDash: byDash,
    ));
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);

    // Pulsing magnetic field ring
    final pulse = (sin(_elapsed * 3.0) + 1.0) / 2.0; // 0..1
    final ringOpacity = 0.05 + pulse * 0.1;
    _fieldRingPaint.color =
        GameConfig.magneticAsteroidColor.withValues(alpha: ringOpacity);
    canvas.drawCircle(
      Offset.zero,
      GameConfig.magneticPullRadius,
      _fieldRingPaint,
    );

    // Neon asteroid outline
    NeonRenderer.drawNeonPath(canvas, _shape, _glowPaint, _solidPaint);

    canvas.restore();
  }
}
