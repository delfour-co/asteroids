import '../asteroids/asteroid.dart';
import '../enemies/ufo_events.dart';
import 'arcade_events.dart';
import 'event_bus.dart';
import 'game_state.dart';

/// Tracks per-session gameplay statistics.
///
/// Reset on RestartGameEvent. Displayed on game over.
class SessionStats {
  int asteroidsDestroyed = 0;
  int shotsFired = 0;
  int shotsHit = 0;
  int ufosDestroyed = 0;
  int bestCombo = 1;
  int waveReached = 1;
  double duration = 0;
  int perfectKills = 0;
  int dashKills = 0;

  bool _running = false;

  late final void Function(AsteroidDestroyedEvent) _asteroidListener;
  late final void Function(UfoDestroyedEvent) _ufoListener;
  late final void Function(ComboChangedEvent) _comboListener;
  late final void Function(WaveStartedEvent) _waveListener;
  late final void Function(PerfectKillEvent) _perfectKillListener;
  late final void Function(GameOverEvent) _gameOverListener;
  late final void Function(RestartGameEvent) _restartListener;
  late final void Function(ShotFiredEvent) _shotFiredListener;

  void init() {
    _asteroidListener = _onAsteroidDestroyed;
    _ufoListener = _onUfoDestroyed;
    _comboListener = _onComboChanged;
    _waveListener = _onWaveStarted;
    _perfectKillListener = _onPerfectKill;
    _gameOverListener = (_) => _running = false;
    _restartListener = (_) => reset();
    _shotFiredListener = (_) => shotsFired++;

    eventBus.on<AsteroidDestroyedEvent>(_asteroidListener);
    eventBus.on<UfoDestroyedEvent>(_ufoListener);
    eventBus.on<ComboChangedEvent>(_comboListener);
    eventBus.on<WaveStartedEvent>(_waveListener);
    eventBus.on<PerfectKillEvent>(_perfectKillListener);
    eventBus.on<GameOverEvent>(_gameOverListener);
    eventBus.on<RestartGameEvent>(_restartListener);
    eventBus.on<ShotFiredEvent>(_shotFiredListener);

    _running = true;
  }

  void dispose() {
    eventBus.off<AsteroidDestroyedEvent>(_asteroidListener);
    eventBus.off<UfoDestroyedEvent>(_ufoListener);
    eventBus.off<ComboChangedEvent>(_comboListener);
    eventBus.off<WaveStartedEvent>(_waveListener);
    eventBus.off<PerfectKillEvent>(_perfectKillListener);
    eventBus.off<GameOverEvent>(_gameOverListener);
    eventBus.off<RestartGameEvent>(_restartListener);
    eventBus.off<ShotFiredEvent>(_shotFiredListener);
  }

  void update(double dt) {
    if (_running) duration += dt;
  }

  void reset() {
    asteroidsDestroyed = 0;
    shotsFired = 0;
    shotsHit = 0;
    ufosDestroyed = 0;
    bestCombo = 1;
    waveReached = 1;
    duration = 0;
    perfectKills = 0;
    dashKills = 0;
    _running = true;
  }

  double get accuracy =>
      shotsFired > 0 ? (shotsHit / shotsFired * 100) : 0;

  String get durationFormatted {
    final m = (duration ~/ 60).toString().padLeft(2, '0');
    final s = (duration.toInt() % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _onAsteroidDestroyed(AsteroidDestroyedEvent event) {
    asteroidsDestroyed++;
    shotsHit++;
    if (event.byDash) dashKills++;
  }

  void _onUfoDestroyed(UfoDestroyedEvent event) {
    ufosDestroyed++;
    shotsHit++;
  }

  void _onComboChanged(ComboChangedEvent event) {
    if (event.multiplier > bestCombo) bestCombo = event.multiplier;
  }

  void _onWaveStarted(WaveStartedEvent event) {
    if (event.wave > waveReached) waveReached = event.wave;
  }

  void _onPerfectKill(PerfectKillEvent event) {
    perfectKills++;
  }
}

/// Event emitted when a projectile is fired (for accuracy tracking).
class ShotFiredEvent {}
