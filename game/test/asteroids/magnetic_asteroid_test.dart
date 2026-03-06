import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/asteroids/asteroid.dart';
import 'package:asteroids_neon/asteroids/magnetic_asteroid.dart';
import 'package:asteroids_neon/core/arcade_events.dart';
import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/core/game_config.dart';

void main() {
  setUp(() {
    eventBus.clear();
    GameConfig.enemySpeedMultiplier = 1.0;
  });

  group('MagneticAsteroid', () {
    test('initializes with correct size for large', () {
      final asteroid = MagneticAsteroid(asteroidSize: AsteroidSize.large);
      expect(asteroid.size.x, AsteroidSize.large.radius * 2);
      expect(asteroid.size.y, AsteroidSize.large.radius * 2);
    });

    test('has center anchor', () {
      final asteroid = MagneticAsteroid(asteroidSize: AsteroidSize.medium);
      expect(asteroid.anchor, Anchor.center);
    });

    testWithGame<FlameGame>(
      'moves according to velocity',
      FlameGame.new,
      (game) async {
        final asteroid = MagneticAsteroid(asteroidSize: AsteroidSize.large)
          ..position = Vector2(200, 200);
        await game.ensureAdd(asteroid);
        asteroid.setVelocity(Vector2(100, 0));

        game.update(1.0);

        expect(asteroid.position.x, greaterThan(200));
      },
    );

    testWithGame<FlameGame>(
      'destroy emits AsteroidDestroyedEvent',
      FlameGame.new,
      (game) async {
        final asteroid = MagneticAsteroid(asteroidSize: AsteroidSize.large)
          ..position = Vector2(100, 100);
        await game.ensureAdd(asteroid);

        AsteroidDestroyedEvent? event;
        eventBus.on<AsteroidDestroyedEvent>((e) => event = e);

        asteroid.destroy();

        expect(event, isNotNull);
        expect(event!.asteroidSize, AsteroidSize.large);
      },
    );

    testWithGame<FlameGame>(
      'destroy with byDash flag',
      FlameGame.new,
      (game) async {
        final asteroid = MagneticAsteroid(asteroidSize: AsteroidSize.medium)
          ..position = Vector2(100, 100);
        await game.ensureAdd(asteroid);

        AsteroidDestroyedEvent? event;
        eventBus.on<AsteroidDestroyedEvent>((e) => event = e);

        asteroid.destroy(byDash: true);

        expect(event!.byDash, true);
      },
    );

    testWithGame<FlameGame>(
      'destroy does not emit KnockbackEvent (only explosive does)',
      FlameGame.new,
      (game) async {
        final asteroid = MagneticAsteroid(asteroidSize: AsteroidSize.large)
          ..position = Vector2(100, 100);
        await game.ensureAdd(asteroid);

        KnockbackEvent? event;
        eventBus.on<KnockbackEvent>((e) => event = e);

        asteroid.destroy();

        expect(event, isNull);
      },
    );

    testWithGame<FlameGame>(
      'speed affected by enemySpeedMultiplier',
      FlameGame.new,
      (game) async {
        final asteroid1 = MagneticAsteroid(asteroidSize: AsteroidSize.large)
          ..position = Vector2(200, 200);
        await game.ensureAdd(asteroid1);
        asteroid1.setVelocity(Vector2(100, 0));
        GameConfig.enemySpeedMultiplier = 1.0;
        game.update(0.5);
        final dist1 = asteroid1.position.x - 200;

        final asteroid2 = MagneticAsteroid(asteroidSize: AsteroidSize.large)
          ..position = Vector2(200, 200);
        await game.ensureAdd(asteroid2);
        asteroid2.setVelocity(Vector2(100, 0));
        GameConfig.enemySpeedMultiplier = 0.5;
        game.update(0.5);
        final dist2 = asteroid2.position.x - 200;

        expect(dist2, lessThan(dist1));
        GameConfig.enemySpeedMultiplier = 1.0;
      },
    );
  });
}
