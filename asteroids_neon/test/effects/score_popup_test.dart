import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/game_config.dart';
import 'package:asteroids_neon/effects/score_popup.dart';

void main() {
  group('ScorePopup', () {
    testWithGame<FlameGame>(
      'stays mounted before duration expires',
      FlameGame.new,
      (game) async {
        final popup = ScorePopup(points: 100, multiplier: 1);
        await game.ensureAdd(popup);

        // Advance time but not past duration
        game.update(GameConfig.scorePopupDuration * 0.5);

        expect(popup.isMounted, true);
      },
    );

    testWithGame<FlameGame>(
      'removes itself after duration',
      FlameGame.new,
      (game) async {
        final popup = ScorePopup(points: 100, multiplier: 1);
        await game.ensureAdd(popup);

        // Advance past duration
        game.update(GameConfig.scorePopupDuration + 0.1);

        // removeFromParent is deferred; process removal
        game.update(0);

        expect(popup.isMounted, false);
      },
    );

    testWithGame<FlameGame>(
      'displays multiplier text when multiplier > 1',
      FlameGame.new,
      (game) async {
        final popup = ScorePopup(points: 100, multiplier: 3);
        await game.ensureAdd(popup);

        expect(popup.text, '+300 x3');
      },
    );

    testWithGame<FlameGame>(
      'displays plain text when multiplier is 1',
      FlameGame.new,
      (game) async {
        final popup = ScorePopup(points: 100, multiplier: 1);
        await game.ensureAdd(popup);

        expect(popup.text, '+100');
      },
    );

    testWithGame<FlameGame>(
      'rises upward over time',
      FlameGame.new,
      (game) async {
        final popup = ScorePopup(points: 50, multiplier: 1);
        popup.position.y = 200;
        await game.ensureAdd(popup);

        final startY = popup.position.y;
        game.update(0.1);

        expect(popup.position.y, lessThan(startY));
      },
    );
  });
}
