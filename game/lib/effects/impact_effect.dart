import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// Small burst of sparks at projectile impact point.
class ImpactEffect extends PositionComponent {
  final Color color;

  static const int _count = 6;
  static const double _duration = 0.3;
  static final Random _rng = Random();

  late final List<_Spark> _sparks;
  double _elapsed = 0;

  ImpactEffect({required this.color});

  @override
  Future<void> onLoad() async {
    _sparks = List.generate(_count, (_) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 40.0 + _rng.nextDouble() * 80.0;
      return _Spark(
        dx: cos(angle) * speed,
        dy: sin(angle) * speed,
        size: 0.5 + _rng.nextDouble() * 1.5,
      );
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= _duration) {
      removeFromParent();
      return;
    }
    for (final s in _sparks) {
      s.x += s.dx * dt;
      s.y += s.dy * dt;
      s.dx *= 0.92;
      s.dy *= 0.92;
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = _elapsed / _duration;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    final paint = Paint()..color = color.withValues(alpha: opacity);
    final glowPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (final s in _sparks) {
      final offset = Offset(s.x, s.y);
      canvas.drawCircle(offset, s.size * 1.2, glowPaint);
      canvas.drawCircle(offset, s.size, paint);
    }
  }
}

class _Spark {
  double x = 0;
  double y = 0;
  double dx;
  double dy;
  final double size;

  _Spark({required this.dx, required this.dy, required this.size});
}
