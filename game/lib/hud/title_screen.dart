import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart' show TextStyle, FontWeight;

import '../app.dart';
import '../audio/audio_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';
import 'changelog_overlay.dart';
import 'cosmetics_overlay.dart';
import 'credits_overlay.dart';
import 'journal_overlay.dart';
import 'leaderboard_overlay.dart';

/// Event emitted when the player starts the game from the title screen.
class StartGameEvent {}

/// Neon title screen shown before gameplay.
class TitleScreen extends PositionComponent
    with HasGameReference<AsteroidsNeonGame>, DragCallbacks {
  late final TextComponent _title;
  late final TextComponent _subtitle;
  late final TextComponent _controls;
  late final TextComponent _leaderboardBtn;
  late final TextComponent _creditsBtn;
  late final TextComponent _changelogBtn;
  late final TextComponent _logBtn;
  late final TextComponent _shipBtn;
  double _pulseTime = 0;

  // Tap zones
  late Rect _leaderboardRect;
  late Rect _creditsRect;
  late Rect _changelogRect;
  late Rect _logRect;
  late Rect _shipRect;


  @override
  Future<void> onLoad() async {
    final gameSize = game.size;
    size = gameSize;

    _title = TextComponent(
      text: 'NEON',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConfig.shipColor,
          fontSize: 56,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(gameSize.x / 2, gameSize.y * 0.3),
    );
    await add(_title);

    await add(TextComponent(
      text: 'A S T E R O I D S',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFF00FF),
          fontSize: 32,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(gameSize.x / 2, gameSize.y * 0.3 + 50),
    ));

    _subtitle = TextComponent(
      text: 'INSERT COIN',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 22,
          fontFamily: 'monospace',
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(gameSize.x / 2, gameSize.y * 0.55),
    );
    await add(_subtitle);

    // LEADERBOARD button
    _leaderboardBtn = TextComponent(
      text: 'LEADERBOARD',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConfig.arcadeYellow,
          fontSize: 20,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(gameSize.x / 2, gameSize.y * 0.66),
    );
    await add(_leaderboardBtn);
    _leaderboardRect = Rect.fromCenter(
      center: Offset(gameSize.x / 2, gameSize.y * 0.66),
      width: 250,
      height: 50,
    );

    // HISTORY and SHIP buttons (centered row)
    final btnGap = 40.0;
    final btnY1 = gameSize.y * 0.74;

    _logBtn = TextComponent(
      text: 'HISTORY',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xAA00FF66),
          fontSize: 16,
          fontFamily: 'monospace',
        ),
      ),
      anchor: Anchor.centerRight,
      position: Vector2(gameSize.x / 2 - btnGap / 2, btnY1),
    );
    await add(_logBtn);
    _logRect = Rect.fromCenter(
      center: Offset(gameSize.x / 2 - btnGap / 2 - 40, btnY1),
      width: 140,
      height: 50,
    );

    _shipBtn = TextComponent(
      text: 'SHIP',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xAA00FF66),
          fontSize: 16,
          fontFamily: 'monospace',
        ),
      ),
      anchor: Anchor.centerLeft,
      position: Vector2(gameSize.x / 2 + btnGap / 2, btnY1),
    );
    await add(_shipBtn);
    _shipRect = Rect.fromCenter(
      center: Offset(gameSize.x / 2 + btnGap / 2 + 30, btnY1),
      width: 120,
      height: 50,
    );

    // CREDITS — bottom left
    _creditsBtn = TextComponent(
      text: 'CREDITS',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0x6600FFFF),
          fontSize: 14,
          fontFamily: 'monospace',
        ),
      ),
      anchor: Anchor.bottomLeft,
      position: Vector2(20, gameSize.y - 16),
    );
    await add(_creditsBtn);
    _creditsRect = Rect.fromLTWH(0, gameSize.y - 60, 160, 60);

    // CHANGELOG — bottom right
    _changelogBtn = TextComponent(
      text: 'CHANGELOG',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0x6600FFFF),
          fontSize: 14,
          fontFamily: 'monospace',
        ),
      ),
      anchor: Anchor.bottomRight,
      position: Vector2(gameSize.x - 20, gameSize.y - 16),
    );
    await add(_changelogBtn);
    _changelogRect = Rect.fromLTWH(gameSize.x - 180, gameSize.y - 60, 180, 60);

    _controls = TextComponent(
      text: 'JOYSTICK: Steer  |  THRUST: Accelerate  |  FIRE: Shoot  |  DASH: Phase through',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0x88FFFFFF),
          fontSize: 14,
          fontFamily: 'monospace',
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(gameSize.x / 2, gameSize.y * 0.88),
    );
    await add(_controls);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt;

    // Pulse "INSERT COIN" opacity
    final opacity = 0.5 + sin(_pulseTime * 3) * 0.5;
    _subtitle.textRenderer = TextPaint(
      style: TextStyle(
        color: Color.fromARGB((opacity * 255).toInt(), 255, 255, 255),
        fontSize: 22,
        fontFamily: 'monospace',
      ),
    );
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final pos = event.localPosition;
    final offset = Offset(pos.x, pos.y);

    if (_leaderboardRect.contains(offset)) {
      eventBus.emit(UiNavigationEvent());
      _showLeaderboard();
      return;
    }
    if (_creditsRect.contains(offset)) {
      eventBus.emit(UiNavigationEvent());
      _showCredits();
      return;
    }
    if (_changelogRect.contains(offset)) {
      eventBus.emit(UiNavigationEvent());
      _showChangelog();
      return;
    }
    if (_logRect.contains(offset)) {
      eventBus.emit(UiNavigationEvent());
      _showJournal();
      return;
    }
    if (_shipRect.contains(offset)) {
      eventBus.emit(UiNavigationEvent());
      _showCosmetics();
      return;
    }

    // Any other tap starts the game
    eventBus.emit(StartGameEvent());
    removeFromParent();
  }

  void _showLeaderboard() {
    game.add(LeaderboardOverlay(
      leaderboard: game.leaderboardManager,
      onDismiss: () {},
    ));
  }

  void _showCredits() {
    game.add(CreditsOverlay(
      onDismiss: () {},
    ));
  }

  void _showChangelog() {
    game.add(ChangelogOverlay(
      onDismiss: () {},
    ));
  }

  void _showJournal() {
    game.add(JournalOverlay(
      unlockedIds: game.fragmentManager.unlockedIds,
      onDismiss: () {},
    ));
  }

  void _showCosmetics() {
    game.add(CosmeticsOverlay(
      cosmetics: game.cosmeticsManager,
      onDismiss: () {},
    ));
  }
}
