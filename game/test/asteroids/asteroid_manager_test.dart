import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/asteroids/asteroid.dart';
import 'package:asteroids_neon/asteroids/asteroid_manager.dart';
import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/enemies/ufo_events.dart';

Future<void> _flushAsync(FlameGame game) async {
  await Future<void>.delayed(Duration.zero);
  game.update(1 / 60);
  await Future<void>.delayed(Duration.zero);
  game.update(1 / 60);
}

void main() {
  setUp(() {
    eventBus.clear();
  });

  group('AsteroidManager', () {
    testWithGame<FlameGame>(
      'spawns initial wave of asteroids on load',
      FlameGame.new,
      (game) async {
        final manager = AsteroidManager();
        await game.ensureAdd(manager);

        final asteroids = manager.children.whereType<Asteroid>();
        expect(asteroids.length, 4);
      },
    );

    testWithGame<FlameGame>(
      'emits WaveStartedEvent on wave spawn',
      FlameGame.new,
      (game) async {
        int? waveNumber;
        eventBus.on<WaveStartedEvent>((e) => waveNumber = e.wave);

        final manager = AsteroidManager();
        await game.ensureAdd(manager);

        expect(waveNumber, 1);
      },
    );

    testWithGame<FlameGame>(
      'splits large asteroid into two medium on destroy',
      FlameGame.new,
      (game) async {
        final manager = AsteroidManager();
        await game.ensureAdd(manager);

        eventBus.emit(AsteroidDestroyedEvent(
          Vector2(100, 100),
          AsteroidSize.large,
        ));

        await _flushAsync(game);

        final mediums = manager.children
            .whereType<Asteroid>()
            .where((a) => a.asteroidSize == AsteroidSize.medium);
        expect(mediums.length, 2);
      },
    );

    testWithGame<FlameGame>(
      'splits medium asteroid into two small on destroy',
      FlameGame.new,
      (game) async {
        final manager = AsteroidManager();
        await game.ensureAdd(manager);

        eventBus.emit(AsteroidDestroyedEvent(
          Vector2(100, 100),
          AsteroidSize.medium,
        ));

        await _flushAsync(game);

        final smalls = manager.children
            .whereType<Asteroid>()
            .where((a) => a.asteroidSize == AsteroidSize.small);
        expect(smalls.length, 2);
      },
    );

    testWithGame<FlameGame>(
      'does not split small asteroids',
      FlameGame.new,
      (game) async {
        final manager = AsteroidManager();
        await game.ensureAdd(manager);

        final countBefore = manager.children.whereType<Asteroid>().length;

        eventBus.emit(AsteroidDestroyedEvent(
          Vector2(100, 100),
          AsteroidSize.small,
        ));

        await _flushAsync(game);

        final countAfter = manager.children.whereType<Asteroid>().length;
        expect(countAfter, countBefore);
      },
    );
  });
}
