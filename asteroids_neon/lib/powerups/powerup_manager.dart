import 'dart:math';

import 'package:flame/components.dart';

import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../core/game_state.dart';
import '../enemies/ufo_events.dart';
import 'powerup.dart';

/// Event emitted when a power-up effect activates or expires.
class PowerUpActiveEvent {
  final PowerUpType type;
  final bool active;
  PowerUpActiveEvent(this.type, this.active);
}

/// Manages power-up spawning from UFO kills and active effect timers.
class PowerUpManager extends Component with HasGameReference {
  static final Random _random = Random();
  static const double _dropChance = 0.35; // 35% chance per UFO kill

  // Active effect timers
  final Map<PowerUpType, double> _activeTimers = {};

  late final void Function(UfoDestroyedEvent) _ufoListener;
  late final void Function(PowerUpCollectedEvent) _collectListener;
  late final void Function(GameOverEvent) _gameOverListener;

  /// Whether a specific power-up is currently active.
  bool isActive(PowerUpType type) => (_activeTimers[type] ?? 0) > 0;

  @override
  Future<void> onLoad() async {
    _ufoListener = _onUfoDestroyed;
    _collectListener = _onPowerUpCollected;
    _gameOverListener = (_) => _clearAllEffects();
    eventBus.on<UfoDestroyedEvent>(_ufoListener);
    eventBus.on<PowerUpCollectedEvent>(_collectListener);
    eventBus.on<GameOverEvent>(_gameOverListener);
  }

  @override
  void onRemove() {
    eventBus.off<UfoDestroyedEvent>(_ufoListener);
    eventBus.off<PowerUpCollectedEvent>(_collectListener);
    eventBus.off<GameOverEvent>(_gameOverListener);
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Tick down active effects
    final expired = <PowerUpType>[];
    for (final entry in _activeTimers.entries) {
      _activeTimers[entry.key] = entry.value - dt;
      if (_activeTimers[entry.key]! <= 0) {
        expired.add(entry.key);
      }
    }
    for (final type in expired) {
      _activeTimers.remove(type);
      eventBus.emit(PowerUpActiveEvent(type, false));
      if (type == PowerUpType.slowMo) {
        GameConfig.enemySpeedMultiplier = 1.0;
      }
    }
  }

  void _onUfoDestroyed(UfoDestroyedEvent event) {
    if (_random.nextDouble() < _dropChance) {
      _spawnPowerUp(event.position);
    }
  }

  void _spawnPowerUp(Vector2 position) {
    final types = PowerUpType.values;
    final type = types[_random.nextInt(types.length)];
    final powerUp = PowerUp(type: type)..position = position.clone();
    add(powerUp);
  }

  void _onPowerUpCollected(PowerUpCollectedEvent event) {
    _activeTimers[event.type] = GameConfig.upgradeDuration;
    eventBus.emit(PowerUpActiveEvent(event.type, true));
    if (event.type == PowerUpType.slowMo) {
      GameConfig.enemySpeedMultiplier = 0.5;
    }
  }

  void _clearAllEffects() {
    for (final type in _activeTimers.keys.toList()) {
      eventBus.emit(PowerUpActiveEvent(type, false));
    }
    _activeTimers.clear();
    GameConfig.enemySpeedMultiplier = 1.0;
    // Remove floating pickups
    children.whereType<PowerUp>().toList().forEach((p) => p.removeFromParent());
  }
}
