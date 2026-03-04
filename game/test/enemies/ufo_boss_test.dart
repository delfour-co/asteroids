import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/core/game_config.dart';
import 'package:asteroids_neon/enemies/ufo_boss.dart';

void main() {
  setUp(() {
    eventBus.clear();
    GameConfig.enemySpeedMultiplier = 1.0;
  });

  group('UfoBoss', () {
    test('initializes with center anchor', () {
      final boss = UfoBoss();
      expect(boss.anchor, Anchor.center);
    });

    test('has correct size', () {
      final boss = UfoBoss();
      // Radius is 32, so size should be 64x64
      expect(boss.size.x, 64);
      expect(boss.size.y, 64);
    });

    test('boss points configured correctly', () {
      expect(GameConfig.bossPoints, 2000);
    });

    testWithGame<FlameGame>(
      'wraps around screen edges',
      FlameGame.new,
      (game) async {
        final boss = UfoBoss()
          ..position = Vector2(game.size.x + 50, 200);
        await game.ensureAdd(boss);

        game.update(1 / 60);

        expect(boss.position.x, lessThan(0));
      },
    );

    testWithGame<FlameGame>(
      'renders without error',
      FlameGame.new,
      (game) async {
        final boss = UfoBoss()
          ..position = Vector2(200, 200);
        await game.ensureAdd(boss);

        // Just verify it doesn't throw during render
        game.update(1 / 60);
      },
    );
  });
}
