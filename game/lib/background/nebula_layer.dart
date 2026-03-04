import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Galaxy background layer inspired by Antennae Galaxies (NGC 4038/4039).
///
/// All geometry and paints are pre-computed in onLoad().
/// Zero allocations in render().
class NebulaLayer extends PositionComponent with HasGameReference<FlameGame> {
  // Pre-computed draw commands
  final List<_NebulaBlob> _dustClouds = [];
  final List<_TidalTail> _tidalTails = [];
  final List<_NebulaBlob> _cores = [];
  final List<_StarDot> _starClusters = [];

  @override
  Future<void> onLoad() async {
    size = game.size;
    final rng = Random(42); // Seeded for deterministic layout
    final w = size.x;
    final h = size.y;

    // Layer 1: Dust clouds (10 blobs) — rose/violet, very low opacity
    for (int i = 0; i < 10; i++) {
      final x = rng.nextDouble() * w;
      final y = rng.nextDouble() * h;
      final radius = 60.0 + rng.nextDouble() * 120.0;
      final opacity = 0.025 + rng.nextDouble() * 0.030;
      // Alternate between rose and violet hues
      final color = i % 2 == 0
          ? Color.fromRGBO(180, 60, 120, opacity)
          : Color.fromRGBO(100, 40, 160, opacity);
      _dustClouds.add(_NebulaBlob(
        center: Offset(x, y),
        radius: radius,
        paint: Paint()
          ..color = color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.6),
      ));
    }

    // Layer 2: Tidal tails (2 curves) — cyan, low opacity
    _tidalTails.add(_TidalTail(
      path: Path()
        ..moveTo(w * 0.15, h * 0.3)
        ..cubicTo(w * 0.35, h * 0.15, w * 0.55, h * 0.45, w * 0.8, h * 0.25),
      paint: Paint()
        ..color = const Color.fromRGBO(0, 200, 255, 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 30.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    ));
    _tidalTails.add(_TidalTail(
      path: Path()
        ..moveTo(w * 0.25, h * 0.75)
        ..cubicTo(w * 0.45, h * 0.6, w * 0.65, h * 0.85, w * 0.9, h * 0.65),
      paint: Paint()
        ..color = const Color.fromRGBO(0, 200, 255, 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 30.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    ));

    // Layer 3: Galactic cores (2 blobs) — amber/gold, slightly higher opacity
    _cores.add(_NebulaBlob(
      center: Offset(w * 0.38, h * 0.35),
      radius: 40.0,
      paint: Paint()
        ..color = const Color.fromRGBO(255, 180, 0, 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    ));
    _cores.add(_NebulaBlob(
      center: Offset(w * 0.62, h * 0.6),
      radius: 35.0,
      paint: Paint()
        ..color = const Color.fromRGBO(255, 200, 50, 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25),
    ));

    // Layer 4: Star clusters (25 dots) — cyan, higher opacity small dots
    for (int i = 0; i < 25; i++) {
      // Cluster around the two cores with some spread
      final clusterCenter = i < 13
          ? Offset(w * 0.38, h * 0.35)
          : Offset(w * 0.62, h * 0.6);
      final spread = 80.0 + rng.nextDouble() * 60.0;
      final angle = rng.nextDouble() * 2 * pi;
      final dist = rng.nextDouble() * spread;
      final x = clusterCenter.dx + cos(angle) * dist;
      final y = clusterCenter.dy + sin(angle) * dist;
      final opacity = 0.3 + rng.nextDouble() * 0.4;
      final radius = 0.5 + rng.nextDouble() * 1.5;

      _starClusters.add(_StarDot(
        center: Offset(x, y),
        radius: radius,
        paint: Paint()..color = Color.fromRGBO(150, 230, 255, opacity),
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    // Layer 1: Dust clouds
    for (final blob in _dustClouds) {
      canvas.drawCircle(blob.center, blob.radius, blob.paint);
    }

    // Layer 2: Tidal tails
    for (final tail in _tidalTails) {
      canvas.drawPath(tail.path, tail.paint);
    }

    // Layer 3: Galactic cores
    for (final core in _cores) {
      canvas.drawCircle(core.center, core.radius, core.paint);
    }

    // Layer 4: Star clusters
    for (final star in _starClusters) {
      canvas.drawCircle(star.center, star.radius, star.paint);
    }
  }
}

class _NebulaBlob {
  final Offset center;
  final double radius;
  final Paint paint;
  _NebulaBlob({required this.center, required this.radius, required this.paint});
}

class _TidalTail {
  final Path path;
  final Paint paint;
  _TidalTail({required this.path, required this.paint});
}

class _StarDot {
  final Offset center;
  final double radius;
  final Paint paint;
  _StarDot({required this.center, required this.radius, required this.paint});
}
