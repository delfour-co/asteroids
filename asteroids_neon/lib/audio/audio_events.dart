/// Event emitted to toggle mute state.
class MuteToggleEvent {}

/// Event emitted when mute state changes.
class MuteChangedEvent {
  final bool isMuted;
  MuteChangedEvent(this.isMuted);
}

/// Event emitted when a UI button is tapped (for click SFX).
class UiNavigationEvent {}
