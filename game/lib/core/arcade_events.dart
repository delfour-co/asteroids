import 'package:flame/components.dart';

/// Event emitted when the game is paused.
class PauseEvent {}

/// Event emitted when the game is resumed.
class ResumeEvent {}

/// Event emitted to return to the title screen.
class ReturnToMenuEvent {}

/// Event emitted when the combo multiplier changes.
class ComboChangedEvent {
  final int multiplier;
  ComboChangedEvent(this.multiplier);
}

/// Event emitted to spawn a score popup at a position.
class ScorePopupEvent {
  final Vector2 position;
  final int points;
  final int multiplier;
  ScorePopupEvent(this.position, this.points, this.multiplier);
}

/// Event emitted to trigger screen shake.
class ScreenShakeEvent {
  final double intensity;
  ScreenShakeEvent(this.intensity);
}

/// Event emitted to trigger a white flash (boss defeated).
class BossFlashEvent {}

/// Event emitted when the countdown starts (blocks input).
class CountdownStartedEvent {}

/// Event emitted when the countdown finishes (unblocks input).
class CountdownFinishedEvent {}

/// Event emitted when a memory fragment is unlocked.
class FragmentUnlockedEvent {
  final int fragmentIndex;
  FragmentUnlockedEvent(this.fragmentIndex);
}

/// Event emitted to trigger death slow-mo sequence.
class DeathSlowMoEvent {
  final Vector2 position;
  DeathSlowMoEvent(this.position);
}

/// Event emitted for a perfect kill (close range).
class PerfectKillEvent {
  final Vector2 position;
  final int points;
  PerfectKillEvent(this.position, this.points);
}

/// Event emitted when a projectile hits a target.
class ProjectileHitEvent {
  final Vector2 position;
  ProjectileHitEvent(this.position);
}

/// Event emitted to apply knockback to nearby asteroids.
class KnockbackEvent {
  final Vector2 origin;
  final double radius;
  final double force;
  KnockbackEvent(this.origin, this.radius, this.force);
}
