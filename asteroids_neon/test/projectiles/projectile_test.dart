import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/projectiles/projectile.dart';

void main() {
  setUp(() {
    eventBus.clear();
  });

  group('Projectile', () {
    test('initializes with center anchor', () {
      final projectile = Projectile();
      expect(projectile.anchor, Anchor.center);
    });

    testWithGame<FlameGame>(
      'moves in initialized direction',
      FlameGame.new,
      (game) async {
        final projectile = Projectile();
        await game.ensureAdd(projectile);
        projectile.init(pos: Vector2(400, 300), shipAngle: 0);

        game.update(1 / 60);

        // Angle 0 = facing up, should move in negative y
        expect(projectile.position.y, lessThan(300));
      },
    );

    testWithGame<FlameGame>(
      'moves right when angled pi/2',
      FlameGame.new,
      (game) async {
        final projectile = Projectile();
        await game.ensureAdd(projectile);
        projectile.init(pos: Vector2(400, 300), shipAngle: pi / 2);

        game.update(1 / 60);

        expect(projectile.position.x, greaterThan(400));
      },
    );

    testWithGame<FlameGame>(
      'removes itself after max lifetime',
      FlameGame.new,
      (game) async {
        final projectile = Projectile();
        await game.ensureAdd(projectile);
        projectile.init(pos: Vector2(400, 300), shipAngle: 0);

        // Advance past 2 second lifetime
        for (int i = 0; i < 150; i++) {
          game.update(1 / 60);
        }

        expect(projectile.isMounted, false);
      },
    );

    testWithGame<FlameGame>(
      'wraps around screen edges',
      FlameGame.new,
      (game) async {
        final projectile = Projectile();
        await game.ensureAdd(projectile);
        projectile.init(
          pos: Vector2(game.size.x + 5, 300),
          shipAngle: pi / 2, // Moving right
        );

        game.update(1 / 60);

        // Should wrap to left side
        expect(projectile.position.x, lessThan(game.size.x));
      },
    );
  });
}
