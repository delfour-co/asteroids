import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/asteroids/asteroid.dart';
import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/effects/effects_manager.dart';
import 'package:asteroids_neon/effects/explosion.dart';
import 'package:asteroids_neon/enemies/ufo_events.dart';
import 'package:asteroids_neon/ship/ship.dart';

Future<void> _flushAsync(FlameGame game) async {
  // Let Flame process async onLoad for queued components
  await Future<void>.delayed(Duration.zero);
  game.update(1 / 60);
  await Future<void>.delayed(Duration.zero);
  game.update(1 / 60);
}

void main() {
  setUp(() {
    eventBus.clear();
  });

  group('EffectsManager', () {
    testWithGame<FlameGame>(
      'spawns explosion on asteroid destroyed',
      FlameGame.new,
      (game) async {
        final manager = EffectsManager();
        await game.ensureAdd(manager);

        eventBus.emit(AsteroidDestroyedEvent(
          Vector2(100, 100),
          AsteroidSize.large,
        ));

        await _flushAsync(game);

        final explosions = manager.children.whereType<Explosion>();
        expect(explosions.length, 1);
      },
    );

    testWithGame<FlameGame>(
      'spawns explosion on ship destroyed',
      FlameGame.new,
      (game) async {
        final manager = EffectsManager();
        await game.ensureAdd(manager);

        eventBus.emit(ShipDestroyedEvent(Vector2(200, 200)));

        await _flushAsync(game);

        final explosions = manager.children.whereType<Explosion>();
        expect(explosions.length, 1);
      },
    );

    testWithGame<FlameGame>(
      'spawns explosion on UFO destroyed',
      FlameGame.new,
      (game) async {
        final manager = EffectsManager();
        await game.ensureAdd(manager);

        eventBus.emit(UfoDestroyedEvent(Vector2(150, 150), 500));

        await _flushAsync(game);

        final explosions = manager.children.whereType<Explosion>();
        expect(explosions.length, 1);
      },
    );

    testWithGame<FlameGame>(
      'spawns double explosion on boss defeated',
      FlameGame.new,
      (game) async {
        final manager = EffectsManager();
        await game.ensureAdd(manager);

        eventBus.emit(BossDefeatedEvent(Vector2(200, 200)));

        await _flushAsync(game);

        final explosions = manager.children.whereType<Explosion>();
        expect(explosions.length, 2);
      },
    );

    testWithGame<FlameGame>(
      'handles multiple events in sequence',
      FlameGame.new,
      (game) async {
        final manager = EffectsManager();
        await game.ensureAdd(manager);

        eventBus.emit(AsteroidDestroyedEvent(
          Vector2(100, 100),
          AsteroidSize.small,
        ));
        eventBus.emit(AsteroidDestroyedEvent(
          Vector2(200, 200),
          AsteroidSize.medium,
        ));

        await _flushAsync(game);

        final explosions = manager.children.whereType<Explosion>();
        expect(explosions.length, 2);
      },
    );
  });
}
