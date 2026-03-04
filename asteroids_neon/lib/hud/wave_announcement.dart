import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show TextStyle, FontWeight;

import '../core/game_config.dart';

/// Big "WAVE X" text that fades in, holds, then fades out and self-removes.
class WaveAnnouncement extends TextComponent with HasGameReference {
  final int wave;
  double _elapsed = 0;

  static const double _fadeIn = 0.3;
  static const double _hold = 1.0;
  static const double _fadeOut = 0.5;
  static double get _totalDuration =>
      GameConfig.waveAnnounceFadeIn +
      GameConfig.waveAnnounceHold +
      GameConfig.waveAnnounceFadeOut;

  WaveAnnouncement({required this.wave})
      : super(
          text: 'WAVE $wave',
          textRenderer: TextPaint(
            style: TextStyle(
              color: GameConfig.arcadeWhite,
              fontSize: GameConfig.waveAnnounceSize,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    position = Vector2(game.size.x / 2, game.size.y / 2);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    double opacity;
    if (_elapsed < GameConfig.waveAnnounceFadeIn) {
      opacity = _elapsed / GameConfig.waveAnnounceFadeIn;
    } else if (_elapsed < GameConfig.waveAnnounceFadeIn + GameConfig.waveAnnounceHold) {
      opacity = 1.0;
    } else {
      final fadeProgress = (_elapsed - GameConfig.waveAnnounceFadeIn - GameConfig.waveAnnounceHold) /
          GameConfig.waveAnnounceFadeOut;
      opacity = (1.0 - fadeProgress).clamp(0.0, 1.0);
    }

    textRenderer = TextPaint(
      style: TextStyle(
        color: GameConfig.arcadeWhite.withValues(alpha: opacity),
        fontSize: GameConfig.waveAnnounceSize,
        fontFamily: 'monospace',
        fontWeight: FontWeight.bold,
      ),
    );

    if (_elapsed >= _totalDuration) {
      removeFromParent();
    }
  }
}
