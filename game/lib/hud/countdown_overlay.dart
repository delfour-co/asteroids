import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show TextStyle, FontWeight;

import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';

/// READY → GO! countdown overlay at game start.
///
/// Emits CountdownStartedEvent on mount, CountdownFinishedEvent when done.
class CountdownOverlay extends PositionComponent with HasGameReference {
  double _elapsed = 0;
  String _currentText = 'READY';
  bool _finished = false;

  static double get _readyDuration => GameConfig.countdownReadyDuration;
  static double get _goDuration => GameConfig.countdownGoDuration;

  @override
  Future<void> onLoad() async {
    priority = 200;
    eventBus.emit(CountdownStartedEvent());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_finished) return;

    _elapsed += dt;

    if (_elapsed < _readyDuration) {
      _currentText = 'READY';
    } else if (_elapsed < _readyDuration + _goDuration) {
      _currentText = 'GO!';
    } else {
      _finished = true;
      eventBus.emit(CountdownFinishedEvent());
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (_finished) return;

    final gameSize = game.size;

    // Fade out during last 0.3s of each phase
    double opacity = 1.0;
    if (_elapsed < _readyDuration) {
      final remaining = _readyDuration - _elapsed;
      if (remaining < 0.3) opacity = remaining / 0.3;
    } else {
      final goElapsed = _elapsed - _readyDuration;
      final remaining = _goDuration - goElapsed;
      if (remaining < 0.3) opacity = (remaining / 0.3).clamp(0.0, 1.0);
    }

    final color = _currentText == 'GO!'
        ? GameConfig.arcadeGreen
        : GameConfig.arcadeWhite;

    TextPaint(
      style: TextStyle(
        color: color.withValues(alpha: opacity),
        fontSize: 72,
        fontFamily: 'monospace',
        fontWeight: FontWeight.bold,
      ),
    ).render(
      canvas,
      _currentText,
      Vector2(gameSize.x / 2, gameSize.y / 2),
      anchor: Anchor.center,
    );
  }
}
