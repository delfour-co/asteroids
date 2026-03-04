import 'dart:ui';

import 'package:flame/components.dart';

import '../asteroids/asteroid.dart';
import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../debris/debris_events.dart';
import '../enemies/ufo_events.dart';
import '../ship/ship.dart';
import 'explosion.dart';
import 'score_popup.dart';

/// Spawns visual effects in response to game events.
class EffectsManager extends Component {
  late final void Function(AsteroidDestroyedEvent) _asteroidListener;
  late final void Function(ShipDestroyedEvent) _shipListener;
  late final void Function(UfoDestroyedEvent) _ufoListener;
  late final void Function(BossDefeatedEvent) _bossListener;
  late final void Function(ScorePopupEvent) _scorePopupListener;
  late final void Function(SpaceDebrisDestroyedEvent) _debrisListener;

  @override
  Future<void> onLoad() async {
    _asteroidListener = _onAsteroidDestroyed;
    _shipListener = _onShipDestroyed;
    _ufoListener = _onUfoDestroyed;
    _bossListener = _onBossDefeated;
    _scorePopupListener = _onScorePopup;
    _debrisListener = _onDebrisDestroyed;
    eventBus.on<AsteroidDestroyedEvent>(_asteroidListener);
    eventBus.on<ShipDestroyedEvent>(_shipListener);
    eventBus.on<UfoDestroyedEvent>(_ufoListener);
    eventBus.on<BossDefeatedEvent>(_bossListener);
    eventBus.on<ScorePopupEvent>(_scorePopupListener);
    eventBus.on<SpaceDebrisDestroyedEvent>(_debrisListener);
  }

  @override
  void onRemove() {
    eventBus.off<AsteroidDestroyedEvent>(_asteroidListener);
    eventBus.off<ShipDestroyedEvent>(_shipListener);
    eventBus.off<UfoDestroyedEvent>(_ufoListener);
    eventBus.off<BossDefeatedEvent>(_bossListener);
    eventBus.off<ScorePopupEvent>(_scorePopupListener);
    eventBus.off<SpaceDebrisDestroyedEvent>(_debrisListener);
    super.onRemove();
  }

  void _onAsteroidDestroyed(AsteroidDestroyedEvent event) {
    // Particle count and speed based on asteroid size
    final int count;
    final double speed;
    final double shakeIntensity;
    switch (event.asteroidSize) {
      case AsteroidSize.large:
        count = 20;
        speed = 150.0;
        shakeIntensity = GameConfig.shakeIntensityLarge;
      case AsteroidSize.medium:
        count = 14;
        speed = 120.0;
        shakeIntensity = GameConfig.shakeIntensityMedium;
      case AsteroidSize.small:
        count = 8;
        speed = 80.0;
        shakeIntensity = GameConfig.shakeIntensitySmall;
    }

    add(Explosion(
      color: const Color(0xFFFF00FF), // Magenta like asteroids
      particleCount: count,
      maxSpeed: speed,
    )..position = event.position);

    eventBus.emit(ScreenShakeEvent(shakeIntensity));
  }

  void _onUfoDestroyed(UfoDestroyedEvent event) {
    add(Explosion(
      color: const Color(0xFF00FF44),
      particleCount: 16,
      maxSpeed: 130.0,
    )..position = event.position);

    eventBus.emit(ScreenShakeEvent(GameConfig.shakeIntensityMedium));
  }

  void _onBossDefeated(BossDefeatedEvent event) {
    // Massive red explosion for boss
    add(Explosion(
      color: const Color(0xFFFF0044),
      particleCount: 40,
      maxSpeed: 250.0,
      duration: 1.2,
    )..position = event.position);
    // Secondary orange ring
    add(Explosion(
      color: const Color(0xFFFF8800),
      particleCount: 20,
      maxSpeed: 180.0,
      duration: 0.8,
    )..position = event.position);

    eventBus.emit(ScreenShakeEvent(GameConfig.shakeIntensityBoss));
    eventBus.emit(BossFlashEvent());
  }

  void _onShipDestroyed(ShipDestroyedEvent event) {
    // Bigger cyan explosion for ship
    add(Explosion(
      color: GameConfig.shipColor,
      particleCount: 24,
      maxSpeed: 180.0,
      duration: 0.8,
    )..position = event.position);

    eventBus.emit(ScreenShakeEvent(GameConfig.shakeIntensityLarge));
  }

  void _onDebrisDestroyed(SpaceDebrisDestroyedEvent event) {
    final Color color;
    switch (event.debrisType) {
      case 'starlink':
        color = GameConfig.starlinkColor;
      case 'station':
        color = GameConfig.stationColor;
      case 'tesla':
        color = GameConfig.teslaColor;
      default:
        color = const Color(0xFFFFFFFF);
    }

    add(Explosion(
      color: color,
      particleCount: 12,
      maxSpeed: 100.0,
    )..position = event.position);

    eventBus.emit(ScreenShakeEvent(GameConfig.shakeIntensitySmall));
  }

  void _onScorePopup(ScorePopupEvent event) {
    add(ScorePopup(
      points: event.points,
      multiplier: event.multiplier,
    )..position = event.position.clone());
  }
}
