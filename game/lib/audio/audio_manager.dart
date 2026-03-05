import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../asteroids/asteroid.dart';
import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_state.dart';
import '../hud/title_screen.dart';
import '../debris/debris_events.dart';
import '../enemies/ufo_events.dart';
import '../input/dash_button.dart';
import '../input/fire_button.dart';
import '../powerups/powerup.dart';
import '../ship/ship.dart';
import 'audio_config.dart';
import 'audio_events.dart';

/// Root-level audio component — persists across restarts and menu returns.
///
/// All audio calls are fire-and-forget to avoid blocking the game loop.
/// Uses per-SFX cooldowns to prevent player exhaustion on Android.
class AudioManager extends Component {
  bool _isMuted = false;
  bool _bgmPlaying = false;
  bool _inGame = false;
  bool _audioAvailable = true;
  int _currentWave = 0;

  // Per-SFX cooldown timers
  final Map<String, double> _sfxCooldowns = {};
  double _fireCooldownTimer = 0;

  // Event listeners
  late final void Function(FireEvent) _fireListener;
  late final void Function(DashEvent) _dashListener;
  late final void Function(AsteroidDestroyedEvent) _asteroidListener;
  late final void Function(UfoDestroyedEvent) _ufoListener;
  late final void Function(BossDefeatedEvent) _bossListener;
  late final void Function(ShipDestroyedEvent) _shipDestroyedListener;
  late final void Function(PowerUpCollectedEvent) _powerupListener;
  late final void Function(ExtraLifeEvent) _extraLifeListener;
  late final void Function(GameOverEvent) _gameOverListener;
  late final void Function(WaveStartedEvent) _waveListener;
  late final void Function(ComboChangedEvent) _comboListener;
  late final void Function(UiNavigationEvent) _uiNavListener;
  late final void Function(MuteToggleEvent) _muteToggleListener;
  late final void Function(PauseEvent) _pauseListener;
  late final void Function(ResumeEvent) _resumeListener;
  late final void Function(RestartGameEvent) _restartListener;
  late final void Function(ReturnToMenuEvent) _menuListener;
  late final void Function(StartGameEvent) _startGameListener;
  late final void Function(SpaceDebrisDestroyedEvent) _debrisListener;

  bool get isMuted => _isMuted;

  @override
  Future<void> onLoad() async {
    // Load mute preference
    final prefs = await SharedPreferences.getInstance();
    _isMuted = prefs.getBool(AudioConfig.muteKey) ?? false;

    // Set up all listeners
    _fireListener = _onFire;
    _dashListener = (_) => _playSfx(AudioConfig.sfxDash, AudioConfig.volDash);
    _asteroidListener = _onAsteroidDestroyed;
    _ufoListener = (_) => _playSfx(AudioConfig.sfxUfoDestroy, AudioConfig.volUfoDestroy);
    _bossListener = (_) => _playSfx(AudioConfig.sfxBossDefeat, AudioConfig.volBossDefeat);
    _shipDestroyedListener = (_) => _playSfx(AudioConfig.sfxShipDestroyed, AudioConfig.volShipDestroyed);
    _powerupListener = (_) => _playSfx(AudioConfig.sfxPowerup, AudioConfig.volPowerup);
    _extraLifeListener = (_) => _playSfx(AudioConfig.sfxExtraLife, AudioConfig.volExtraLife);
    _gameOverListener = (_) => _onGameOver();
    _waveListener = _onWaveStarted;
    _comboListener = (_) => _playSfx(AudioConfig.sfxCombo, AudioConfig.volCombo);
    _uiNavListener = (_) => _playSfx(AudioConfig.sfxUiSelect, AudioConfig.volUiSelect);
    _muteToggleListener = (_) => _toggleMute();
    _pauseListener = (_) => _onPause();
    _resumeListener = (_) => _onResume();
    _restartListener = (_) => _onRestart();
    _menuListener = (_) => _onReturnToMenu();
    _startGameListener = (_) => _onStartGame();
    _debrisListener = (_) => _playSfx(AudioConfig.sfxExplosionSmall, AudioConfig.volExplosion);

    // Subscribe
    eventBus.on<FireEvent>(_fireListener);
    eventBus.on<DashEvent>(_dashListener);
    eventBus.on<AsteroidDestroyedEvent>(_asteroidListener);
    eventBus.on<UfoDestroyedEvent>(_ufoListener);
    eventBus.on<BossDefeatedEvent>(_bossListener);
    eventBus.on<ShipDestroyedEvent>(_shipDestroyedListener);
    eventBus.on<PowerUpCollectedEvent>(_powerupListener);
    eventBus.on<ExtraLifeEvent>(_extraLifeListener);
    eventBus.on<GameOverEvent>(_gameOverListener);
    eventBus.on<WaveStartedEvent>(_waveListener);
    eventBus.on<ComboChangedEvent>(_comboListener);
    eventBus.on<UiNavigationEvent>(_uiNavListener);
    eventBus.on<MuteToggleEvent>(_muteToggleListener);
    eventBus.on<PauseEvent>(_pauseListener);
    eventBus.on<ResumeEvent>(_resumeListener);
    eventBus.on<RestartGameEvent>(_restartListener);
    eventBus.on<ReturnToMenuEvent>(_menuListener);
    eventBus.on<StartGameEvent>(_startGameListener);
    eventBus.on<SpaceDebrisDestroyedEvent>(_debrisListener);

    // Start BGM — fire-and-forget, never blocks onLoad
    _startBgm(AudioConfig.musicVolumeMenu);
  }

  @override
  void onRemove() {
    eventBus.off<FireEvent>(_fireListener);
    eventBus.off<DashEvent>(_dashListener);
    eventBus.off<AsteroidDestroyedEvent>(_asteroidListener);
    eventBus.off<UfoDestroyedEvent>(_ufoListener);
    eventBus.off<BossDefeatedEvent>(_bossListener);
    eventBus.off<ShipDestroyedEvent>(_shipDestroyedListener);
    eventBus.off<PowerUpCollectedEvent>(_powerupListener);
    eventBus.off<ExtraLifeEvent>(_extraLifeListener);
    eventBus.off<GameOverEvent>(_gameOverListener);
    eventBus.off<WaveStartedEvent>(_waveListener);
    eventBus.off<ComboChangedEvent>(_comboListener);
    eventBus.off<UiNavigationEvent>(_uiNavListener);
    eventBus.off<MuteToggleEvent>(_muteToggleListener);
    eventBus.off<PauseEvent>(_pauseListener);
    eventBus.off<ResumeEvent>(_resumeListener);
    eventBus.off<RestartGameEvent>(_restartListener);
    eventBus.off<ReturnToMenuEvent>(_menuListener);
    eventBus.off<StartGameEvent>(_startGameListener);
    eventBus.off<SpaceDebrisDestroyedEvent>(_debrisListener);

    if (_bgmPlaying) {
      _stopBgm();
    }
    super.onRemove();
  }

  @override
  void update(double dt) {
    if (_fireCooldownTimer > 0) {
      _fireCooldownTimer -= dt;
    }
    // Tick down per-SFX cooldowns
    final expired = <String>[];
    _sfxCooldowns.forEach((key, value) {
      _sfxCooldowns[key] = value - dt;
      if (_sfxCooldowns[key]! <= 0) expired.add(key);
    });
    for (final key in expired) {
      _sfxCooldowns.remove(key);
    }
  }

  // --- SFX ---

  void _playSfx(String file, double volume, {double cooldown = 0.1}) {
    if (_isMuted || !_audioAvailable) return;
    // Per-file cooldown: skip if same sound played recently
    if (_sfxCooldowns.containsKey(file)) return;
    _sfxCooldowns[file] = cooldown;
    try {
      FlameAudio.play(file, volume: volume).then((player) {
        // Dispose player after playback to free Android audio stream
        // Use listen instead of .first to avoid "Bad state: No element"
        // if the player is disposed before the stream emits.
        var disposed = false;
        player.onPlayerComplete.listen((_) {
          if (!disposed) {
            disposed = true;
            player.dispose();
          }
        });
        // Safety: dispose after 3s even if onPlayerComplete doesn't fire
        Future.delayed(const Duration(seconds: 3), () {
          if (!disposed) {
            disposed = true;
            player.dispose();
          }
        });
      }).catchError((e) {
        debugPrint('[Audio] SFX play error ($file): $e');
      });
    } catch (e) {
      debugPrint('[Audio] SFX error ($file): $e');
    }
  }

  void _onFire(FireEvent event) {
    if (!event.isFiring) return;
    if (_fireCooldownTimer > 0) return;
    _fireCooldownTimer = AudioConfig.fireCooldown;
    _playSfx(AudioConfig.sfxFire, AudioConfig.volFire, cooldown: AudioConfig.fireCooldown);
  }

  void _onAsteroidDestroyed(AsteroidDestroyedEvent event) {
    switch (event.asteroidSize) {
      case AsteroidSize.small:
        _playSfx(AudioConfig.sfxExplosionSmall, AudioConfig.volExplosion);
      case AsteroidSize.medium:
        _playSfx(AudioConfig.sfxExplosionMedium, AudioConfig.volExplosion);
      case AsteroidSize.large:
        _playSfx(AudioConfig.sfxExplosionLarge, AudioConfig.volExplosion);
    }
  }

  // --- BGM ---
  // All BGM operations are fire-and-forget to never block the game loop.

  void _startBgm(double volume) {
    if (_isMuted || !_audioAvailable) return;
    FlameAudio.bgm.play(AudioConfig.musicAmbient, volume: volume).then((_) {
      _bgmPlaying = true;
      debugPrint('[Audio] BGM started (volume: $volume)');
    }).catchError((e) {
      debugPrint('[Audio] BGM start failed: $e');
      _audioAvailable = false;
    });
  }

  void _stopBgm() {
    if (!_audioAvailable) return;
    try {
      FlameAudio.bgm.stop();
      _bgmPlaying = false;
      debugPrint('[Audio] BGM stopped');
    } catch (e) {
      debugPrint('[Audio] BGM stop failed: $e');
      _audioAvailable = false;
    }
  }

  void _setBgmVolume(double volume) {
    if (!_bgmPlaying || !_audioAvailable) return;
    try {
      FlameAudio.bgm.audioPlayer.setVolume(volume);
    } catch (e) {
      debugPrint('[Audio] BGM volume error: $e');
    }
  }

  void _onGameOver() {
    _playSfx(AudioConfig.sfxGameOver, AudioConfig.volGameOver);
    _setBgmVolume(AudioConfig.musicVolumeGameOver);
  }

  void _onWaveStarted(WaveStartedEvent event) {
    _currentWave = event.wave;
    _playSfx(AudioConfig.sfxWave, AudioConfig.volWave);
    _updateBgmVolumeForWave();
  }

  void _updateBgmVolumeForWave() {
    if (_currentWave >= 8) {
      _setBgmVolume(AudioConfig.musicVolumeVeryHighWave);
    } else if (_currentWave >= 4) {
      _setBgmVolume(AudioConfig.musicVolumeHighWave);
    } else {
      _setBgmVolume(AudioConfig.musicVolume);
    }
  }

  void _onPause() {
    if (!_audioAvailable) return;
    try {
      FlameAudio.bgm.pause();
      debugPrint('[Audio] BGM paused');
    } catch (e) {
      debugPrint('[Audio] BGM pause error: $e');
    }
  }

  void _onResume() {
    if (_isMuted || !_audioAvailable) return;
    try {
      FlameAudio.bgm.resume();
      debugPrint('[Audio] BGM resumed');
    } catch (e) {
      debugPrint('[Audio] BGM resume error: $e');
    }
  }

  void _onRestart() {
    _currentWave = 0;
    _sfxCooldowns.clear();
    _setBgmVolume(AudioConfig.musicVolume);
    if (!_bgmPlaying && !_isMuted) {
      _startBgm(AudioConfig.musicVolume);
    }
  }

  void _onStartGame() {
    _inGame = true;
    _currentWave = 0;
    _sfxCooldowns.clear();
    debugPrint('[Audio] Game started');
    _setBgmVolume(AudioConfig.musicVolume);
    if (!_bgmPlaying && !_isMuted) {
      _startBgm(AudioConfig.musicVolume);
    }
  }

  void _onReturnToMenu() {
    _inGame = false;
    _currentWave = 0;
    _sfxCooldowns.clear();
    if (_isMuted) return;
    _stopBgm();
    _startBgm(AudioConfig.musicVolumeMenu);
  }

  // --- Mute ---

  void _toggleMute() {
    _isMuted = !_isMuted;
    debugPrint('[Audio] Mute toggled: $_isMuted');

    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(AudioConfig.muteKey, _isMuted);
    });

    if (_isMuted) {
      _stopBgm();
    } else {
      final volume = _inGame ? AudioConfig.musicVolume : AudioConfig.musicVolumeMenu;
      _startBgm(volume);
    }

    eventBus.emit(MuteChangedEvent(_isMuted));
  }
}
