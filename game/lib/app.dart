import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'asteroids/asteroid_manager.dart';
import 'background/background_layer.dart';
import 'core/combo_manager.dart';
import 'core/game_config.dart';
import 'debris/space_debris_manager.dart';
import 'effects/effects_manager.dart';
import 'audio/audio_manager.dart';
import 'effects/flash_effect.dart';
import 'effects/screen_shake_manager.dart';
import 'effects/wave_ring_effect.dart';
import 'enemies/ufo_manager.dart';
import 'core/event_bus.dart';
import 'core/game_state.dart';
import 'powerups/powerup_manager.dart';
import 'core/arcade_events.dart';
import 'core/leaderboard.dart';
import 'hud/countdown_overlay.dart';
import 'hud/credits_overlay.dart';
import 'hud/hud_layer.dart';
import 'hud/initial_entry_overlay.dart';
import 'hud/leaderboard_overlay.dart';
import 'hud/menu_button.dart';
import 'hud/pause_button.dart';
import 'hud/pause_overlay.dart';
import 'hud/title_screen.dart';
import 'hud/tutorial_overlay.dart';
import 'input/action_buttons.dart';
import 'input/dash_button.dart';
import 'input/fire_button.dart';
import 'input/joystick.dart';
import 'projectiles/projectile.dart';
import 'projectiles/projectile_manager.dart';
import 'ship/ship.dart';

/// Layer containing gameplay entities (ship, asteroids, projectiles...).
class GameLayer extends Component with HasGameReference<AsteroidsNeonGame> {
  bool _gameOver = false;
  bool _paused = false;

  late final void Function(ShipDestroyedEvent) _shipDestroyedListener;
  late final void Function(GameOverEvent) _gameOverListener;
  late final void Function(RestartGameEvent) _restartListener;
  late final void Function(PauseEvent) _pauseListener;
  late final void Function(ResumeEvent) _resumeListener;

  @override
  Future<void> onLoad() async {
    _shipDestroyedListener = _onShipDestroyed;
    _gameOverListener = _onGameOver;
    _restartListener = _onRestart;
    _pauseListener = (_) => _paused = true;
    _resumeListener = (_) => _paused = false;
    eventBus.on<ShipDestroyedEvent>(_shipDestroyedListener);
    eventBus.on<GameOverEvent>(_gameOverListener);
    eventBus.on<RestartGameEvent>(_restartListener);
    eventBus.on<PauseEvent>(_pauseListener);
    eventBus.on<ResumeEvent>(_resumeListener);

    await _spawnGameplay();
  }

  @override
  void onRemove() {
    eventBus.off<ShipDestroyedEvent>(_shipDestroyedListener);
    eventBus.off<GameOverEvent>(_gameOverListener);
    eventBus.off<RestartGameEvent>(_restartListener);
    eventBus.off<PauseEvent>(_pauseListener);
    eventBus.off<ResumeEvent>(_resumeListener);
    super.onRemove();
  }

  @override
  void update(double dt) {
    if (_paused) return;
    super.update(dt);
  }

  Future<void> _spawnGameplay() async {
    final gameSize = game.size;
    final ship = Ship()
      ..position = Vector2(gameSize.x / 2, gameSize.y / 2);
    await add(ship);
    await add(ProjectileManager());
    await add(AsteroidManager());
    await add(UfoManager());
    await add(PowerUpManager());
    await add(EffectsManager());
    await add(ComboManager());
    await add(SpaceDebrisManager());
  }

  void _onShipDestroyed(ShipDestroyedEvent event) {
    if (_gameOver) return;

    Future.delayed(const Duration(seconds: 2), () {
      if (isMounted && !_gameOver) {
        final gameSize = game.size;
        final newShip = Ship()
          ..position = Vector2(gameSize.x / 2, gameSize.y / 2);
        add(newShip);
      }
    });
  }

  void _onGameOver(GameOverEvent event) {
    _gameOver = true;
    children.whereType<Projectile>().toList().forEach((p) => p.removeFromParent());
    for (final mgr in children.whereType<UfoManager>()) {
      mgr.clearAll();
    }
    for (final mgr in children.whereType<SpaceDebrisManager>()) {
      mgr.clearAll();
    }
    eventBus.emit(FireEvent(false));
    eventBus.emit(ThrustEvent(false));
  }

  void _onRestart(RestartGameEvent event) {
    _gameOver = false;

    // Remove all gameplay entities
    children.whereType<Ship>().toList().forEach((s) => s.removeFromParent());
    children.whereType<Projectile>().toList().forEach((p) => p.removeFromParent());
    children.whereType<ProjectileManager>().toList().forEach((m) => m.removeFromParent());
    children.whereType<AsteroidManager>().toList().forEach((m) => m.removeFromParent());
    children.whereType<UfoManager>().toList().forEach((m) => m.removeFromParent());
    children.whereType<PowerUpManager>().toList().forEach((m) => m.removeFromParent());
    children.whereType<EffectsManager>().toList().forEach((m) => m.removeFromParent());
    children.whereType<ComboManager>().toList().forEach((m) => m.removeFromParent());
    children.whereType<SpaceDebrisManager>().toList().forEach((m) => m.removeFromParent());

    // Respawn everything
    _spawnGameplay();
  }
}

/// Invisible full-screen overlay that handles tap-to-restart.
///
/// Only active during game over. Uses DragCallbacks (same as buttons)
/// to avoid gesture arena conflicts with TapCallbacks.
class RestartOverlay extends PositionComponent
    with HasGameReference<AsteroidsNeonGame>, DragCallbacks {
  bool _active = false;

  late final void Function(GameOverEvent) _gameOverListener;
  late final void Function(RestartGameEvent) _restartListener;

  @override
  Future<void> onLoad() async {
    size = game.size;
    position = Vector2.zero();
    // Low priority so buttons are checked first
    priority = -1;

    _gameOverListener = (_) => _active = true;
    _restartListener = (_) => _active = false;
    eventBus.on<GameOverEvent>(_gameOverListener);
    eventBus.on<RestartGameEvent>(_restartListener);
  }

  @override
  void onRemove() {
    eventBus.off<GameOverEvent>(_gameOverListener);
    eventBus.off<RestartGameEvent>(_restartListener);
    super.onRemove();
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (_active) {
      eventBus.emit(RestartGameEvent());
    }
  }
}

/// Main game class — entry point for the Flame game.
///
/// Shows title screen first, then starts gameplay on tap.
class AsteroidsNeonGame extends FlameGame with HasCollisionDetection {
  late final GameState gameState;
  late final LeaderboardManager leaderboardManager;
  bool _isPaused = false;

  late void Function(StartGameEvent) _startListener;
  late final void Function(ReturnToMenuEvent) _menuListener;
  late final void Function(PauseEvent) _gamePauseListener;
  late final void Function(ResumeEvent) _gameResumeListener;

  // Refs to gameplay components for cleanup on return-to-menu
  RestartOverlay? _restartOverlay;
  GameLayer? _gameLayer;
  HudLayer? _hudLayer;
  ShipJoystick? _joystick;
  ThrustButton? _thrustButton;
  FireButton? _fireButton;
  DashButton? _dashButton;
  PauseButton? _pauseButton;
  PauseOverlay? _pauseOverlay;
  MenuButton? _menuButton;

  @override
  Future<void> onLoad() async {
    gameState = GameState();
    await gameState.init();

    leaderboardManager = LeaderboardManager();
    await leaderboardManager.init();

    await add(BackgroundLayer());
    await add(ScreenShakeManager());
    await add(FlashEffect());
    await add(AudioManager());
    await add(WaveRingEffect());

    _menuListener = (_) => _returnToMenu();
    _gamePauseListener = (_) => _isPaused = true;
    _gameResumeListener = (_) => _isPaused = false;
    eventBus.on<ReturnToMenuEvent>(_menuListener);
    eventBus.on<PauseEvent>(_gamePauseListener);
    eventBus.on<ResumeEvent>(_gameResumeListener);

    // Show title screen
    await add(TitleScreen());

    // Listen for game start
    _startListener = (_) => _startGame();
    eventBus.on<StartGameEvent>(_startListener);
  }

  Future<void> _startGame() async {
    eventBus.off<StartGameEvent>(_startListener);

    // Add gameplay components
    _restartOverlay = RestartOverlay();
    _gameLayer = GameLayer();
    _hudLayer = HudLayer();
    _joystick = ShipJoystick();
    _thrustButton = ThrustButton();
    _fireButton = FireButton();
    _dashButton = DashButton();
    _pauseButton = PauseButton();
    _pauseOverlay = PauseOverlay();
    _menuButton = MenuButton();

    add(_restartOverlay!);
    add(_gameLayer!);
    add(_hudLayer!);
    add(_joystick!);
    add(_thrustButton!);
    add(_fireButton!);
    add(_dashButton!);
    add(_pauseButton!);
    add(_pauseOverlay!);
    add(_menuButton!);

    // Show tutorial on first launch, then countdown
    final prefs = await SharedPreferences.getInstance();
    final tutorialSeen = prefs.getBool(GameConfig.tutorialSeenKey) ?? false;

    if (!tutorialSeen) {
      add(TutorialOverlay(
        onDismiss: () async {
          await prefs.setBool(GameConfig.tutorialSeenKey, true);
          if (isMounted) {
            add(CountdownOverlay());
          }
        },
      ));
    } else {
      add(CountdownOverlay());
    }
  }

  void _returnToMenu() {
    _isPaused = false;
    // Remove all gameplay components
    _restartOverlay?.removeFromParent();
    _gameLayer?.removeFromParent();
    _hudLayer?.removeFromParent();
    _joystick?.removeFromParent();
    _thrustButton?.removeFromParent();
    _fireButton?.removeFromParent();
    _dashButton?.removeFromParent();
    _pauseButton?.removeFromParent();
    _pauseOverlay?.removeFromParent();
    _menuButton?.removeFromParent();

    // Also remove any active overlays
    children.whereType<CountdownOverlay>().toList().forEach((c) => c.removeFromParent());
    children.whereType<InitialEntryOverlay>().toList().forEach((c) => c.removeFromParent());
    children.whereType<LeaderboardOverlay>().toList().forEach((c) => c.removeFromParent());
    children.whereType<CreditsOverlay>().toList().forEach((c) => c.removeFromParent());
    children.whereType<TutorialOverlay>().toList().forEach((c) => c.removeFromParent());

    _restartOverlay = null;
    _gameLayer = null;
    _hudLayer = null;
    _joystick = null;
    _thrustButton = null;
    _fireButton = null;
    _dashButton = null;
    _pauseButton = null;
    _pauseOverlay = null;
    _menuButton = null;

    // Reset game state
    gameState.resetForMenu();

    // Re-show title screen
    add(TitleScreen());

    // Re-register start listener
    _startListener = (_) => _startGame();
    eventBus.on<StartGameEvent>(_startListener);
  }

  @override
  void update(double dt) {
    if (_isPaused) return;
    super.update(dt);
  }

  @override
  void onRemove() {
    eventBus.off<ReturnToMenuEvent>(_menuListener);
    eventBus.off<PauseEvent>(_gamePauseListener);
    eventBus.off<ResumeEvent>(_gameResumeListener);
    gameState.dispose();
    super.onRemove();
  }
}
