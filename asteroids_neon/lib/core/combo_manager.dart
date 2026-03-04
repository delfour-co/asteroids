import 'package:flame/components.dart';

import 'arcade_events.dart';
import 'event_bus.dart';
import 'game_config.dart';
import '../asteroids/asteroid.dart';
import '../enemies/ufo_events.dart';

/// Tracks kill combos and emits multiplier changes.
///
/// Each kill within [GameConfig.comboTimeout] seconds increases the multiplier.
/// The multiplier resets when the timer expires.
class ComboManager extends Component {
  int _killCount = 0;
  int _multiplier = 1;
  double _timer = 0;

  int get multiplier => _multiplier;

  late final void Function(AsteroidDestroyedEvent) _asteroidListener;
  late final void Function(UfoDestroyedEvent) _ufoListener;

  @override
  Future<void> onLoad() async {
    _asteroidListener = (_) => _onKill();
    _ufoListener = (_) => _onKill();
    eventBus.on<AsteroidDestroyedEvent>(_asteroidListener);
    eventBus.on<UfoDestroyedEvent>(_ufoListener);
  }

  @override
  void onRemove() {
    eventBus.off<AsteroidDestroyedEvent>(_asteroidListener);
    eventBus.off<UfoDestroyedEvent>(_ufoListener);
    super.onRemove();
  }

  void _onKill() {
    _killCount++;
    _timer = GameConfig.comboTimeout;

    final newMultiplier = _killCount.clamp(1, GameConfig.comboMaxMultiplier);
    if (newMultiplier != _multiplier) {
      _multiplier = newMultiplier;
      eventBus.emit(ComboChangedEvent(_multiplier));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_timer > 0) {
      _timer -= dt;
      if (_timer <= 0) {
        _killCount = 0;
        _multiplier = 1;
        _timer = 0;
        eventBus.emit(ComboChangedEvent(_multiplier));
      }
    }
  }
}
