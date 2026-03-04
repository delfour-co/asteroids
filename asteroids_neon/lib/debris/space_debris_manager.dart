import 'dart:math';

import 'package:flame/components.dart';

import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../core/game_state.dart';
import '../enemies/ufo_events.dart';
import 'space_station.dart';
import 'starlink_train.dart';
import 'tesla_roadster.dart';

/// Manages space debris spawning — guaranteed every 2 waves + random timer.
///
/// Follows UfoManager pattern: listens to WaveStartedEvent and GameOverEvent.
class SpaceDebrisManager extends Component with HasGameReference {
  static final Random _random = Random();

  bool _gameOver = false;
  double _randomTimer = 0;

  late final void Function(WaveStartedEvent) _waveListener;
  late final void Function(GameOverEvent) _gameOverListener;

  @override
  Future<void> onLoad() async {
    _waveListener = _onWaveStarted;
    _gameOverListener = (_) => _gameOver = true;
    eventBus.on<WaveStartedEvent>(_waveListener);
    eventBus.on<GameOverEvent>(_gameOverListener);

    _resetRandomTimer();
  }

  @override
  void onRemove() {
    eventBus.off<WaveStartedEvent>(_waveListener);
    eventBus.off<GameOverEvent>(_gameOverListener);
    super.onRemove();
  }

  void _onWaveStarted(WaveStartedEvent event) {
    // Guaranteed spawn on even waves starting at wave 2
    if (event.wave >= 2 && event.wave % 2 == 0) {
      _spawnDebris();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_gameOver) return;

    _randomTimer -= dt;
    if (_randomTimer <= 0) {
      _spawnDebris();
      _resetRandomTimer();
    }
  }

  void _resetRandomTimer() {
    _randomTimer = 20.0 + _random.nextDouble() * 20.0; // 20-40s
  }

  void _spawnDebris() {
    final gameSize = game.size;
    final roll = _random.nextDouble();

    final Component debris;
    if (roll < 0.40) {
      debris = _createStarlink(gameSize);
    } else if (roll < 0.75) {
      debris = _createStation(gameSize);
    } else {
      debris = _createTesla(gameSize);
    }

    add(debris);
  }

  StarlinkTrain _createStarlink(Vector2 gameSize) {
    final spawnData = _randomEdgeSpawn(gameSize);
    final train = StarlinkTrain(velocity: spawnData.velocity);
    train.position = spawnData.position;
    return train;
  }

  SpaceStation _createStation(Vector2 gameSize) {
    final spawnData = _randomEdgeSpawn(gameSize);
    final station = SpaceStation(
      velocity: spawnData.velocity,
      rotationSpeed: 0.05 + _random.nextDouble() * 0.15,
    );
    station.position = spawnData.position;
    return station;
  }

  TeslaRoadster _createTesla(Vector2 gameSize) {
    final spawnData = _randomEdgeSpawn(gameSize);
    final tesla = TeslaRoadster(
      velocity: spawnData.velocity,
      rotationSpeed: 0.03 + _random.nextDouble() * 0.1,
    );
    tesla.position = spawnData.position;
    return tesla;
  }

  ({Vector2 position, Vector2 velocity}) _randomEdgeSpawn(Vector2 gameSize) {
    final speed = GameConfig.debrisMinSpeed +
        _random.nextDouble() * (GameConfig.debrisMaxSpeed - GameConfig.debrisMinSpeed);

    final edge = _random.nextInt(4);
    final Vector2 pos;
    final Vector2 dir;

    switch (edge) {
      case 0: // Top
        pos = Vector2(_random.nextDouble() * gameSize.x, -40);
        dir = Vector2((_random.nextDouble() - 0.5) * 0.5, 1)..normalize();
      case 1: // Right
        pos = Vector2(gameSize.x + 40, _random.nextDouble() * gameSize.y);
        dir = Vector2(-1, (_random.nextDouble() - 0.5) * 0.5)..normalize();
      case 2: // Bottom
        pos = Vector2(_random.nextDouble() * gameSize.x, gameSize.y + 40);
        dir = Vector2((_random.nextDouble() - 0.5) * 0.5, -1)..normalize();
      default: // Left
        pos = Vector2(-40, _random.nextDouble() * gameSize.y);
        dir = Vector2(1, (_random.nextDouble() - 0.5) * 0.5)..normalize();
    }

    return (position: pos, velocity: dir * speed);
  }

  /// Remove all debris (for game over / restart).
  void clearAll() {
    children.whereType<StarlinkTrain>().toList().forEach((d) => d.removeFromParent());
    children.whereType<SpaceStation>().toList().forEach((d) => d.removeFromParent());
    children.whereType<TeslaRoadster>().toList().forEach((d) => d.removeFromParent());
  }
}
