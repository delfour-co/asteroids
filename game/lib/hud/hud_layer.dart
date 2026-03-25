import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show TextStyle, FontWeight, Shadow, TextPainter, TextSpan, TextDirection;

import '../app.dart';
import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../core/game_state.dart';
import '../enemies/ufo_events.dart';
import 'initial_entry_overlay.dart';
import 'panel_renderer.dart';
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
  _TronTextComponent? _gameOverText;
  TextComponent? _restartText;
  TextComponent? _highScoreGameOverText;
  TextComponent? _statsLeftText;
  TextComponent? _statsRightText;

  // Game over panel component
  _GameOverPanel? _gameOverPanel;
  _StatsVisualBars? _statsVisualBars;

  @override
  Future<void> onLoad() async {
    final gameSize = game.size;

    await add(_HudFrame(gameSize: gameSize));

    // Score text — top center, monospace bold with Tron glow
    _scoreText = TextComponent(
      text: '0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConfig.shipColor,
          fontSize: 40,
          fontFamily: 'JetBrainsMono',
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          shadows: [
            Shadow(color: Color(0x9900FFFF), blurRadius: 10),
            Shadow(color: Color(0x4400FFFF), blurRadius: 20),
          ],
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(gameSize.x / 2, 12),
    );
    await add(_scoreText);

    // High score — below score, dim cyan with subtle glow
    _highScoreText = TextComponent(
      text: 'HI ${game.gameState.highScore}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0x8800FFFF),
          fontSize: 14,
          fontFamily: 'JetBrainsMono',
          letterSpacing: 1.5,
          shadows: [
            Shadow(color: Color(0x3300FFFF), blurRadius: 6),
          ],
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(gameSize.x / 2, 54),
    );
    await add(_highScoreText);

    // Version — top right, dimmer
    await add(TextComponent(
      text: 'v1.8.0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0x6600FFFF),
          fontSize: 11,
          fontFamily: 'JetBrainsMono',
          letterSpacing: 1.0,
        ),
      ),
      anchor: Anchor.topRight,
      position: Vector2(gameSize.x - 16, 12),
    ));

    // Wave text — below high score, cyan with glow
    _waveText = TextComponent(
      text: 'WAVE 1',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xAA00FFFF),
          fontSize: 14,
          fontFamily: 'JetBrainsMono',
          letterSpacing: 1.5,
          shadows: [
            Shadow(color: Color(0x4400FFFF), blurRadius: 6),
          ],
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(gameSize.x / 2, 72),
    );
    await add(_waveText);

    // Combo text — below wave, hidden by default, yellow glow
    _comboText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConfig.comboColor,
          fontSize: 18,
          fontFamily: 'JetBrainsMono',
          letterSpacing: 1.5,
          shadows: [
            Shadow(color: Color(0x99CC00FF), blurRadius: 8),
            Shadow(color: Color(0x44CC00FF), blurRadius: 16),
          ],
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(gameSize.x / 2, 90),
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

    // Hide HUD elements behind game over screen
    _scoreText.text = '';
    _highScoreText.text = '';
    _waveText.text = '';
    _comboText.text = '';

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

    // Add panel behind game over content
    _gameOverPanel = _GameOverPanel(gameSize: gameSize);
    add(_gameOverPanel!);

    final cy = gameSize.y / 2;
    final cx = gameSize.x / 2;

    _gameOverText = _TronTextComponent(
      text: 'SIGNAL PERDU',
      fontSize: 48,
      position: Vector2(cx, cy - 120),
      gameWidth: gameSize.x,
    );
    add(_gameOverText!);

    _highScoreGameOverText = TextComponent(
      text: 'SCORE ${gs.score}  |  BEST ${gs.highScore}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xAA00FFFF),
          fontSize: 22,
          fontFamily: 'JetBrainsMono',
          letterSpacing: 1.5,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(cx, cy - 70),
    );
    add(_highScoreGameOverText!);

    // Session stats — two columns
    const statStyle = TextStyle(
      color: Color(0xAA00FFFF),
      fontSize: 13,
      fontFamily: 'JetBrainsMono',
    );
    final statPaint = TextPaint(style: statStyle);

    _statsLeftText = TextComponent(
      text: 'ASTEROIDS  ${stats.asteroidsDestroyed}\n'
          'UFOS       ${stats.ufosDestroyed}\n'
          'ACCURACY   ${stats.accuracy.toStringAsFixed(0)}%\n'
          'BEST COMBO x${stats.bestCombo}',
      textRenderer: statPaint,
      anchor: Anchor.topRight,
      position: Vector2(cx - 10, cy - 40),
    );
    add(_statsLeftText!);

    _statsRightText = TextComponent(
      text: 'WAVE       ${stats.waveReached}\n'
          'DURATION   ${stats.durationFormatted}\n'
          'PERFECT    ${stats.perfectKills}\n'
          'DASH KILLS ${stats.dashKills}',
      textRenderer: statPaint,
      anchor: Anchor.topLeft,
      position: Vector2(cx + 10, cy - 40),
    );
    add(_statsRightText!);

    _statsVisualBars = _StatsVisualBars(
      accuracy: stats.accuracy,
      bestCombo: stats.bestCombo,
      gameSize: gameSize,
    );
    add(_statsVisualBars!);

    _restartText = TextComponent(
      text: 'TAP TO RESTART',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConfig.shipColor,
          fontSize: 18,
          fontFamily: 'JetBrainsMono',
          letterSpacing: 1.5,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(cx, cy + 130),
    );
    add(_restartText!);
  }

  void _onRestart(RestartGameEvent event) {
    // Restore HUD
    _scoreText.text = '0';
    _highScoreText.text = 'HI ${game.gameState.highScore}';
    _waveText.text = 'WAVE 1';

    _gameOverPanel?.removeFromParent();
    _gameOverPanel = null;
    _gameOverText?.removeFromParent();
    _gameOverText = null;
    _highScoreGameOverText?.removeFromParent();
    _highScoreGameOverText = null;
    _statsLeftText?.removeFromParent();
    _statsLeftText = null;
    _statsRightText?.removeFromParent();
    _statsRightText = null;
    _statsVisualBars?.removeFromParent();
    _statsVisualBars = null;
    _restartText?.removeFromParent();
    _restartText = null;
  }
}

/// Panel drawn behind game over content with modern system window style.
class _GameOverPanel extends PositionComponent {
  final Vector2 gameSize;

  _GameOverPanel({required this.gameSize});

  @override
  Future<void> onLoad() async {
    size = gameSize;
    position = Vector2.zero();
  }

  @override
  void render(Canvas canvas) {
    final panelRect = Rect.fromCenter(
      center: Offset(gameSize.x / 2, gameSize.y / 2),
      width: gameSize.x * 0.85,
      height: gameSize.y * 0.85,
    );
    PanelRenderer.drawPanel(canvas, panelRect, title: 'SIGNAL LOST');
    PanelRenderer.drawScanlines(canvas, panelRect);
  }
}

/// Tron-style outlined text with multi-layer glow (like PAUSED title).
class _TronTextComponent extends PositionComponent {
  final String text;
  final double fontSize;
  final double gameWidth;

  _TronTextComponent({
    required this.text,
    required this.fontSize,
    required Vector2 position,
    required this.gameWidth,
  }) {
    this.position = position;
    anchor = Anchor.center;
    size = Vector2(gameWidth, fontSize * 2);
  }

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Layer 1: Wide glow
    _draw(canvas, cx, cy, Paint()
      ..color = const Color.fromARGB(50, 0, 255, 255)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16));
    // Layer 2: Medium glow
    _draw(canvas, cx, cy, Paint()
      ..color = const Color.fromARGB(100, 0, 255, 255)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    // Layer 3: Dark fill
    _draw(canvas, cx, cy, Paint()
      ..color = const Color(0xFF003844));
    // Layer 4: Bright outline
    _draw(canvas, cx, cy, Paint()
      ..color = const Color(0xDD00FFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0);
  }

  void _draw(Canvas canvas, double cx, double cy, Paint paint) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          foreground: paint,
          fontSize: fontSize,
          fontFamily: 'JetBrainsMono',
          fontWeight: FontWeight.bold,
          letterSpacing: 4.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }
}

/// Ship icon representing a life — mini triangle with neon glow.
class _LifeIcon extends PositionComponent {
  static final Paint _glowPaint = Paint()
    ..color = const Color(0x4400FFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

  static final Paint _solidPaint = Paint()
    ..color = GameConfig.shipColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  _LifeIcon() {
    size = Vector2(22, 28);
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    final path = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(0, size.y)
      ..lineTo(size.x, size.y)
      ..close();
    canvas.drawPath(path, _glowPaint);
    canvas.drawPath(path, _solidPaint);
  }
}

/// Sci-fi FUI frame decorations around the score area.
class _HudFrame extends PositionComponent {
  _HudFrame({required Vector2 gameSize}) {
    size = gameSize;
  }

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;

    // Top and bottom horizontal frame lines
    final linePaint = Paint()
      ..color = const Color.fromRGBO(0, 255, 255, 0.06)
      ..strokeWidth = 1.0;

    final left = cx - size.x * 0.22;
    final right = cx + size.x * 0.22;

    // Top line
    canvas.drawLine(Offset(left, 6), Offset(right, 6), linePaint);
    // Bottom line
    canvas.drawLine(Offset(left, 108), Offset(right, 108), linePaint);

    // Corner ticks (L-shapes)
    final tickPaint = Paint()
      ..color = const Color.fromRGBO(0, 255, 255, 0.12)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    const arm = 8.0;
    // Top-left corner
    canvas.drawLine(Offset(left, 6), Offset(left + arm, 6), tickPaint);
    canvas.drawLine(Offset(left, 6), Offset(left, 6 + arm), tickPaint);
    // Top-right corner
    canvas.drawLine(Offset(right, 6), Offset(right - arm, 6), tickPaint);
    canvas.drawLine(Offset(right, 6), Offset(right, 6 + arm), tickPaint);
    // Bottom-left corner
    canvas.drawLine(Offset(left, 108), Offset(left + arm, 108), tickPaint);
    canvas.drawLine(Offset(left, 108), Offset(left, 108 - arm), tickPaint);
    // Bottom-right corner
    canvas.drawLine(Offset(right, 108), Offset(right - arm, 108), tickPaint);
    canvas.drawLine(Offset(right, 108), Offset(right, 108 - arm), tickPaint);

    // Small tick dots along lines
    final dotPaint = Paint()..color = const Color.fromRGBO(0, 255, 255, 0.08);
    for (double x = left + 20; x < right; x += 30) {
      canvas.drawCircle(Offset(x, 6), 1.0, dotPaint);
      canvas.drawCircle(Offset(x, 108), 1.0, dotPaint);
    }
  }
}

/// Visual bars for game over stats (accuracy arc + combo bar).
class _StatsVisualBars extends PositionComponent {
  final double accuracy;
  final int bestCombo;
  final int maxCombo;
  final Vector2 gameSize;

  _StatsVisualBars({
    required this.accuracy,
    required this.bestCombo,
    // ignore: unused_element_parameter
    this.maxCombo = 8,
    required this.gameSize,
  });

  @override
  Future<void> onLoad() async {
    size = gameSize;
  }

  @override
  void render(Canvas canvas) {
    final cx = gameSize.x / 2;
    final baseY = gameSize.y / 2 + 55;

    // Accuracy arc
    final arcCenter = Offset(cx - 80, baseY);
    const arcRadius = 22.0;
    final arcPaint = Paint()
      ..color = const Color(0xFF00FFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    final arcBgPaint = Paint()
      ..color = const Color(0x2200FFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Background arc (full)
    canvas.drawArc(
      Rect.fromCircle(center: arcCenter, radius: arcRadius),
      -2.35, 4.71, false, arcBgPaint,
    );
    // Filled arc (accuracy proportion)
    canvas.drawArc(
      Rect.fromCircle(center: arcCenter, radius: arcRadius),
      -2.35, 4.71 * (accuracy / 100.0).clamp(0.0, 1.0), false, arcPaint,
    );
    // Accuracy % text in center
    _drawCenteredText(canvas, '${accuracy.toStringAsFixed(0)}%', arcCenter.dx, arcCenter.dy, 14, const Color(0xFF00FFFF));
    // Label below
    _drawCenteredText(canvas, 'ACCURACY', arcCenter.dx, arcCenter.dy + arcRadius + 14, 11, const Color(0x8800FFFF));

    // Combo segmented bar
    final barLeft = cx + 30;
    final barY = baseY;
    const segW = 14.0;
    const segH = 8.0;
    const segGap = 3.0;

    for (int i = 0; i < maxCombo; i++) {
      final x = barLeft + i * (segW + segGap);
      final filled = i < bestCombo;
      canvas.drawRect(
        Rect.fromLTWH(x, barY - segH / 2, segW, segH),
        Paint()..color = filled
          ? const Color(0xFFCC00FF)
          : const Color(0x22CC00FF),
      );
    }
    // Label below
    _drawCenteredText(canvas, 'BEST COMBO', barLeft + maxCombo * (segW + segGap) / 2, barY + segH / 2 + 14, 11, const Color(0x88CC00FF));
  }

  void _drawCenteredText(Canvas canvas, String text, double x, double y, double fontSize, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontFamily: 'JetBrainsMono',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }
}
