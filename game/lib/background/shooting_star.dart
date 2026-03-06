import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../enemies/ufo_events.dart';

/// A single shooting star with position, velocity and remaining lifetime.
class _ShootingStar {
  double x;
  double y;
  final double vx;
  final double vy;
  double lifetime;
  final double maxLifetime;

  _ShootingStar({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.lifetime,
  }) : maxLifetime = lifetime;
}

/// Spawns shooting stars at random intervals across the screen.
///
/// Added as a child of BackgroundLayer. Listens to WaveStartedEvent
/// to increase frequency as waves progress.
class ShootingStarManager extends Component with HasGameReference<FlameGame> {
  final Random _random = Random();
  final List<_ShootingStar> _stars = [];

  double _spawnTimer = 0;
  double _currentMinInterval = GameConfig.shootingStarMinInterval;
  double _currentMaxInterval = GameConfig.shootingStarMaxInterval;
  late double _nextSpawnTime;

  // Pre-allocated paints
  late final Paint _glowPaint;
  late final Paint _corePaint;

  late final void Function(WaveStartedEvent) _waveListener;

  @override
  Future<void> onLoad() async {
    _glowPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    _corePaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    _nextSpawnTime = _randomInterval();

    _waveListener = _onWaveStarted;
    eventBus.on<WaveStartedEvent>(_waveListener);
  }

  @override
  void onRemove() {
    eventBus.off<WaveStartedEvent>(_waveListener);
    super.onRemove();
  }

  void _onWaveStarted(WaveStartedEvent event) {
    // Decrease interval by 10% per wave, minimum 3 seconds
    _currentMinInterval = (_currentMinInterval * 0.9).clamp(3.0, double.infinity);
    _currentMaxInterval = (_currentMaxInterval * 0.9).clamp(3.0, double.infinity);
    // Ensure max >= min
    if (_currentMaxInterval < _currentMinInterval) {
      _currentMaxInterval = _currentMinInterval;
    }
  }

  double _randomInterval() {
    return _currentMinInterval +
        _random.nextDouble() * (_currentMaxInterval - _currentMinInterval);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Spawn logic
    _spawnTimer += dt;
    if (_spawnTimer >= _nextSpawnTime) {
      _spawnTimer = 0;
      _nextSpawnTime = _randomInterval();
      _spawnStar();
    }

    // Update active stars
    final gameSize = game.size;
    _stars.removeWhere((star) {
      star.x += star.vx * dt;
      star.y += star.vy * dt;
      star.lifetime -= dt;

      // Remove if lifetime expired or off screen (with margin for tail)
      final margin = GameConfig.shootingStarLength + 20;
      return star.lifetime <= 0 ||
          star.x < -margin ||
          star.x > gameSize.x + margin ||
          star.y < -margin ||
          star.y > gameSize.y + margin;
    });
  }

  void _spawnStar() {
    final gameSize = game.size;

    // Pick a random edge: 0=top, 1=right, 2=bottom, 3=left
    final edge = _random.nextInt(4);
    double startX;
    double startY;

    switch (edge) {
      case 0: // top
        startX = _random.nextDouble() * gameSize.x;
        startY = 0;
      case 1: // right
        startX = gameSize.x;
        startY = _random.nextDouble() * gameSize.y;
      case 2: // bottom
        startX = _random.nextDouble() * gameSize.x;
        startY = gameSize.y;
      default: // left
        startX = 0;
        startY = _random.nextDouble() * gameSize.y;
    }

    // Aim diagonally toward the center area with some randomness
    final targetX = gameSize.x * (0.2 + _random.nextDouble() * 0.6);
    final targetY = gameSize.y * (0.2 + _random.nextDouble() * 0.6);
    final dx = targetX - startX;
    final dy = targetY - startY;
    final dist = sqrt(dx * dx + dy * dy);
    final speed = GameConfig.shootingStarSpeed;

    _stars.add(_ShootingStar(
      x: startX,
      y: startY,
      vx: (dx / dist) * speed,
      vy: (dy / dist) * speed,
      lifetime: 1.5,
    ));
  }

  @override
  void render(Canvas canvas) {
    for (final star in _stars) {
      final progress = (star.lifetime / star.maxLifetime).clamp(0.0, 1.0);
      final tailLength = GameConfig.shootingStarLength;

      // Direction for tail (opposite of velocity)
      final speed = sqrt(star.vx * star.vx + star.vy * star.vy);
      if (speed == 0) continue;
      final tailDx = -(star.vx / speed) * tailLength;
      final tailDy = -(star.vy / speed) * tailLength;

      final headOffset = Offset(star.x, star.y);
      final tailOffset = Offset(star.x + tailDx, star.y + tailDy);

      // Glow line (wider, blurred)
      _glowPaint.color = Color.fromRGBO(255, 255, 255, 0.3 * progress);
      canvas.drawLine(headOffset, tailOffset, _glowPaint);

      // Core line (thin, bright)
      _corePaint.color = Color.fromRGBO(255, 255, 255, 0.9 * progress);
      canvas.drawLine(headOffset, tailOffset, _corePaint);
    }
  }
}
