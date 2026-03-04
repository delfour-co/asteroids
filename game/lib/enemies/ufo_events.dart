import 'package:flame/components.dart';

/// Event emitted when a UFO is destroyed.
class UfoDestroyedEvent {
  final Vector2 position;
  final int points;
  UfoDestroyedEvent(this.position, this.points);
}

/// Event emitted when a new wave starts (for UFO spawn timing).
class WaveStartedEvent {
  final int wave;
  WaveStartedEvent(this.wave);
}

/// Event emitted when a boss UFO is defeated.
class BossDefeatedEvent {
  final Vector2 position;
  BossDefeatedEvent(this.position);
}
