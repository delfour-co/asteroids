import 'dart:ui';

import 'package:flame/components.dart';

import '../asteroids/asteroid.dart';
import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../debris/debris_events.dart';
import '../enemies/ufo_events.dart';
import '../ship/ship.dart';
import 'ember_effect.dart';
import 'explosion.dart';
import 'impact_effect.dart';
import 'score_popup.dart';

/// Spawns visual effects in response to game events.
class EffectsManager extends Component {
  late final void Function(AsteroidDestroyedEvent) _asteroidListener;
  late final void Function(ShipDestroyedEvent) _shipListener;
  late final void Function(UfoDestroyedEvent) _ufoListener;
  late final void Function(BossDefeatedEvent) _bossListener;
  late final void Function(ScorePopupEvent) _scorePopupListener;
  late final void Function(SpaceDebrisDestroyedEvent) _debrisListener;
  late final void Function(PerfectKillEvent) _perfectKillListener;
  late final void Function(ProjectileHitEvent) _projectileHitListener;

  @override
  Future<void> onLoad() async {
    _asteroidListener = _onAsteroidDestroyed;
    _shipListener = _onShipDestroyed;
    _ufoListener = _onUfoDestroyed;
    _bossListener = _onBossDefeated;
    _scorePopupListener = _onScorePopup;
    _debrisListener = _onDebrisDestroyed;
    _perfectKillListener = _onPerfectKill;
    _projectileHitListener = _onProjectileHit;
    eventBus.on<AsteroidDestroyedEvent>(_asteroidListener);
    eventBus.on<ShipDestroyedEvent>(_shipListener);
    eventBus.on<UfoDestroyedEvent>(_ufoListener);
    eventBus.on<BossDefeatedEvent>(_bossListener);
    eventBus.on<ScorePopupEvent>(_scorePopupListener);
    eventBus.on<SpaceDebrisDestroyedEvent>(_debrisListener);
    eventBus.on<PerfectKillEvent>(_perfectKillListener);
    eventBus.on<ProjectileHitEvent>(_projectileHitListener);
  }

  @override
  void onRemove() {
    eventBus.off<AsteroidDestroyedEvent>(_asteroidListener);
    eventBus.off<ShipDestroyedEvent>(_shipListener);
    eventBus.off<UfoDestroyedEvent>(_ufoListener);
    eventBus.off<BossDefeatedEvent>(_bossListener);
    eventBus.off<ScorePopupEvent>(_scorePopupListener);
    eventBus.off<SpaceDebrisDestroyedEvent>(_debrisListener);
    eventBus.off<PerfectKillEvent>(_perfectKillListener);
    eventBus.off<ProjectileHitEvent>(_projectileHitListener);
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

    // Embers for medium and large asteroids
    final int emberCount;
    switch (event.asteroidSize) {
      case AsteroidSize.large:
        emberCount = GameConfig.emberCountLarge;
      case AsteroidSize.medium:
        emberCount = GameConfig.emberCountMedium;
      case AsteroidSize.small:
        emberCount = GameConfig.emberCountSmall;
    }
    if (emberCount > 0) {
      add(EmberEffect(
        color: const Color(0xFFFF00FF),
        particleCount: emberCount,
      )..position = event.position.clone());
    }

    eventBus.emit(ScreenShakeEvent(shakeIntensity));

    // Perfect kill check — close-range destruction
    _checkPerfectKill(event.position, event.asteroidSize.points);
  }

  void _checkPerfectKill(Vector2 destroyPos, int basePoints) {
    final ships = parent?.children.whereType<Ship>();
    if (ships == null || ships.isEmpty) return;
    final shipPos = ships.first.position;
    final dist = destroyPos.distanceTo(shipPos);
    if (dist <= GameConfig.perfectKillRange) {
      eventBus.emit(PerfectKillEvent(
        destroyPos,
        basePoints * GameConfig.perfectKillMultiplier,
      ));
    }
  }

  void _onUfoDestroyed(UfoDestroyedEvent event) {
    add(Explosion(
      color: const Color(0xFF00FF44),
      particleCount: 16,
      maxSpeed: 130.0,
    )..position = event.position);

    add(EmberEffect(
      color: const Color(0xFF00FF44),
      particleCount: GameConfig.emberCountUfo,
    )..position = event.position.clone());

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

    add(EmberEffect(
      color: const Color(0xFFFF0044),
      particleCount: GameConfig.emberCountBoss,
    )..position = event.position.clone());

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

    add(EmberEffect(
      color: GameConfig.shipColor,
      particleCount: GameConfig.emberCountShip,
    )..position = event.position.clone());

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

  void _onPerfectKill(PerfectKillEvent event) {
    // Golden "PERFECT" popup
    add(ScorePopup(
      points: event.points,
      multiplier: 1,
      label: 'PERFECT',
      color: const Color(0xFFFFCC00),
    )..position = event.position.clone());
  }

  void _onProjectileHit(ProjectileHitEvent event) {
    add(ImpactEffect(
      color: GameConfig.shipColor,
    )..position = event.position.clone());
  }
}
