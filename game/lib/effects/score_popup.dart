import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show TextStyle, FontWeight;

import '../core/game_config.dart';

/// Floating "+100 x2" text that rises and fades out.
class ScorePopup extends TextComponent {
  final int points;
  final int multiplier;
  double _elapsed = 0;

  ScorePopup({
    required this.points,
    required this.multiplier,
  }) : super(
          text: multiplier > 1
              ? '+${points * multiplier} x$multiplier'
              : '+$points',
          textRenderer: TextPaint(
            style: TextStyle(
              color: multiplier > 1
                  ? GameConfig.comboColor
                  : GameConfig.arcadeWhite,
              fontSize: GameConfig.scorePopupFontSize,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    // Rise
    position.y -= GameConfig.scorePopupRiseSpeed * dt;

    // Fade out
    final progress = _elapsed / GameConfig.scorePopupDuration;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    final color = multiplier > 1
        ? GameConfig.comboColor
        : GameConfig.arcadeWhite;
    textRenderer = TextPaint(
      style: TextStyle(
        color: color.withValues(alpha: opacity),
        fontSize: GameConfig.scorePopupFontSize,
        fontFamily: 'monospace',
        fontWeight: FontWeight.bold,
      ),
    );

    if (_elapsed >= GameConfig.scorePopupDuration) {
      removeFromParent();
    }
  }
}
