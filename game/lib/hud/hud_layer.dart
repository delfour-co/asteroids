import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show TextStyle, FontWeight;

import '../app.dart';
import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../core/game_state.dart';
import '../enemies/ufo_events.dart';
import 'initial_entry_overlay.dart';
import 'wave_announcement.dart';

/// HUD displaying score and remaining lives with neon styling.
class HudLayer extends PositionComponent with HasGameReference<AsteroidsNeonGame> {
  late final TextComponent _scoreText;
  late final TextComponent _highScoreText;
  late final TextComponent _waveText;
  late final TextComponent _comboText;
  late final List<_LifeIcon> _lifeIcons;

  late final void Function(ScoreChangedEvent) _scoreListener;
  late final void Function(LivesChangedEvent) _livesListener;
  late final void Function(GameOverEvent) _gameOverListener;
  late final void Function(RestartGameEvent) _restartListener;
  late final void Function(HighScoreChangedEvent) _highScoreListener;
  late final void Function(WaveStartedEvent) _waveListener;
  late final void Function(ComboChangedEvent) _comboListener;

  // Game over overlay
  TextComponent? _gameOverText;
  TextComponent? _restartText;
  TextComponent? _highScoreGameOverText;
  TextComponent? _statsLeftText;
  TextComponent? _statsRightText;

  @override
  Future<void> onLoad() async {
    final gameSize = game.size;

    // Score text — top center
    _scoreText = TextComponent(
      text: '0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConfig.shipColor,
          fontSize: 40,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(gameSize.x / 2, 12),
    );
    await add(_scoreText);

    // High score — below score (read initial value from gameState)
    _highScoreText = TextComponent(
      text: 'HI ${game.gameState.highScore}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xAAFFFF00),
          fontSize: 20,
          fontFamily: 'monospace',
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(gameSize.x / 2, 56),
    );
    await add(_highScoreText);

    // Version — top right
    await add(TextComponent(
      text: 'v1.7.0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xAAFFFFFF),
          fontSize: 14,
          fontFamily: 'monospace',
        ),
      ),
      anchor: Anchor.topRight,
      position: Vector2(gameSize.x - 16, 12),
    ));

    // Wave text — below high score
    _waveText = TextComponent(
      text: 'WAVE 1',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xAA00FF66),
          fontSize: 18,
          fontFamily: 'monospace',
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(gameSize.x / 2, 80),
    );
    await add(_waveText);

    // Combo text — below wave, hidden by default
    _comboText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConfig.comboColor,
          fontSize: 22,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(gameSize.x / 2, 102),
    );
    await add(_comboText);

    // Life icons — top left
    _lifeIcons = [];
    _updateLives(GameConfig.startingLives);

    // Subscribe to events
    _scoreListener = _onScoreChanged;
    _livesListener = _onLivesChanged;
    _gameOverListener = _onGameOver;
    _restartListener = _onRestart;
    _highScoreListener = _onHighScoreChanged;
    _waveListener = _onWaveStarted;
    _comboListener = _onComboChanged;
    eventBus.on<ScoreChangedEvent>(_scoreListener);
    eventBus.on<LivesChangedEvent>(_livesListener);
    eventBus.on<GameOverEvent>(_gameOverListener);
    eventBus.on<RestartGameEvent>(_restartListener);
    eventBus.on<HighScoreChangedEvent>(_highScoreListener);
    eventBus.on<WaveStartedEvent>(_waveListener);
    eventBus.on<ComboChangedEvent>(_comboListener);
  }

  @override
  void onRemove() {
    eventBus.off<ScoreChangedEvent>(_scoreListener);
    eventBus.off<LivesChangedEvent>(_livesListener);
    eventBus.off<GameOverEvent>(_gameOverListener);
    eventBus.off<RestartGameEvent>(_restartListener);
    eventBus.off<HighScoreChangedEvent>(_highScoreListener);
    eventBus.off<WaveStartedEvent>(_waveListener);
    eventBus.off<ComboChangedEvent>(_comboListener);
    super.onRemove();
  }

  void _onScoreChanged(ScoreChangedEvent event) {
    _scoreText.text = event.score.toString();
  }

  void _onHighScoreChanged(HighScoreChangedEvent event) {
    _highScoreText.text = 'HI ${event.highScore}';
  }

  void _onLivesChanged(LivesChangedEvent event) {
    _updateLives(event.lives);
  }

  void _updateLives(int count) {
    // Remove existing icons
    for (final icon in _lifeIcons) {
      icon.removeFromParent();
    }
    _lifeIcons.clear();

    // Add new icons
    for (int i = 0; i < count; i++) {
      final icon = _LifeIcon()
        ..position = Vector2(24 + i * 36.0, 24);
      add(icon);
      _lifeIcons.add(icon);
    }
  }

  void _onWaveStarted(WaveStartedEvent event) {
    _waveText.text = 'WAVE ${event.wave}';
    // Spawn big wave announcement
    add(WaveAnnouncement(wave: event.wave));
    // Check cosmetic unlocks
    game.cosmeticsManager.checkWaveUnlocks(event.wave);
  }

  void _onComboChanged(ComboChangedEvent event) {
    if (event.multiplier > 1) {
      _comboText.text = 'x${event.multiplier} COMBO';
    } else {
      _comboText.text = '';
    }
  }

  void _onGameOver(GameOverEvent event) {
    final gameSize = game.size;
    final gs = game.gameState;
    final stats = game.sessionStats;

    // Check if score qualifies for leaderboard
    if (game.leaderboardManager.qualifies(gs.score)) {
      // Delay to let game over settle, then show initials entry
      Future.delayed(const Duration(milliseconds: 500), () {
        if (isMounted) {
          game.add(InitialEntryOverlay(
            score: gs.score,
            leaderboard: game.leaderboardManager,
          ));
        }
      });
    }

    _gameOverText = TextComponent(
      text: 'SIGNAL PERDU',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF00FF66),
          fontSize: 48,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(gameSize.x / 2, gameSize.y / 2 - 80),
    );
    add(_gameOverText!);

    _highScoreGameOverText = TextComponent(
      text: 'SCORE ${gs.score}  |  BEST ${gs.highScore}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xAAFFFF00),
          fontSize: 26,
          fontFamily: 'monospace',
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(gameSize.x / 2, gameSize.y / 2 - 40),
    );
    add(_highScoreGameOverText!);

    // Session stats — two columns
    const statStyle = TextStyle(
      color: Color(0xAA00FFFF),
      fontSize: 16,
      fontFamily: 'monospace',
    );
    final statPaint = TextPaint(style: statStyle);

    _statsLeftText = TextComponent(
      text: 'ASTEROIDS  ${stats.asteroidsDestroyed}\n'
          'UFOS       ${stats.ufosDestroyed}\n'
          'ACCURACY   ${stats.accuracy.toStringAsFixed(0)}%\n'
          'BEST COMBO x${stats.bestCombo}',
      textRenderer: statPaint,
      anchor: Anchor.topRight,
      position: Vector2(gameSize.x / 2 - 10, gameSize.y / 2 - 12),
    );
    add(_statsLeftText!);

    _statsRightText = TextComponent(
      text: 'WAVE       ${stats.waveReached}\n'
          'DURATION   ${stats.durationFormatted}\n'
          'PERFECT    ${stats.perfectKills}\n'
          'DASH KILLS ${stats.dashKills}',
      textRenderer: statPaint,
      anchor: Anchor.topLeft,
      position: Vector2(gameSize.x / 2 + 10, gameSize.y / 2 - 12),
    );
    add(_statsRightText!);

    _restartText = TextComponent(
      text: 'TAP TO RESTART',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConfig.shipColor,
          fontSize: 24,
          fontFamily: 'monospace',
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(gameSize.x / 2, gameSize.y / 2 + 110),
    );
    add(_restartText!);
  }

  void _onRestart(RestartGameEvent event) {
    _gameOverText?.removeFromParent();
    _gameOverText = null;
    _highScoreGameOverText?.removeFromParent();
    _highScoreGameOverText = null;
    _statsLeftText?.removeFromParent();
    _statsLeftText = null;
    _statsRightText?.removeFromParent();
    _statsRightText = null;
    _restartText?.removeFromParent();
    _restartText = null;
  }
}

/// Ship icon representing a life.
class _LifeIcon extends PositionComponent {
  static final Paint _paint = Paint()
    ..color = GameConfig.shipColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  _LifeIcon() {
    size = Vector2(22, 28);
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    // Draw a small triangle (mini ship)
    final path = Path()
      ..moveTo(size.x / 2, 0) // Nose
      ..lineTo(0, size.y) // Bottom left
      ..lineTo(size.x, size.y) // Bottom right
      ..close();
    canvas.drawPath(path, _paint);
  }
}
