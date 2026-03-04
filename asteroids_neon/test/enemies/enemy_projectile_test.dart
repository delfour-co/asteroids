import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/enemies/enemy_projectile.dart';

void main() {
  setUp(() {
    eventBus.clear();
  });

  group('EnemyProjectile', () {
    test('initializes with center anchor', () {
      final proj = EnemyProjectile();
      expect(proj.anchor, Anchor.center);
    });

    testWithGame<FlameGame>(
      'moves towards target direction',
      FlameGame.new,
      (game) async {
        final proj = EnemyProjectile();
        await game.ensureAdd(proj);
        proj.init(pos: Vector2(200, 200), target: Vector2(300, 200));

        game.update(1 / 60);

        // Should move towards right (positive x)
        expect(proj.position.x, greaterThan(200));
      },
    );

    testWithGame<FlameGame>(
      'removes itself after max lifetime',
      FlameGame.new,
      (game) async {
        final proj = EnemyProjectile();
        await game.ensureAdd(proj);
        proj.init(pos: Vector2(200, 200), target: Vector2(200, 100));

        // Advance past 3 second lifetime
        for (int i = 0; i < 200; i++) {
          game.update(1 / 60);
        }

        expect(proj.isMounted, false);
      },
    );

    testWithGame<FlameGame>(
      'removes itself when off screen',
      FlameGame.new,
      (game) async {
        final proj = EnemyProjectile();
        await game.ensureAdd(proj);
        // Fire straight up from near top
        proj.init(pos: Vector2(200, 10), target: Vector2(200, -100));

        // Should go off screen quickly
        for (int i = 0; i < 10; i++) {
          game.update(1 / 60);
        }

        expect(proj.isMounted, false);
      },
    );
  });
}
