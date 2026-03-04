import 'dart:math';

import 'package:flame/components.dart';

import '../core/event_bus.dart';
import '../core/game_state.dart';
import '../enemies/ufo_events.dart';
import 'asteroid.dart';

/// Manages asteroid spawning, splitting, and lifecycle.
///
/// Spawns initial wave of asteroids at game start.
/// Listens for AsteroidDestroyedEvent to handle splitting.
/// Spawns new wave when all asteroids are destroyed.
class AsteroidManager extends Component with HasGameReference {
  static final Random _random = Random();

  // Wave config
  int _wave = 0;
  static const int _baseAsteroidCount = 4;

  bool _gameOver = false;
  bool _waveActive = false;

  // Event listeners
  late final void Function(AsteroidDestroyedEvent) _destroyedListener;
  late final void Function(GameOverEvent) _gameOverListener;

  @override
  Future<void> onLoad() async {
    _destroyedListener = _onAsteroidDestroyed;
    _gameOverListener = (_) => _gameOver = true;
    eventBus.on<AsteroidDestroyedEvent>(_destroyedListener);
    eventBus.on<GameOverEvent>(_gameOverListener);
    _spawnWave();
  }

  @override
  void onRemove() {
    eventBus.off<AsteroidDestroyedEvent>(_destroyedListener);
    eventBus.off<GameOverEvent>(_gameOverListener);
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_gameOver || !_waveActive) return;

    // Check if all asteroids are destroyed — spawn new wave
    if (children.whereType<Asteroid>().isEmpty) {
      _waveActive = false;
      // Small delay before next wave
      Future.delayed(const Duration(seconds: 2), () {
        if (!_gameOver && isMounted) {
          _spawnWave();
        }
      });
    }
  }

  void _spawnWave() {
    _wave++;
    _waveActive = true;
    eventBus.emit(WaveStartedEvent(_wave));
    final count = (_baseAsteroidCount + (_wave - 1)).clamp(0, 12);
    final gameSize = game.size;

    // Speed scales with wave: +10% per wave (sqrt scaling for gentle ramp)
    final speedMultiplier = 1.0 + sqrt(_wave.toDouble()) * 0.15;

    for (int i = 0; i < count; i++) {
      final asteroid = Asteroid(asteroidSize: AsteroidSize.large);

      // Spawn on screen edges to avoid spawning on ship
      final edge = _random.nextInt(4);
      double x, y;
      switch (edge) {
        case 0: // Top
          x = _random.nextDouble() * gameSize.x;
          y = -20;
        case 1: // Right
          x = gameSize.x + 20;
          y = _random.nextDouble() * gameSize.y;
        case 2: // Bottom
          x = _random.nextDouble() * gameSize.x;
          y = gameSize.y + 20;
        default: // Left
          x = -20;
          y = _random.nextDouble() * gameSize.y;
      }

      asteroid.position = Vector2(x, y);

      // Random velocity towards center-ish area (scaled by wave)
      final speed = (30.0 + _random.nextDouble() * 50.0) * speedMultiplier;
      final angle = _random.nextDouble() * 2 * pi;
      asteroid.setVelocity(Vector2(cos(angle) * speed, sin(angle) * speed));

      add(asteroid);
    }
  }

  void _onAsteroidDestroyed(AsteroidDestroyedEvent event) {
    if (_gameOver) return;

    // Split asteroid into smaller pieces
    final nextSize = _getNextSize(event.asteroidSize);
    if (nextSize != null) {
      final speedMultiplier = 1.0 + sqrt(_wave.toDouble()) * 0.15;
      for (int i = 0; i < 2; i++) {
        final child = Asteroid(asteroidSize: nextSize);
        child.position = event.position.clone();

        // Random velocity diverging from parent (scaled by wave)
        final speed = (40.0 + _random.nextDouble() * 60.0) * speedMultiplier;
        final angle = _random.nextDouble() * 2 * pi;
        child.setVelocity(Vector2(cos(angle) * speed, sin(angle) * speed));

        add(child);
      }
    }
  }

  AsteroidSize? _getNextSize(AsteroidSize size) {
    switch (size) {
      case AsteroidSize.large:
        return AsteroidSize.medium;
      case AsteroidSize.medium:
        return AsteroidSize.small;
      case AsteroidSize.small:
        return null; // Fully destroyed
    }
  }
}
