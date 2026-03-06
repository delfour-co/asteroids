import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../effects/neon_renderer.dart';
import 'asteroid.dart';
import 'asteroid_generator.dart';

/// An explosive asteroid that triggers a knockback blast on destruction.
///
/// Visually distinguished by an orange-red neon color and a pulsing
/// inner glow. When destroyed, emits a [KnockbackEvent] that pushes
/// nearby asteroids away, plus an extra-strong screen shake.
///
/// Only spawned for large and medium sizes — small fragments use
/// regular [Asteroid].
class ExplosiveAsteroid extends PositionComponent
    with HasGameReference, CollisionCallbacks {
  final AsteroidSize asteroidSize;
  final Vector2 _velocity = Vector2.zero();
  final double _rotationSpeed;

  // Rendering
  late final Path _shape;
  late final Paint _glowPaint;
  late final Paint _solidPaint;
  late final Paint _pulseGlowPaint;
  late final Paint _pulseSolidPaint;

  // Pulse tracking
  double _elapsed = 0.0;

  static final Random _random = Random();

  ExplosiveAsteroid({
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

    const color = GameConfig.explosiveAsteroidColor;

    final paints = NeonRenderer.createNeonPaints(
      color: color,
      glowRadius: 6.0,
      glowOpacity: 0.5,
      strokeWidth: 1.5,
    );
    _glowPaint = paints.glow;
    _solidPaint = paints.solid;

    // Inner pulse circle paints (filled, not stroked)
    _pulseGlowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    _pulseSolidPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    await add(CircleHitbox(radius: asteroidSize.radius));
  }

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;

    // Move (affected by slow-mo)
    final sm = GameConfig.enemySpeedMultiplier;
    position.x += _velocity.x * dt * sm;
    position.y += _velocity.y * dt * sm;

    // Rotate
    angle += _rotationSpeed * dt;

    // Wrap around
    _wrapAround();
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

  /// Destroy this asteroid, emitting knockback blast and events.
  void destroy({bool byDash = false}) {
    // Knockback blast — push nearby asteroids away
    eventBus.emit(KnockbackEvent(
      position.clone(),
      GameConfig.explosiveBlastRadius,
      GameConfig.knockbackForce,
    ));

    // Extra-strong screen shake for explosive blast
    eventBus.emit(ScreenShakeEvent(GameConfig.shakeIntensityLarge));

    // Standard asteroid destroyed event (scoring, splitting, embers)
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

    // Pulsing inner glow — distinguishes from normal asteroids
    final pulse = (sin(_elapsed * 4.0) + 1.0) / 2.0; // 0..1
    final pulseRadius = asteroidSize.radius * (0.3 + pulse * 0.25);

    _pulseGlowPaint.color = GameConfig.explosiveAsteroidColor
        .withValues(alpha: 0.15 + pulse * 0.2);
    canvas.drawCircle(Offset.zero, pulseRadius, _pulseGlowPaint);
    canvas.drawCircle(Offset.zero, pulseRadius * 0.6, _pulseSolidPaint);

    // Neon asteroid outline
    NeonRenderer.drawNeonPath(canvas, _shape, _glowPaint, _solidPaint);

    canvas.restore();
  }
}
