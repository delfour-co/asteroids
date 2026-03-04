import 'package:flame/components.dart';

/// Event emitted when a space debris is destroyed by the player.
class SpaceDebrisDestroyedEvent {
  final Vector2 position;
  final int points;
  final String debrisType; // 'starlink' | 'station' | 'tesla'
  SpaceDebrisDestroyedEvent(this.position, this.points, this.debrisType);
}
