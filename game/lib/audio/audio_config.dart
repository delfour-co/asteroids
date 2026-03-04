/// Audio file names and volume configuration.
abstract class AudioConfig {
  // BGM
  static const String musicAmbient = 'music_ambient.ogg';
  static const double musicVolume = 0.35;
  static const double musicVolumeMenu = 0.175; // × 0.5
  static const double musicVolumeGameOver = 0.105; // × 0.3
  static const double musicVolumeHighWave = 0.455; // × 1.3 (wave 4+)
  static const double musicVolumeVeryHighWave = 0.56; // × 1.6 (wave 8+)

  // SFX files
  static const String sfxFire = 'sfx_fire.ogg';
  static const String sfxExplosionSmall = 'sfx_explosion_small.ogg';
  static const String sfxExplosionMedium = 'sfx_explosion_medium.ogg';
  static const String sfxExplosionLarge = 'sfx_explosion_large.ogg';
  static const String sfxDash = 'sfx_dash.ogg';
  static const String sfxPowerup = 'sfx_powerup.ogg';
  static const String sfxUfoDestroy = 'sfx_ufo_destroy.ogg';
  static const String sfxBossDefeat = 'sfx_boss_defeat.ogg';
  static const String sfxShipDestroyed = 'sfx_ship_destroyed.ogg';
  static const String sfxExtraLife = 'sfx_extra_life.ogg';
  static const String sfxWave = 'sfx_wave.ogg';
  static const String sfxUiSelect = 'sfx_ui_select.ogg';
  static const String sfxGameOver = 'sfx_game_over.ogg';
  static const String sfxCombo = 'sfx_combo.ogg';

  // SFX volumes
  static const double volFire = 0.3;
  static const double volExplosion = 0.7;
  static const double volDash = 0.7;
  static const double volPowerup = 0.7;
  static const double volUfoDestroy = 0.7;
  static const double volBossDefeat = 0.7;
  static const double volShipDestroyed = 0.7;
  static const double volExtraLife = 0.7;
  static const double volWave = 0.6;
  static const double volUiSelect = 0.5;
  static const double volGameOver = 0.7;
  static const double volCombo = 0.4;

  // Fire cooldown to avoid spam
  static const double fireCooldown = 0.15; // 150ms

  // SharedPreferences key
  static const String muteKey = 'audio_muted';
}
