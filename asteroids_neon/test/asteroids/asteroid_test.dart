import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/asteroids/asteroid.dart';
import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/core/game_config.dart';

void main() {
  setUp(() {
    eventBus.clear();
    GameConfig.enemySpeedMultiplier = 1.0;
  });

  group('Asteroid', () {
    test('initializes with correct size for large', () {
      final asteroid = Asteroid(asteroidSize: AsteroidSize.large);
      expect(asteroid.size.x, AsteroidSize.large.radius * 2);
      expect(asteroid.size.y, AsteroidSize.large.radius * 2);
    });

    test('initializes with correct size for medium', () {
      final asteroid = Asteroid(asteroidSize: AsteroidSize.medium);
      expect(asteroid.size.x, AsteroidSize.medium.radius * 2);
    });

    test('initializes with correct size for small', () {
      final asteroid = Asteroid(asteroidSize: AsteroidSize.small);
      expect(asteroid.size.x, AsteroidSize.small.radius * 2);
    });

    test('has center anchor', () {
      final asteroid = Asteroid(asteroidSize: AsteroidSize.large);
      expect(asteroid.anchor, Anchor.center);
    });

    testWithGame<FlameGame>(
      'moves according to velocity',
      FlameGame.new,
      (game) async {
        final asteroid = Asteroid(asteroidSize: AsteroidSize.large)
          ..position = Vector2(200, 200);
        await game.ensureAdd(asteroid);
        asteroid.setVelocity(Vector2(100, 0));

        game.update(1.0);

        expect(asteroid.position.x, greaterThan(200));
      },
    );

    testWithGame<FlameGame>(
      'wraps around screen edges',
      FlameGame.new,
      (game) async {
        final asteroid = Asteroid(asteroidSize: AsteroidSize.large)
          ..position = Vector2(game.size.x + 50, 200);
        await game.ensureAdd(asteroid);

        game.update(1 / 60);

        expect(asteroid.position.x, lessThan(0));
      },
    );

    testWithGame<FlameGame>(
      'destroy emits AsteroidDestroyedEvent',
      FlameGame.new,
      (game) async {
        final asteroid = Asteroid(asteroidSize: AsteroidSize.medium)
          ..position = Vector2(100, 100);
        await game.ensureAdd(asteroid);

        AsteroidDestroyedEvent? event;
        eventBus.on<AsteroidDestroyedEvent>((e) => event = e);

        asteroid.destroy();

        expect(event, isNotNull);
        expect(event!.asteroidSize, AsteroidSize.medium);
      },
    );

    testWithGame<FlameGame>(
      'destroy with byDash flag',
      FlameGame.new,
      (game) async {
        final asteroid = Asteroid(asteroidSize: AsteroidSize.small)
          ..position = Vector2(100, 100);
        await game.ensureAdd(asteroid);

        AsteroidDestroyedEvent? event;
        eventBus.on<AsteroidDestroyedEvent>((e) => event = e);

        asteroid.destroy(byDash: true);

        expect(event!.byDash, true);
      },
    );

    testWithGame<FlameGame>(
      'speed affected by enemySpeedMultiplier',
      FlameGame.new,
      (game) async {
        // Test at full speed
        final asteroid1 = Asteroid(asteroidSize: AsteroidSize.large)
          ..position = Vector2(200, 200);
        await game.ensureAdd(asteroid1);
        asteroid1.setVelocity(Vector2(100, 0));
        GameConfig.enemySpeedMultiplier = 1.0;
        game.update(0.5);
        final dist1 = asteroid1.position.x - 200;

        // Test at half speed
        final asteroid2 = Asteroid(asteroidSize: AsteroidSize.large)
          ..position = Vector2(200, 200);
        await game.ensureAdd(asteroid2);
        asteroid2.setVelocity(Vector2(100, 0));
        GameConfig.enemySpeedMultiplier = 0.5;
        game.update(0.5);
        final dist2 = asteroid2.position.x - 200;

        // Half speed should travel less
        expect(dist2, lessThan(dist1));
        GameConfig.enemySpeedMultiplier = 1.0;
      },
    );
  });

  group('AsteroidSize', () {
    test('large has correct points', () {
      expect(AsteroidSize.large.points, GameConfig.largeAsteroidPoints);
    });

    test('medium has correct points', () {
      expect(AsteroidSize.medium.points, GameConfig.mediumAsteroidPoints);
    });

    test('small has correct points', () {
      expect(AsteroidSize.small.points, GameConfig.smallAsteroidPoints);
    });

    test('sizes are ordered large > medium > small', () {
      expect(AsteroidSize.large.radius, greaterThan(AsteroidSize.medium.radius));
      expect(AsteroidSize.medium.radius, greaterThan(AsteroidSize.small.radius));
    });
  });
}
