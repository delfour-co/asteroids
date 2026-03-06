import 'dart:ui';

/// Static game configuration constants.
///
/// All balancing values live here — single source of truth.
abstract class GameConfig {
  // Ship
  static const double shipMaxSpeed = 300.0;
  static const int startingLives = 3;
  static const int extraLifeScore = 15000;

  // Dash
  static const double dashDuration = 0.5;
  static const double dashCooldown = 3.0;

  // Scoring
  static const int largeAsteroidPoints = 20;
  static const int mediumAsteroidPoints = 50;
  static const int smallAsteroidPoints = 100;
  static const int ufoPoints = 500;
  static const int bossPoints = 2000;

  // Upgrades
  static const double upgradeDuration = 12.0;
  static const double wreckageLifetime = 8.0;

  // Visuals
  static const Color shipColor = Color(0xFF00FFFF);
  static const Color backgroundColor = Color(0xFF000011);
  static const double glowRadius = 10.0;
  static const double glowOpacity = 0.6;

  // Starfield
  static const int starCount = 150;
  static const double starMinSize = 1.0;
  static const double starMaxSize = 3.0;
  static const double starMinOpacity = 0.3;
  static const double starMaxOpacity = 1.0;

  // Joystick
  static final Paint joystickKnobPaint = Paint()
    ..color = const Color(0xFF00FFFF)
    ..style = PaintingStyle.fill;

  static final Paint joystickBackgroundPaint = Paint()
    ..color = const Color(0x4400FFFF)
    ..style = PaintingStyle.fill;

  // Buttons
  static final Paint thrustButtonPaint = Paint()
    ..color = const Color(0xFF00FFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  // Physics
  static const double shipAcceleration = 200.0;
  static const double shipMaxVelocity = 300.0;
  static const double shipDrag = 0.98; // Multiplied per frame for inertia drift

  // Slow-mo multiplier (mutable — affected by power-up)
  static double enemySpeedMultiplier = 1.0;

  // Combo
  static const double comboTimeout = 2.0; // seconds before combo resets
  static const int comboMaxMultiplier = 8;
  static const Color comboColor = Color(0xFFFFFF00);

  // Score popup
  static const double scorePopupDuration = 0.8;
  static const double scorePopupRiseSpeed = 60.0;
  static const double scorePopupFontSize = 20.0;

  // Screen shake
  static const double shakeIntensitySmall = 3.0;
  static const double shakeIntensityMedium = 6.0;
  static const double shakeIntensityLarge = 10.0;
  static const double shakeIntensityBoss = 16.0;
  static const double shakeDuration = 0.3;

  // Flash effect
  static const double flashDuration = 0.4;

  // Countdown
  static const double countdownReadyDuration = 1.2;
  static const double countdownGoDuration = 0.6;

  // Wave announcement
  static const double waveAnnounceFadeIn = 0.3;
  static const double waveAnnounceHold = 1.0;
  static const double waveAnnounceFadeOut = 0.5;
  static const double waveAnnounceSize = 48.0;

  // Leaderboard
  static const int leaderboardMaxEntries = 10;
  static const String leaderboardKey = 'leaderboard_v1';

  // Arcade colors
  static const Color arcadeYellow = Color(0xFFFFFF00);
  static const Color arcadeGreen = Color(0xFF00FF66);
  static const Color arcadeRed = Color(0xFFFF0066);
  static const Color arcadeWhite = Color(0xFFFFFFFF);

  // Space debris
  static const Color starlinkColor = Color(0xFFCCCCCC);
  static const Color stationColor = Color(0xFF00FFAA);
  static const Color teslaColor = Color(0xFFFFBB00);
  static const int starlinkPoints = 150;
  static const int stationPoints = 300;
  static const int teslaPoints = 250;
  static const double debrisMinSpeed = 15.0;
  static const double debrisMaxSpeed = 35.0;

  // Tutorial
  static const String tutorialSeenKey = 'tutorial_seen';

  // Wave ring transition
  static const double waveRingDuration = 0.8;
  static const double waveRingShakeIntensity = 2.0;
  static const Color waveRingColor = Color(0xFF00FFFF);

  // Embers
  static const double emberMinLifetime = 1.5;
  static const double emberMaxLifetime = 2.5;
  static const double emberMinSpeed = 5.0;
  static const double emberMaxSpeed = 30.0;
  static const double emberMinSize = 0.5;
  static const double emberMaxSize = 1.5;
  static const int emberCountSmall = 0; // skip small asteroids
  static const int emberCountMedium = 5;
  static const int emberCountLarge = 7;
  static const int emberCountUfo = 7;
  static const int emberCountBoss = 12;
  static const int emberCountShip = 6;

  // Narration — memory fragments
  static const int fragmentUnlockInterval = 10; // every N waves
  static const String fragmentsKey = 'unlocked_fragments';

  // Death sequence
  static const double deathSlowMoDuration = 0.6;
  static const double deathSlowMoFactor = 0.3;
  static const double signalLostDuration = 2.5;

  // Shooting stars
  static const double shootingStarMinInterval = 8.0;
  static const double shootingStarMaxInterval = 20.0;
  static const double shootingStarSpeed = 400.0;
  static const double shootingStarLength = 60.0;

  // Special asteroids
  static const Color explosiveAsteroidColor = Color(0xFFFF4400);
  static const Color magneticAsteroidColor = Color(0xFFAA00FF);
  static const double magneticPullRadius = 150.0;
  static const double magneticPullForce = 40.0;
  static const double explosiveBlastRadius = 120.0;
  static const int explosiveMinWave = 5;
  static const int magneticMinWave = 8;

  // Perfect kill
  static const double perfectKillRange = 60.0;
  static const int perfectKillMultiplier = 2;
  static const double knockbackRadius = 100.0;
  static const double knockbackForce = 80.0;

  // Cosmetics
  static const String selectedColorKey = 'selected_ship_color';
  static const String unlockedColorsKey = 'unlocked_colors';
  static const List<int> cosmeticUnlockWaves = [10, 20, 30, 50];
  static const List<Color> shipColors = [
    Color(0xFF00FFFF), // Cyan (default)
    Color(0xFFFF00FF), // Magenta (wave 10)
    Color(0xFF00FF66), // Green (wave 20)
    Color(0xFFFFCC00), // Gold (wave 30)
  ];
  static const List<String> shipColorNames = ['CYAN', 'MAGENTA', 'GREEN', 'GOLD'];
}
