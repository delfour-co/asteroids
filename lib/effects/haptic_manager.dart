import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_state.dart';
import '../ship/ship.dart';

/// Triggers haptic feedback in response to game events.
///
/// Root component — survives restarts.
class HapticManager extends Component {
  late final void Function(ProjectileHitEvent) _hitListener;
  late final void Function(ShipDestroyedEvent) _shipDestroyedListener;
  late final void Function(GameOverEvent) _gameOverListener;
  late final void Function(DeathSlowMoEvent) _deathListener;

  @override
  Future<void> onLoad() async {
    _hitListener = (_) => HapticFeedback.lightImpact();
    _shipDestroyedListener = (_) => HapticFeedback.heavyImpact();
    _gameOverListener = (_) => HapticFeedback.vibrate();
    _deathListener = (_) => HapticFeedback.mediumImpact();

    eventBus.on<ProjectileHitEvent>(_hitListener);
    eventBus.on<ShipDestroyedEvent>(_shipDestroyedListener);
    eventBus.on<GameOverEvent>(_gameOverListener);
    eventBus.on<DeathSlowMoEvent>(_deathListener);
  }

  @override
  void onRemove() {
    eventBus.off<ProjectileHitEvent>(_hitListener);
    eventBus.off<ShipDestroyedEvent>(_shipDestroyedListener);
    eventBus.off<GameOverEvent>(_gameOverListener);
    eventBus.off<DeathSlowMoEvent>(_deathListener);
    super.onRemove();
  }
}
