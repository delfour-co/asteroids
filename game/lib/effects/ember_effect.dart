import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../core/game_config.dart';

/// Slow-drifting ember particles that linger after an explosion.
///
/// Spawned by EffectsManager for medium/large asteroids, UFOs, boss, ship.
class EmberEffect extends PositionComponent {
  final Color color;
  final int particleCount;

  late final List<_EmberParticle> _particles;

  static final Random _random = Random();

  // Pre-allocated paints
  late final Paint _corePaint;
  late final Paint _glowPaint;

  EmberEffect({
    required this.color,
    required this.particleCount,
  });

  @override
  Future<void> onLoad() async {
    // Darker version of the explosion color for embers
    final r = (color.r * 0.6).toInt();
    final g = (color.g * 0.6).toInt();
    final b = (color.b * 0.6).toInt();
    final dimColor = Color.fromARGB(255, r, g, b);

    _corePaint = Paint()..color = dimColor;
    _glowPaint = Paint()
      ..color = dimColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    _particles = List.generate(particleCount, (_) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = GameConfig.emberMinSpeed +
          _random.nextDouble() * (GameConfig.emberMaxSpeed - GameConfig.emberMinSpeed);
      final size = GameConfig.emberMinSize +
          _random.nextDouble() * (GameConfig.emberMaxSize - GameConfig.emberMinSize);
      final lifetime = GameConfig.emberMinLifetime +
          _random.nextDouble() * (GameConfig.emberMaxLifetime - GameConfig.emberMinLifetime);
      return _EmberParticle(
        dx: cos(angle) * speed,
        dy: sin(angle) * speed,
        size: size,
        lifetime: lifetime,
      );
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    bool anyAlive = false;
    for (final p in _particles) {
      if (p.dead) continue;
      p.elapsed += dt;
      if (p.elapsed >= p.lifetime) {
        p.dead = true;
        continue;
      }
      anyAlive = true;
      p.x += p.dx * dt;
      p.y += p.dy * dt;
      // Exponential drag
      final drag = pow(0.15, dt).toDouble();
      p.dx *= drag;
      p.dy *= drag;
    }

    if (!anyAlive) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    for (final p in _particles) {
      if (p.dead) continue;
      final progress = (p.elapsed / p.lifetime).clamp(0.0, 1.0);
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      final offset = Offset(p.x, p.y);
      _glowPaint.color = _corePaint.color.withValues(alpha: opacity * 0.4);
      canvas.drawCircle(offset, p.size * 2, _glowPaint);

      _corePaint.color = _corePaint.color.withValues(alpha: opacity);
      canvas.drawCircle(offset, p.size, _corePaint);
    }
  }
}

class _EmberParticle {
  double x = 0;
  double y = 0;
  double dx;
  double dy;
  final double size;
  final double lifetime;
  double elapsed = 0;
  bool dead = false;

  _EmberParticle({
    required this.dx,
    required this.dy,
    required this.size,
    required this.lifetime,
  });
}
