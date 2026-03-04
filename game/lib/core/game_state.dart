import 'package:shared_preferences/shared_preferences.dart';

import 'arcade_events.dart';
import 'event_bus.dart';
import 'game_config.dart';
import '../asteroids/asteroid.dart';
import '../debris/debris_events.dart';
import '../enemies/ufo_events.dart';
import '../ship/ship.dart';

/// Event emitted when the score changes.
class ScoreChangedEvent {
  final int score;
  ScoreChangedEvent(this.score);
}

/// Event emitted when lives change.
class LivesChangedEvent {
  final int lives;
  LivesChangedEvent(this.lives);
}

/// Event emitted when the game is over.
class GameOverEvent {}

/// Event emitted when an extra life is awarded.
class ExtraLifeEvent {}

/// Event emitted to restart the game.
class RestartGameEvent {}

/// Event emitted when high score changes.
class HighScoreChangedEvent {
  final int highScore;
  HighScoreChangedEvent(this.highScore);
}

/// Manages score, lives, and game state.
///
/// Listens to AsteroidDestroyedEvent for scoring.
/// Listens to ShipDestroyedEvent for lives.
/// Emits ScoreChangedEvent, LivesChangedEvent, GameOverEvent.
class GameState {
  int _score = 0;
  int _lives = GameConfig.startingLives;
  int _nextExtraLife = GameConfig.extraLifeScore;
  int _highScore = 0;
  int _comboMultiplier = 1;

  static const String _highScoreKey = 'high_score';

  int get score => _score;
  int get lives => _lives;
  int get highScore => _highScore;

  bool _isGameOver = false;

  late final void Function(AsteroidDestroyedEvent) _asteroidListener;
  late final void Function(ShipDestroyedEvent) _shipListener;
  late final void Function(RestartGameEvent) _restartListener;
  late final void Function(UfoDestroyedEvent) _ufoListener;
  late final void Function(ComboChangedEvent) _comboListener;
  late final void Function(SpaceDebrisDestroyedEvent) _debrisListener;

  bool get isGameOver => _isGameOver;

  Future<void> init() async {
    // Load high score
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt(_highScoreKey) ?? 0;

    _asteroidListener = _onAsteroidDestroyed;
    _shipListener = _onShipDestroyed;
    _restartListener = _onRestart;
    _ufoListener = _onUfoDestroyed;
    _comboListener = (e) => _comboMultiplier = e.multiplier;
    _debrisListener = _onDebrisDestroyed;
    eventBus.on<AsteroidDestroyedEvent>(_asteroidListener);
    eventBus.on<ShipDestroyedEvent>(_shipListener);
    eventBus.on<RestartGameEvent>(_restartListener);
    eventBus.on<UfoDestroyedEvent>(_ufoListener);
    eventBus.on<ComboChangedEvent>(_comboListener);
    eventBus.on<SpaceDebrisDestroyedEvent>(_debrisListener);

    eventBus.emit(ScoreChangedEvent(_score));
    eventBus.emit(LivesChangedEvent(_lives));
    eventBus.emit(HighScoreChangedEvent(_highScore));
  }

  void dispose() {
    eventBus.off<AsteroidDestroyedEvent>(_asteroidListener);
    eventBus.off<ShipDestroyedEvent>(_shipListener);
    eventBus.off<RestartGameEvent>(_restartListener);
    eventBus.off<UfoDestroyedEvent>(_ufoListener);
    eventBus.off<ComboChangedEvent>(_comboListener);
    eventBus.off<SpaceDebrisDestroyedEvent>(_debrisListener);
  }

  void _onRestart(RestartGameEvent event) {
    _score = 0;
    _lives = GameConfig.startingLives;
    _nextExtraLife = GameConfig.extraLifeScore;
    _isGameOver = false;
    eventBus.emit(ScoreChangedEvent(_score));
    eventBus.emit(LivesChangedEvent(_lives));
  }

  void _onAsteroidDestroyed(AsteroidDestroyedEvent event) {
    final basePoints = event.asteroidSize.points;
    final totalPoints = basePoints * _comboMultiplier;
    _score += totalPoints;
    eventBus.emit(ScoreChangedEvent(_score));
    eventBus.emit(ScorePopupEvent(event.position, basePoints, _comboMultiplier));

    _checkExtraLife();
  }

  void _onUfoDestroyed(UfoDestroyedEvent event) {
    final totalPoints = event.points * _comboMultiplier;
    _score += totalPoints;
    eventBus.emit(ScoreChangedEvent(_score));
    eventBus.emit(ScorePopupEvent(event.position, event.points, _comboMultiplier));

    _checkExtraLife();
  }

  void _onDebrisDestroyed(SpaceDebrisDestroyedEvent event) {
    final totalPoints = event.points * _comboMultiplier;
    _score += totalPoints;
    eventBus.emit(ScoreChangedEvent(_score));
    eventBus.emit(ScorePopupEvent(event.position, event.points, _comboMultiplier));

    _checkExtraLife();
  }

  void _checkExtraLife() {
    if (_score >= _nextExtraLife) {
      _lives++;
      _nextExtraLife += GameConfig.extraLifeScore;
      eventBus.emit(LivesChangedEvent(_lives));
      eventBus.emit(ExtraLifeEvent());
    }
  }

  void _onShipDestroyed(ShipDestroyedEvent event) {
    _lives--;
    eventBus.emit(LivesChangedEvent(_lives));

    if (_lives <= 0) {
      _isGameOver = true;
      _saveHighScore();
      eventBus.emit(GameOverEvent());
    }
  }

  void resetForMenu() {
    _score = 0;
    _lives = GameConfig.startingLives;
    _nextExtraLife = GameConfig.extraLifeScore;
    _isGameOver = false;
    _comboMultiplier = 1;
  }

  void _saveHighScore() {
    if (_score > _highScore) {
      _highScore = _score;
      eventBus.emit(HighScoreChangedEvent(_highScore));
      SharedPreferences.getInstance().then((prefs) {
        prefs.setInt(_highScoreKey, _highScore);
      });
    }
  }
}
