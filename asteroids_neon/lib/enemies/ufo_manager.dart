import 'dart:math';

import 'package:flame/components.dart';

import '../core/event_bus.dart';
import '../core/game_state.dart';
import 'enemy_projectile.dart';
import 'ufo_events.dart';
import 'ufo_boss.dart';
import 'ufo_hunter.dart';
import 'ufo_scout.dart';

/// Manages UFO spawning based on wave progression.
///
/// Scouts appear from wave 3+, Hunters from wave 6+.
/// UFOs spawn during waves with random timing.
class UfoManager extends Component with HasGameReference {
  static final Random _random = Random();

  int _currentWave = 0;
  double _spawnTimer = 0;
  bool _gameOver = false;

  // Spawn intervals decrease with waves
  static const double _baseSpawnInterval = 12.0;
  static const double _minSpawnInterval = 5.0;
  static const int _scoutStartWave = 4;
  static const int _hunterStartWave = 8;
  static const int _bossInterval = 5; // Boss every N waves

  late final void Function(WaveStartedEvent) _waveListener;
  late final void Function(GameOverEvent) _gameOverListener;

  @override
  Future<void> onLoad() async {
    _waveListener = _onWaveStarted;
    _gameOverListener = (_) => _gameOver = true;
    eventBus.on<WaveStartedEvent>(_waveListener);
    eventBus.on<GameOverEvent>(_gameOverListener);
  }

  @override
  void onRemove() {
    eventBus.off<WaveStartedEvent>(_waveListener);
    eventBus.off<GameOverEvent>(_gameOverListener);
    super.onRemove();
  }

  void _onWaveStarted(WaveStartedEvent event) {
    _currentWave = event.wave;
    // Reset timer for new wave
    _spawnTimer = 3.0 + _random.nextDouble() * 3.0; // Delay before first UFO

    // Spawn boss every N waves (starting at wave 5)
    if (_currentWave >= _bossInterval && _currentWave % _bossInterval == 0) {
      _spawnBoss(game.size);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_gameOver || _currentWave < _scoutStartWave) return;

    _spawnTimer -= dt;
    if (_spawnTimer <= 0) {
      _spawnUfo();
      // Next spawn interval — decreases with wave
      final interval = (_baseSpawnInterval - _currentWave * 0.5)
          .clamp(_minSpawnInterval, _baseSpawnInterval);
      _spawnTimer = interval + _random.nextDouble() * 3.0;
    }
  }

  void _spawnUfo() {
    final gameSize = game.size;

    // Decide type based on wave
    final bool spawnHunter =
        _currentWave >= _hunterStartWave && _random.nextDouble() < 0.4;

    if (spawnHunter) {
      _spawnHunter(gameSize);
    } else {
      _spawnScout(gameSize);
    }
  }

  void _spawnScout(Vector2 gameSize) {
    final scout = UfoScout();

    // Spawn from a random edge and travel across
    final fromLeft = _random.nextBool();
    final y = 40.0 + _random.nextDouble() * (gameSize.y - 80);

    if (fromLeft) {
      scout.position = Vector2(-20, y);
      scout.setDirection(Vector2(1, (_random.nextDouble() - 0.5) * 0.5)
        ..normalize());
    } else {
      scout.position = Vector2(gameSize.x + 20, y);
      scout.setDirection(Vector2(-1, (_random.nextDouble() - 0.5) * 0.5)
        ..normalize());
    }

    add(scout);
  }

  void _spawnHunter(Vector2 gameSize) {
    final hunter = UfoHunter();

    // Spawn from random edge
    final edge = _random.nextInt(4);
    switch (edge) {
      case 0:
        hunter.position =
            Vector2(_random.nextDouble() * gameSize.x, -20);
      case 1:
        hunter.position =
            Vector2(gameSize.x + 20, _random.nextDouble() * gameSize.y);
      case 2:
        hunter.position =
            Vector2(_random.nextDouble() * gameSize.x, gameSize.y + 20);
      default:
        hunter.position =
            Vector2(-20, _random.nextDouble() * gameSize.y);
    }

    add(hunter);
  }

  void _spawnBoss(Vector2 gameSize) {
    final boss = UfoBoss();
    // Spawn from top of screen
    boss.position = Vector2(
      gameSize.x * 0.2 + _random.nextDouble() * gameSize.x * 0.6,
      -40,
    );
    add(boss);
  }

  /// Remove all UFOs and enemy projectiles (for restart).
  void clearAll() {
    children.whereType<UfoScout>().toList().forEach((u) => u.removeFromParent());
    children.whereType<UfoHunter>().toList().forEach((u) => u.removeFromParent());
    children.whereType<UfoBoss>().toList().forEach((u) => u.removeFromParent());
    children
        .whereType<EnemyProjectile>()
        .toList()
        .forEach((p) => p.removeFromParent());
  }
}
