import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../effects/neon_renderer.dart';
import '../projectiles/projectile.dart';
import 'debris_events.dart';

/// Tesla Roadster with Starman silhouette — amber/gold wireframe.
///
/// 1 HP, 250 pts. Passive — no collision with Ship, only with Projectile.
class TeslaRoadster extends PositionComponent
    with HasGameReference, CollisionCallbacks {
  static const double _offScreenMargin = 80.0;
  static const Color _color = GameConfig.teslaColor;

  final Vector2 velocity;
  final double rotationSpeed;

  late final Path _carShape;
  late final Path _starmanShape;
  late final Paint _glowPaint;
  late final Paint _solidPaint;

  TeslaRoadster({required this.velocity, this.rotationSpeed = 0.05}) {
    size = Vector2(44, 44);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    // Car silhouette (coupe profile facing right)
    _carShape = Path()
      // Underbody
      ..moveTo(-18, 6)
      ..lineTo(18, 6)
      // Front
      ..lineTo(20, 2)
      ..lineTo(16, -2)
      // Roof arc
      ..lineTo(6, -8)
      ..lineTo(-4, -10)
      ..lineTo(-12, -8)
      // Rear
      ..lineTo(-16, -2)
      ..lineTo(-18, 6)
      // Front wheel
      ..addOval(Rect.fromCircle(center: const Offset(10, 6), radius: 3))
      // Rear wheel
      ..addOval(Rect.fromCircle(center: const Offset(-10, 6), radius: 3));

    // Starman silhouette (seated figure)
    _starmanShape = Path()
      // Helmet (circle)
      ..addOval(Rect.fromCircle(center: const Offset(0, -14), radius: 4))
      // Torso
      ..moveTo(0, -10)
      ..lineTo(0, -4)
      // Left arm (resting on steering)
      ..moveTo(0, -8)
      ..lineTo(5, -6)
      ..lineTo(8, -4)
      // Right arm
      ..moveTo(0, -8)
      ..lineTo(-4, -5)
      // Legs (folded, seated)
      ..moveTo(0, -4)
      ..lineTo(4, 0)
      ..lineTo(6, 4)
      ..moveTo(0, -4)
      ..lineTo(-3, 0)
      ..lineTo(-4, 4);

    final paints = NeonRenderer.createNeonPaints(
      color: _color,
      glowRadius: 6.0,
      glowOpacity: 0.5,
      strokeWidth: 1.5,
    );
    _glowPaint = paints.glow;
    _solidPaint = paints.solid;

    await add(CircleHitbox(radius: 20));
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Projectile) {
      other.removeFromParent();
      _destroy();
    }
  }

  void _destroy() {
    eventBus.emit(SpaceDebrisDestroyedEvent(
      position.clone(),
      GameConfig.teslaPoints,
      'tesla',
    ));
    removeFromParent();
  }

  @override
  void update(double dt) {
    super.update(dt);

    angle += rotationSpeed * dt;
    position += velocity * dt;

    // Remove when off screen
    final gameSize = game.size;
    if (position.x < -_offScreenMargin ||
        position.x > gameSize.x + _offScreenMargin ||
        position.y < -_offScreenMargin ||
        position.y > gameSize.y + _offScreenMargin) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    NeonRenderer.drawNeonPath(canvas, _carShape, _glowPaint, _solidPaint);
    NeonRenderer.drawNeonPath(canvas, _starmanShape, _glowPaint, _solidPaint);
    canvas.restore();
  }
}
