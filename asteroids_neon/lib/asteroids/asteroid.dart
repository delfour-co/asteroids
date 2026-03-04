import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../effects/neon_renderer.dart';
import 'asteroid_generator.dart';

/// Asteroid sizes with associated radius and points.
enum AsteroidSize {
  large(radius: 40.0, points: 20),
  medium(radius: 22.0, points: 50),
  small(radius: 12.0, points: 100);

  final double radius;
  final int points;
  const AsteroidSize({required this.radius, required this.points});
}

/// Event emitted when an asteroid is destroyed.
class AsteroidDestroyedEvent {
  final Vector2 position;
  final AsteroidSize asteroidSize;
  final bool byDash;
  AsteroidDestroyedEvent(this.position, this.asteroidSize,
      {this.byDash = false});
}

/// A procedurally generated asteroid with neon rendering.
class Asteroid extends PositionComponent
    with HasGameReference, CollisionCallbacks {
  final AsteroidSize asteroidSize;
  final Vector2 _velocity = Vector2.zero();
  final double _rotationSpeed;

  // Pre-allocated rendering
  late final Path _shape;
  late final Paint _glowPaint;
  late final Paint _solidPaint;

  static final Random _random = Random();

  Asteroid({
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

    final paints = NeonRenderer.createNeonPaints(
      color: const Color(0xFFFF00FF), // Magenta for asteroids
      glowRadius: 6.0,
      glowOpacity: 0.5,
      strokeWidth: 1.5,
    );
    _glowPaint = paints.glow;
    _solidPaint = paints.solid;

    // Add hitbox for collision detection
    await add(CircleHitbox(radius: asteroidSize.radius));
  }

  @override
  void update(double dt) {
    super.update(dt);

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

  /// Destroy this asteroid, emitting event and splitting if needed.
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
    NeonRenderer.drawNeonPath(canvas, _shape, _glowPaint, _solidPaint);
    canvas.restore();
  }
}
