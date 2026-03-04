import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../effects/neon_renderer.dart';
import '../projectiles/projectile.dart';
import 'debris_events.dart';

/// Space Station (ISS/MIR style) — 3 HP, teal wireframe.
///
/// Central module with solar panels, docking port, and trusses.
/// Passive — no collision with Ship, only with Projectile.
class SpaceStation extends PositionComponent
    with HasGameReference, CollisionCallbacks {
  static const int _maxHp = 3;
  static const double _offScreenMargin = 80.0;
  static const Color _color = GameConfig.stationColor;

  final Vector2 velocity;
  final double rotationSpeed;

  late final Path _shape;
  late final Paint _glowPaint;
  late final Paint _solidPaint;
  late final Paint _hpBarPaint;
  late final Paint _hpBarBgPaint;

  int _hp = _maxHp;
  double _flashTimer = 0;

  SpaceStation({required this.velocity, this.rotationSpeed = 0.1}) {
    size = Vector2(64, 30);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    _shape = Path()
      // Central module (rectangle)
      ..addRect(const Rect.fromLTWH(-10, -6, 20, 12))
      // Left solar panel
      ..addRect(const Rect.fromLTWH(-31, -10, 16, 4))
      ..addRect(const Rect.fromLTWH(-31, 6, 16, 4))
      // Right solar panel
      ..addRect(const Rect.fromLTWH(15, -10, 16, 4))
      ..addRect(const Rect.fromLTWH(15, 6, 16, 4))
      // Truss (horizontal beam)
      ..moveTo(-31, 0)
      ..lineTo(31, 0)
      // Docking port (small rectangle at front)
      ..addRect(const Rect.fromLTWH(-3, -14, 6, 8));

    final paints = NeonRenderer.createNeonPaints(
      color: _color,
      glowRadius: 6.0,
      glowOpacity: 0.5,
      strokeWidth: 1.5,
    );
    _glowPaint = paints.glow;
    _solidPaint = paints.solid;

    _hpBarPaint = Paint()..color = _color;
    _hpBarBgPaint = Paint()..color = _color.withValues(alpha: 0.25);

    await add(RectangleHitbox(
      size: Vector2(62, 28),
      position: Vector2(1, 1),
      anchor: Anchor.center,
    ));
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Projectile) {
      other.removeFromParent();
      _takeDamage();
    }
  }

  void _takeDamage() {
    _hp--;
    _flashTimer = 0.15;
    if (_hp <= 0) {
      _destroy();
    }
  }

  void _destroy() {
    eventBus.emit(SpaceDebrisDestroyedEvent(
      position.clone(),
      GameConfig.stationPoints,
      'station',
    ));
    removeFromParent();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _flashTimer -= dt;
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

    // Flash white on hit
    if (_flashTimer > 0) {
      final flashPaint = Paint()
        ..color = const Color(0xCCFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawPath(_shape, flashPaint);
    }

    NeonRenderer.drawNeonPath(canvas, _shape, _glowPaint, _solidPaint);

    // HP bar above station
    const barWidth = 40.0;
    const barHeight = 3.0;
    const barY = -20.0;
    const barX = -barWidth / 2;

    canvas.drawRect(
      const Rect.fromLTWH(barX, barY, barWidth, barHeight),
      _hpBarBgPaint,
    );
    final hpRatio = _hp / _maxHp;
    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barWidth * hpRatio, barHeight),
      _hpBarPaint,
    );

    canvas.restore();
  }
}
