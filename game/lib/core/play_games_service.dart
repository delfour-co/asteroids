import 'package:games_services/games_services.dart';

import '../asteroids/asteroid.dart';
import 'arcade_events.dart';
import 'event_bus.dart';
import 'game_state.dart';
import '../enemies/ufo_events.dart';

/// Achievement IDs from Google Play Games Services.
abstract class AchievementIds {
  static const firstLight = 'CgkIodmGoaUTEAIQBA';
  static const gettingWarmer = 'CgkIodmGoaUTEAIQBg';
  static const doubleDigits = 'CgkIodmGoaUTEAIQAw';
  static const veteranPilot = 'CgkIodmGoaUTEAIQBw';
  static const neonLegend = 'CgkIodmGoaUTEAIQCg';
  static const firstMemory = 'CgkIodmGoaUTEAIQCw';
  static const fullStory = 'CgkIodmGoaUTEAIQCQ';
  static const phantomDash = 'CgkIodmGoaUTEAIQBQ';
  static const perfectShot = 'CgkIodmGoaUTEAIQDg';
  static const chainReaction = 'CgkIodmGoaUTEAIQDQ';
  static const ufoHunter = 'CgkIodmGoaUTEAIQDA';
  static const newColors = 'CgkIodmGoaUTEAIQCA';
}

/// Leaderboard IDs from Google Play Games Services.
abstract class LeaderboardIds {
  static const highScore = 'CgkIodmGoaUTEAIQDw';
  static const bestWave = 'CgkIodmGoaUTEAIQEA';
}

/// Manages Google Play Games Services: sign-in, achievements, leaderboards.
///
/// Plain Dart class (like CosmeticsManager). Initialized once in app.dart.
class PlayGamesService {
  bool _signedIn = false;
  int _bestWave = 0;

  late final void Function(WaveStartedEvent) _waveListener;
  late final void Function(AsteroidDestroyedEvent) _asteroidListener;
  late final void Function(UfoDestroyedEvent) _ufoListener;
  late final void Function(PerfectKillEvent) _perfectKillListener;
  late final void Function(FragmentUnlockedEvent) _fragmentListener;
  late final void Function(KnockbackEvent) _knockbackListener;
  late final void Function(GameOverEvent) _gameOverListener;

  /// Reference to GameState for score submission.
  final GameState _gameState;

  PlayGamesService(this._gameState);

  Future<void> init() async {
    try {
      await GamesServices.signIn();
      _signedIn = true;
    } catch (_) {
      _signedIn = false;
    }

    _waveListener = _onWaveStarted;
    _asteroidListener = _onAsteroidDestroyed;
    _ufoListener = _onUfoDestroyed;
    _perfectKillListener = _onPerfectKill;
    _fragmentListener = _onFragmentUnlocked;
    _knockbackListener = _onKnockback;
    _gameOverListener = _onGameOver;

    eventBus.on<WaveStartedEvent>(_waveListener);
    eventBus.on<AsteroidDestroyedEvent>(_asteroidListener);
    eventBus.on<UfoDestroyedEvent>(_ufoListener);
    eventBus.on<PerfectKillEvent>(_perfectKillListener);
    eventBus.on<FragmentUnlockedEvent>(_fragmentListener);
    eventBus.on<KnockbackEvent>(_knockbackListener);
    eventBus.on<GameOverEvent>(_gameOverListener);
  }

  void dispose() {
    eventBus.off<WaveStartedEvent>(_waveListener);
    eventBus.off<AsteroidDestroyedEvent>(_asteroidListener);
    eventBus.off<UfoDestroyedEvent>(_ufoListener);
    eventBus.off<PerfectKillEvent>(_perfectKillListener);
    eventBus.off<FragmentUnlockedEvent>(_fragmentListener);
    eventBus.off<KnockbackEvent>(_knockbackListener);
    eventBus.off<GameOverEvent>(_gameOverListener);
  }

  void _onWaveStarted(WaveStartedEvent event) {
    final wave = event.wave;
    if (wave > _bestWave) _bestWave = wave;

    // Wave milestone achievements
    if (wave >= 1) _unlock(AchievementIds.firstLight);
    if (wave >= 5) _unlock(AchievementIds.gettingWarmer);
    if (wave >= 10) _unlock(AchievementIds.doubleDigits);
    if (wave >= 20) _unlock(AchievementIds.veteranPilot);
    if (wave >= 50) _unlock(AchievementIds.neonLegend);
  }

  void _onAsteroidDestroyed(AsteroidDestroyedEvent event) {
    if (event.byDash) {
      _unlock(AchievementIds.phantomDash);
    }
  }

  void _onUfoDestroyed(UfoDestroyedEvent event) {
    _unlock(AchievementIds.ufoHunter);
  }

  void _onPerfectKill(PerfectKillEvent event) {
    _unlock(AchievementIds.perfectShot);
  }

  void _onFragmentUnlocked(FragmentUnlockedEvent event) {
    _unlock(AchievementIds.firstMemory);

    // Last fragment is index 9 (wave 100) — unlock "Full Story"
    if (event.fragmentIndex == 9) {
      _unlock(AchievementIds.fullStory);
    }
  }

  void _onKnockback(KnockbackEvent event) {
    // Knockback events come from explosive asteroid chain reactions
    _unlock(AchievementIds.chainReaction);
  }

  void _onGameOver(GameOverEvent event) {
    _submitScores();
  }

  void _unlock(String achievementId) {
    if (!_signedIn) return;
    try {
      GamesServices.unlock(achievement: Achievement(androidID: achievementId));
    } catch (_) {
      // Silently fail — not critical
    }
  }

  void _submitScores() {
    if (!_signedIn) return;
    try {
      final score = _gameState.score;
      if (score > 0) {
        GamesServices.submitScore(
          score: Score(
            androidLeaderboardID: LeaderboardIds.highScore,
            value: score,
          ),
        );
      }
      if (_bestWave > 0) {
        GamesServices.submitScore(
          score: Score(
            androidLeaderboardID: LeaderboardIds.bestWave,
            value: _bestWave,
          ),
        );
      }
    } catch (_) {
      // Silently fail
    }
    _bestWave = 0;
  }

  /// Notify that a new color was unlocked (from CosmeticsManager).
  void onColorUnlocked() {
    _unlock(AchievementIds.newColors);
  }
}
