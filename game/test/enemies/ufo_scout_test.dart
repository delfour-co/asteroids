import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/core/game_config.dart';
import 'package:asteroids_neon/enemies/ufo_scout.dart';

void main() {
  setUp(() {
    eventBus.clear();
    GameConfig.enemySpeedMultiplier = 1.0;
  });

  group('UfoScout', () {
    test('initializes with center anchor', () {
      final scout = UfoScout();
      expect(scout.anchor, Anchor.center);
    });

    testWithGame<FlameGame>(
      'moves in set direction',
      FlameGame.new,
      (game) async {
        final scout = UfoScout()
          ..position = Vector2(200, 200);
        await game.ensureAdd(scout);
        scout.setDirection(Vector2(1, 0));

        for (int i = 0; i < 10; i++) {
          game.update(1 / 60);
        }

        expect(scout.position.x, greaterThan(200));
      },
    );

    testWithGame<FlameGame>(
      'removes itself when far off screen',
      FlameGame.new,
      (game) async {
        final scout = UfoScout()
          ..position = Vector2(-100, 200);
        await game.ensureAdd(scout);
        scout.setDirection(Vector2(-1, 0));

        // Move further off screen
        for (int i = 0; i < 30; i++) {
          game.update(1 / 60);
        }

        // Should be removed after going far off screen
        expect(scout.isMounted, false);
      },
    );

    testWithGame<FlameGame>(
      'speed affected by enemySpeedMultiplier',
      FlameGame.new,
      (game) async {
        final scout = UfoScout()
          ..position = Vector2(200, 200);
        await game.ensureAdd(scout);
        scout.setDirection(Vector2(1, 0));

        GameConfig.enemySpeedMultiplier = 0.5;
        game.update(1.0);
        final pos05 = scout.position.x;

        // Reset
        scout.position = Vector2(200, 200);
        GameConfig.enemySpeedMultiplier = 1.0;
        game.update(1.0);
        final pos10 = scout.position.x;

        // Full speed should travel further
        expect(pos10, greaterThan(pos05));
      },
    );
  });
}
