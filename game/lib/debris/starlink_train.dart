import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../effects/neon_renderer.dart';
import '../projectiles/projectile.dart';
import 'debris_events.dart';

/// A train of 7 Starlink satellites drifting in formation.
///
/// Hitting any satellite destroys the entire train for 150 pts.
/// Passive — no collision with Ship, only with Projectile.
class StarlinkTrain extends PositionComponent with HasGameReference {
  static const int _satCount = 7;
  static const double _satSpacing = 18.0;
  static const double _offScreenMargin = 80.0;

  final Vector2 velocity;

  StarlinkTrain({required this.velocity});

  @override
  Future<void> onLoad() async {
    for (int i = 0; i < _satCount; i++) {
      await add(_StarlinkSat(
        offset: Vector2(i * _satSpacing, 0),
        train: this,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move entire train
    position += velocity * dt;

    // Remove when off screen
    final gameSize = game.size;
    if (position.x < -_offScreenMargin - _satCount * _satSpacing ||
        position.x > gameSize.x + _offScreenMargin + _satCount * _satSpacing ||
        position.y < -_offScreenMargin ||
        position.y > gameSize.y + _offScreenMargin) {
      removeFromParent();
    }
  }

  void destroy() {
    eventBus.emit(SpaceDebrisDestroyedEvent(
      position.clone(),
      GameConfig.starlinkPoints,
      'starlink',
    ));
    removeFromParent();
  }
}

/// Single satellite in the Starlink train — small cross (+) shape.
class _StarlinkSat extends PositionComponent with CollisionCallbacks {
  final Vector2 offset;
  final StarlinkTrain train;

  late final Path _shape;
  late final Paint _glowPaint;
  late final Paint _solidPaint;

  static const double _armLength = 5.0;
  static const double _stubLength = 3.0;

  _StarlinkSat({required this.offset, required this.train}) {
    size = Vector2.all(12);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    position = offset;

    // Cross (+) with small solar panel stubs
    _shape = Path()
      // Vertical arm
      ..moveTo(0, -_armLength)
      ..lineTo(0, _armLength)
      // Horizontal arm (solar panels)
      ..moveTo(-_armLength - _stubLength, 0)
      ..lineTo(_armLength + _stubLength, 0)
      // Small panel stubs at tips
      ..moveTo(-_armLength - _stubLength, -_stubLength)
      ..lineTo(-_armLength - _stubLength, _stubLength)
      ..moveTo(_armLength + _stubLength, -_stubLength)
      ..lineTo(_armLength + _stubLength, _stubLength);

    final paints = NeonRenderer.createNeonPaints(
      color: GameConfig.starlinkColor,
      glowRadius: 4.0,
      glowOpacity: 0.5,
      strokeWidth: 1.0,
    );
    _glowPaint = paints.glow;
    _solidPaint = paints.solid;

    await add(CircleHitbox(radius: 5));
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Projectile) {
      other.removeFromParent();
      train.destroy();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    NeonRenderer.drawNeonPath(canvas, _shape, _glowPaint, _solidPaint);
    canvas.restore();
  }
}
