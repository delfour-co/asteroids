import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// A burst of neon particles that fades out.
///
/// Spawned when asteroids or ship are destroyed.
class Explosion extends PositionComponent {
  final Color color;
  final int particleCount;
  final double maxSpeed;
  final double duration;

  late final List<_Particle> _particles;
  double _elapsed = 0;

  static final Random _random = Random();

  Explosion({
    required this.color,
    this.particleCount = 12,
    this.maxSpeed = 120.0,
    this.duration = 0.6,
  });

  @override
  Future<void> onLoad() async {
    _particles = List.generate(particleCount, (_) {
      // Quantize angles to 45° increments for geometric feel
      final angleIndex = _random.nextInt(8);
      final angle = angleIndex * (pi / 4);
      final speed = 30.0 + _random.nextDouble() * maxSpeed;
      final size = 1.0 + _random.nextDouble() * 2.5;
      return _Particle(
        dx: cos(angle) * speed,
        dy: sin(angle) * speed,
        size: size,
      );
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
      return;
    }

    for (final p in _particles) {
      p.x += p.dx * dt;
      p.y += p.dy * dt;
      // Slow down
      p.dx *= 0.96;
      p.dy *= 0.96;
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = _elapsed / duration;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    final paint = Paint()..color = color.withValues(alpha: opacity);
    final glowPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (final p in _particles) {
      final offset = Offset(p.x, p.y);
      // Tron-style geometric fragments
      final rect = Rect.fromCenter(
        center: offset,
        width: p.size * 2,
        height: p.size * 1.2,
      );
      final glowRect = Rect.fromCenter(
        center: offset,
        width: p.size * 2.5,
        height: p.size * 1.8,
      );
      canvas.drawRect(glowRect, glowPaint);
      canvas.drawRect(rect, paint);
    }
  }
}

class _Particle {
  double x = 0;
  double y = 0;
  double dx;
  double dy;
  final double size;

  _Particle({required this.dx, required this.dy, required this.size});
}
