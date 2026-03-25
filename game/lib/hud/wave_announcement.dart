import 'package:flame/components.dart';
import 'dart:ui' show Color;

import 'package:flutter/painting.dart' show FontWeight, Shadow, TextStyle;

import '../core/game_config.dart';

/// Big "WAVE X" text that fades in, holds, then fades out and self-removes.
class WaveAnnouncement extends TextComponent with HasGameReference {
  final int wave;
  double _elapsed = 0;

  static double get _totalDuration =>
      GameConfig.waveAnnounceFadeIn +
      GameConfig.waveAnnounceHold +
      GameConfig.waveAnnounceFadeOut;

  WaveAnnouncement({required this.wave})
      : super(
          text: 'WAVE $wave',
          textRenderer: TextPaint(
            style: TextStyle(
              color: GameConfig.shipColor,
              fontSize: GameConfig.waveAnnounceSize,
              fontFamily: 'JetBrainsMono',
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              shadows: [
                Shadow(color: Color(0x9900FFFF), blurRadius: 12),
                Shadow(color: Color(0x4400FFFF), blurRadius: 24),
              ],
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
        color: GameConfig.shipColor.withValues(alpha: opacity),
        fontSize: GameConfig.waveAnnounceSize,
        fontFamily: 'JetBrainsMono',
        fontWeight: FontWeight.bold,
        letterSpacing: 4.0,
        shadows: [
          Shadow(color: Color(0x9900FFFF).withValues(alpha: opacity), blurRadius: 12),
          Shadow(color: Color(0x4400FFFF).withValues(alpha: opacity), blurRadius: 24),
        ],
      ),
    );

    if (_elapsed >= _totalDuration) {
      removeFromParent();
    }
  }
}
