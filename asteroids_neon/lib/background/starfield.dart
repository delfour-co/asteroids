import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../core/game_config.dart';

/// A single star's pre-computed data.
class _Star {
  final double x;
  final double y;
  final double radius;
  final Paint paint;

  _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.paint,
  });
}

/// Generates and renders static stars on a dark background.
///
/// Stars are generated once in onLoad() and rendered every frame.
/// All Paint objects are pre-allocated — nothing created in render().
class Starfield extends PositionComponent
    with HasGameReference<FlameGame> {
  final List<_Star> _stars = [];
  final Random _random = Random();

  // Pre-allocated background paint
  final Paint _bgPaint = Paint()..color = GameConfig.backgroundColor;

  @override
  Future<void> onLoad() async {
    size = game.size;
    _generateStars();
  }

  void _generateStars() {
    _stars.clear();
    for (int i = 0; i < GameConfig.starCount; i++) {
      final opacity = GameConfig.starMinOpacity +
          _random.nextDouble() *
              (GameConfig.starMaxOpacity - GameConfig.starMinOpacity);
      final radius = GameConfig.starMinSize +
          _random.nextDouble() *
              (GameConfig.starMaxSize - GameConfig.starMinSize);

      _stars.add(_Star(
        x: _random.nextDouble() * size.x,
        y: _random.nextDouble() * size.y,
        radius: radius * 0.5,
        paint: Paint()..color = Color.fromRGBO(255, 255, 255, opacity),
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    // Fill background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      _bgPaint,
    );

    // Draw stars
    for (final star in _stars) {
      canvas.drawCircle(Offset(star.x, star.y), star.radius, star.paint);
    }
  }
}
