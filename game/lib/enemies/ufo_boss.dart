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

/// Boss UFO — large, multi-hit enemy that appears every 5 waves.
///
/// Red neon octagonal shape. Has 5 HP. Alternates between attack patterns:
/// - Spread shot (fan of 5 projectiles)
/// - Aimed burst (3 rapid shots at player)
/// Moves slowly across screen, periodically charging at player.
class UfoBoss extends PositionComponent
    with HasGameReference, CollisionCallbacks {
  static const double _radius = 32.0;
  static const int _maxHp = 5;
  static const double _speed = 60.0;
  static const Color _color = Color(0xFFFF0044); // Red neon
  static const int _points = 2000;

  late final Path _shape;
  late final Paint _glowPaint;
  late final Paint _solidPaint;
  late final Paint _hpBarPaint;
  late final Paint _hpBarBgPaint;

  final Vector2 _velocity = Vector2.zero();
  int _hp = _maxHp;
  double _attackTimer = 0;
  int _attackPattern = 0; // 0 = spread, 1 = burst
  double _burstTimer = 0;
  int _burstCount = 0;
  double _movePhase = 0;

  // Damage flash
  double _flashTimer = 0;

  static final Random _random = Random();

  UfoBoss() {
    size = Vector2.all(_radius * 2);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    // Octagonal shape
    _shape = Path();
    for (int i = 0; i < 8; i++) {
      final a = (i * pi / 4) - pi / 8;
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
      glowRadius: 10.0,
      glowOpacity: 0.7,
      strokeWidth: 2.0,
    );
    _glowPaint = paints.glow;
    _solidPaint = paints.solid;

    _hpBarPaint = Paint()..color = _color;
    _hpBarBgPaint = Paint()..color = const Color(0x44FF0044);

    await add(CircleHitbox(radius: _radius));

    _attackTimer = 2.0 + _random.nextDouble() * 1.5;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Projectile) {
      other.removeFromParent();
      _takeDamage();
    } else if (other is Ship && !other.invulnerable) {
      eventBus.emit(ShipDestroyedEvent(other.position.clone()));
      other.removeFromParent();
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
    eventBus.emit(UfoDestroyedEvent(position.clone(), _points));
    eventBus.emit(BossDefeatedEvent(position.clone()));
    removeFromParent();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _flashTimer -= dt;
    _movePhase += dt;

    final ship = _findShip();
    final sm = GameConfig.enemySpeedMultiplier;

    // Movement: slow drift towards player with sinusoidal weave
    if (ship != null) {
      final toShip = ship.position - position;
      if (toShip.length > 0) {
        toShip.normalize();
        _velocity.setFrom(toShip * _speed);
      }
    }

    // Add sinusoidal weave
    final weaveX = cos(_movePhase * 1.5) * 40.0;
    final weaveY = sin(_movePhase * 2.0) * 25.0;

    position.x += (_velocity.x + weaveX * dt) * dt * sm;
    position.y += (_velocity.y + weaveY * dt) * dt * sm;

    // Wrap around
    _wrapAround();

    // Attack logic
    if (_burstCount > 0) {
      _burstTimer -= dt;
      if (_burstTimer <= 0 && ship != null) {
        _burstTimer = 0.2;
        _burstCount--;
        _fireAimed(ship);
      }
    } else {
      _attackTimer -= dt;
      if (_attackTimer <= 0 && ship != null) {
        _attackTimer = 3.0 + _random.nextDouble() * 2.0;
        _executeAttack(ship);
        _attackPattern = (_attackPattern + 1) % 2;
      }
    }
  }

  void _executeAttack(Ship ship) {
    switch (_attackPattern) {
      case 0:
        _fireSpread(ship);
      case 1:
        _burstCount = 3;
        _burstTimer = 0;
    }
  }

  void _fireSpread(Ship ship) {
    final baseDir = ship.position - position;
    if (baseDir.length > 0) baseDir.normalize();

    for (int i = -2; i <= 2; i++) {
      final spread = i * 0.25; // ~14 degrees apart
      final dir = Vector2(
        baseDir.x * cos(spread) - baseDir.y * sin(spread),
        baseDir.x * sin(spread) + baseDir.y * cos(spread),
      );
      final projectile = EnemyProjectile();
      projectile.init(pos: position.clone(), target: position + dir * 100);
      parent?.add(projectile);
    }
  }

  void _fireAimed(Ship ship) {
    final spread = (_random.nextDouble() - 0.5) * 0.1;
    final dir = ship.position - position;
    if (dir.length > 0) dir.normalize();
    final rotatedDir = Vector2(
      dir.x * cos(spread) - dir.y * sin(spread),
      dir.x * sin(spread) + dir.y * cos(spread),
    );
    final projectile = EnemyProjectile();
    projectile.init(pos: position.clone(), target: position + rotatedDir * 100);
    parent?.add(projectile);
  }

  void _wrapAround() {
    final gameSize = game.size;
    if (position.x < -_radius) position.x = gameSize.x + _radius;
    if (position.x > gameSize.x + _radius) position.x = -_radius;
    if (position.y < -_radius) position.y = gameSize.y + _radius;
    if (position.y > gameSize.y + _radius) position.y = -_radius;
  }

  Ship? _findShip() {
    final gameLayer = parent?.parent;
    if (gameLayer == null) return null;
    for (final child in gameLayer.children) {
      if (child is Ship) return child;
    }
    return null;
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

    // Inner glow fill
    final fillPaint = Paint()..color = _color.withValues(alpha: 0.1);
    canvas.drawPath(_shape, fillPaint);

    // HP bar above boss
    final barWidth = _radius * 1.8;
    final barHeight = 4.0;
    final barY = -_radius - 12.0;
    final barX = -barWidth / 2;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barWidth, barHeight),
      _hpBarBgPaint,
    );
    // Fill
    final hpRatio = _hp / _maxHp;
    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barWidth * hpRatio, barHeight),
      _hpBarPaint,
    );

    canvas.restore();
  }
}
