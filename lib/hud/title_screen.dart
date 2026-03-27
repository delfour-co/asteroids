import 'dart:math';
import 'dart:ui';

import 'package:d4_dark_ds/d4_dark_ds.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart'
    show TextStyle, FontWeight, TextPainter, TextDirection, TextSpan;

import '../app.dart';
import '../audio/audio_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';
import 'changelog_overlay.dart';
import 'panel_renderer.dart';
import 'cosmetics_overlay.dart';
import 'credits_overlay.dart';
import 'journal_overlay.dart';
import 'leaderboard_overlay.dart';

/// Event emitted when the player starts the game from the title screen.
class StartGameEvent {}

/// A single menu button with GitHero-style neon glow border.
class _MenuButton {
  _MenuButton({
    required this.label,
    required this.rect,
    this.textColor = const Color(0xFF00FFFF),
    this.fontSize = 16.0,
    this.outline = false,
  });

  final String label;
  final Rect rect;
  final Color textColor;
  final double fontSize;
  final bool outline;

  bool contains(Offset pos) => rect.contains(pos);

  void render(Canvas canvas) {
    if (outline) {
      PanelRenderer.drawOutlineButton(
        canvas,
        rect,
        label,
        textColor,
        fontSize: fontSize,
        letterSpacing: 1.5,
      );
    } else {
      PanelRenderer.drawGlowButton(
        canvas,
        rect,
        label,
        textColor,
        fontSize: fontSize,
        letterSpacing: 1.5,
      );
    }
  }
}

/// Neon title screen shown before gameplay.
class TitleScreen extends PositionComponent
    with HasGameReference<AsteroidsNeonGame>, DragCallbacks {
  double _pulseTime = 0;

  // Buttons
  late _MenuButton _leaderboardBtn;
  late _MenuButton _historyBtn;
  late _MenuButton _shipBtn;
  late _MenuButton _creditsBtn;
  late _MenuButton _changelogBtn;

  // Cached painters
  late TextPainter _neonPainter;
  late TextPainter _asteroidsPainter;
  late TextPainter _subtitlePainter;
  late TextPainter _controlsPainter;
  late Offset _neonOffset;
  late Offset _asteroidsOffset;
  late Offset _subtitleOffset;
  late Offset _controlsOffset;
  late double _insertCoinY;
  late double _gameWidth;

  @override
  Future<void> onLoad() async {
    final gameSize = game.size;
    size = gameSize;
    _gameWidth = gameSize.x;

    // ── Title: "NEON" (big) + "ASTEROIDS" (smaller), two lines ──
    _neonPainter = TextPainter(
      text: const TextSpan(
        text: 'NEON',
        style: TextStyle(
          color: Color(0xFF003844),
          fontSize: 72,
          fontFamily: 'Tron',
          letterSpacing: 12.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    _asteroidsPainter = TextPainter(
      text: const TextSpan(
        text: 'ASTEROIDS',
        style: TextStyle(
          color: Color(0xFF003844),
          fontSize: 36,
          fontFamily: 'Tron',
          letterSpacing: 6.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final titleCenterY = gameSize.y * 0.22;
    const gap = 4.0;
    final totalH = _neonPainter.height + gap + _asteroidsPainter.height;
    _neonOffset = Offset(
      gameSize.x / 2 - _neonPainter.width / 2,
      titleCenterY - totalH / 2,
    );
    _asteroidsOffset = Offset(
      gameSize.x / 2 - _asteroidsPainter.width / 2,
      _neonOffset.dy + _neonPainter.height + gap,
    );

    // ── "by D4 Games" subtitle ──
    _subtitlePainter = TextPainter(
      text: const TextSpan(
        text: 'by D4 Games',
        style: TextStyle(
          color: Color(0x6600FFFF),
          fontSize: 14,
          fontFamily: D4DsTypography.monoFont,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    _subtitleOffset = Offset(
      gameSize.x / 2 - _subtitlePainter.width / 2,
      _asteroidsOffset.dy + _asteroidsPainter.height + 10,
    );

    // ── INSERT COIN position — centered vertically ──
    _insertCoinY = gameSize.y * 0.55;

    // ── Menu Buttons ──
    final cx = gameSize.x / 2;

    // HISTORY — top left corner
    const cornerW = 140.0;
    const cornerH = 34.0;
    const topY = 24.0;
    _historyBtn = _MenuButton(
      label: 'HISTORY',
      rect: Rect.fromLTWH(16, topY, cornerW, cornerH),
      textColor: const Color(0xFF00FF66),
      fontSize: 13,
    );

    // SHIP — top right corner
    _shipBtn = _MenuButton(
      label: 'SHIP',
      rect: Rect.fromLTWH(gameSize.x - cornerW - 16, topY, cornerW, cornerH),
      textColor: const Color(0xFF00FF66),
      fontSize: 13,
    );

    // Bottom row: CREDITS — left, LEADERBOARD — center, CHANGELOG — right
    final bottomY = gameSize.y - 40;

    const smallW = 110.0;
    const smallH = 28.0;
    _creditsBtn = _MenuButton(
      label: 'CREDITS',
      rect: Rect.fromLTWH(16, bottomY - smallH / 2, smallW, smallH),
      textColor: const Color(0x7700FFFF),
      fontSize: 11,
      outline: true,
    );

    const lbW = 200.0;
    _leaderboardBtn = _MenuButton(
      label: 'LEADERBOARD',
      rect: Rect.fromCenter(
        center: Offset(cx, bottomY),
        width: lbW,
        height: cornerH,
      ),
      textColor: GameConfig.arcadeYellow,
      fontSize: 13,
    );

    _changelogBtn = _MenuButton(
      label: 'CHANGELOG',
      rect: Rect.fromLTWH(
        gameSize.x - smallW - 16,
        bottomY - smallH / 2,
        smallW,
        smallH,
      ),
      textColor: const Color(0x7700FFFF),
      fontSize: 11,
      outline: true,
    );

    // ── Controls legend ──
    _controlsPainter = TextPainter(
      text: const TextSpan(
        text:
            'JOYSTICK: Steer  |  THRUST: Accelerate  |  FIRE: Shoot  |  DASH: Phase through',
        style: TextStyle(
          color: Color(0x88FFFFFF),
          fontSize: 11,
          fontFamily: D4DsTypography.monoFont,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    _controlsOffset = Offset(
      gameSize.x / 2 - _controlsPainter.width / 2,
      gameSize.y * 0.82,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // ── Title: "NEON" (big) + "ASTEROIDS" (smaller) — Tron glow style ──
    for (final entry in [
      (_neonOffset, 'NEON', 72.0, 12.0),
      (_asteroidsOffset, 'ASTEROIDS', 36.0, 6.0),
    ]) {
      final (offset, text, fontSize, letterSpacing) = entry;
      // Layer 1: Wide glow halo
      _drawTitleLine(canvas, text, fontSize, letterSpacing, offset,
        Paint()
          ..color = const Color(0x3000FFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));
      // Layer 2: Medium glow
      _drawTitleLine(canvas, text, fontSize, letterSpacing, offset,
        Paint()
          ..color = const Color(0x6000FFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    }
    // Layer 3: Solid filled text
    _neonPainter.paint(canvas, _neonOffset);
    _asteroidsPainter.paint(canvas, _asteroidsOffset);
    // Layer 4: Bright outline on top
    for (final entry in [
      (_neonOffset, 'NEON', 72.0, 12.0),
      (_asteroidsOffset, 'ASTEROIDS', 36.0, 6.0),
    ]) {
      final (offset, text, fontSize, letterSpacing) = entry;
      _drawTitleLine(canvas, text, fontSize, letterSpacing, offset,
        Paint()
          ..color = const Color(0xDD00FFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
    }

    // ── "D4 Games" ──
    _subtitlePainter.paint(canvas, _subtitleOffset);

    // ── INSERT COIN (pulsing, Tron outline style, Tron font) ──
    final opacity = 0.5 + sin(_pulseTime * 3) * 0.5;
    const icText = 'INSERT COIN';
    const icFontSize = 38.0;
    const icFont = D4DsTypography.monoFont;
    const icLetterSpacing = 3.0;

    // Layer 1: Wide violet glow halo
    _drawCenteredTextWithPaint(
      canvas,
      icText,
      icFontSize,
      icFont,
      icLetterSpacing,
      _insertCoinY,
      Paint()
        ..color = Color.fromARGB((opacity * 40).toInt(), 200, 0, 255)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
    // Layer 2: Medium violet glow
    _drawCenteredTextWithPaint(
      canvas,
      icText,
      icFontSize,
      icFont,
      icLetterSpacing,
      _insertCoinY,
      Paint()
        ..color = Color.fromARGB((opacity * 90).toInt(), 200, 0, 255)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Layer 3: Dark fill
    _drawCenteredTextWithPaint(
      canvas,
      icText,
      icFontSize,
      icFont,
      icLetterSpacing,
      _insertCoinY,
      Paint()..color = Color.fromARGB((opacity * 70).toInt(), 40, 0, 50),
    );
    // Layer 4: Bright violet outline
    _drawCenteredTextWithPaint(
      canvas,
      icText,
      icFontSize,
      icFont,
      icLetterSpacing,
      _insertCoinY,
      Paint()
        ..color = Color.fromARGB((opacity * 220).toInt(), 200, 0, 255)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // ── Menu Buttons ──
    _leaderboardBtn.render(canvas);
    _historyBtn.render(canvas);
    _shipBtn.render(canvas);
    _creditsBtn.render(canvas);
    _changelogBtn.render(canvas);

    // ── Controls ──
    _controlsPainter.paint(canvas, _controlsOffset);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final pos = event.localPosition;
    final offset = Offset(pos.x, pos.y);

    if (_leaderboardBtn.contains(offset)) {
      eventBus.emit(UiNavigationEvent());
      _showLeaderboard();
      return;
    }
    if (_creditsBtn.contains(offset)) {
      eventBus.emit(UiNavigationEvent());
      _showCredits();
      return;
    }
    if (_changelogBtn.contains(offset)) {
      eventBus.emit(UiNavigationEvent());
      _showChangelog();
      return;
    }
    if (_historyBtn.contains(offset)) {
      eventBus.emit(UiNavigationEvent());
      _showJournal();
      return;
    }
    if (_shipBtn.contains(offset)) {
      eventBus.emit(UiNavigationEvent());
      _showCosmetics();
      return;
    }

    // Any other tap starts the game
    eventBus.emit(StartGameEvent());
    removeFromParent();
  }

  /// Draw text centered at a given Y position with a custom foreground paint.
  void _drawCenteredTextWithPaint(
    Canvas canvas,
    String text,
    double fontSize,
    String fontFamily,
    double letterSpacing,
    double centerY,
    Paint paint,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          foreground: paint,
          fontSize: fontSize,
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
          letterSpacing: letterSpacing,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(_gameWidth / 2 - tp.width / 2, centerY - tp.height / 2),
    );
  }

  /// Draw a title line with a custom foreground paint (for stroke/glow layers).
  void _drawTitleLine(
    Canvas canvas,
    String text,
    double fontSize,
    double letterSpacing,
    Offset offset,
    Paint paint,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          foreground: paint,
          fontSize: fontSize,
          fontFamily: 'Tron',
          letterSpacing: letterSpacing,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  void _showLeaderboard() {
    game.add(
      LeaderboardOverlay(
        leaderboard: game.leaderboardManager,
        onDismiss: () {},
      ),
    );
  }

  void _showCredits() {
    game.add(CreditsOverlay(onDismiss: () {}));
  }

  void _showChangelog() {
    game.add(ChangelogOverlay(onDismiss: () {}));
  }

  void _showJournal() {
    game.add(
      JournalOverlay(
        unlockedIds: game.fragmentManager.unlockedIds,
        onDismiss: () {},
      ),
    );
  }

  void _showCosmetics() {
    game.add(
      CosmeticsOverlay(cosmetics: game.cosmeticsManager, onDismiss: () {}),
    );
  }
}
