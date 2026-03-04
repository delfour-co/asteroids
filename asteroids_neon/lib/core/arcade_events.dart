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
