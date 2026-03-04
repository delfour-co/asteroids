/// Central typed synchronous Event Bus for inter-system communication.
///
/// All features communicate ONLY via this bus — no direct references.
/// Subscribe in onLoad(), unsubscribe in onRemove().
class EventBus {
  final _listeners = <Type, List<Function>>{};

  /// Subscribe to events of type [T].
  void on<T>(void Function(T event) listener) {
    _listeners.putIfAbsent(T, () => []).add(listener);
  }

  /// Unsubscribe from events of type [T].
  void off<T>(void Function(T event) listener) {
    _listeners[T]?.remove(listener);
  }

  /// Emit an event of type [T] synchronously to all listeners.
  void emit<T>(T event) {
    final listeners = _listeners[T];
    if (listeners == null) return;
    for (final listener in List<Function>.from(listeners)) {
      (listener as void Function(T))(event);
    }
  }

  /// Remove all listeners (useful for testing).
  void clear() {
    _listeners.clear();
  }
}

/// Global event bus instance.
final eventBus = EventBus();
