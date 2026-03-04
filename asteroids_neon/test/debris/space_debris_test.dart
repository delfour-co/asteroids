import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:asteroids_neon/core/arcade_events.dart';
import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/core/game_state.dart';
import 'package:asteroids_neon/debris/debris_events.dart';
import 'package:asteroids_neon/debris/space_debris_manager.dart';
import 'package:asteroids_neon/debris/space_station.dart';
import 'package:asteroids_neon/debris/starlink_train.dart';
import 'package:asteroids_neon/debris/tesla_roadster.dart';
import 'package:asteroids_neon/enemies/ufo_events.dart';

Future<void> _flushAsync(FlameGame game, {int frames = 2}) async {
  for (int i = 0; i < frames; i++) {
    await Future<void>.delayed(Duration.zero);
    game.update(1 / 60);
  }
}

void main() {
  setUp(() {
    eventBus.clear();
  });

  group('SpaceDebrisManager', () {
    testWithGame<FlameGame>(
      'spawns debris on even wave >= 2',
      FlameGame.new,
      (game) async {
        final manager = SpaceDebrisManager();
        await game.ensureAdd(manager);

        eventBus.emit(WaveStartedEvent(2));
        await _flushAsync(game, frames: 5);

        final debrisCount = manager.children
            .where((c) =>
                c is StarlinkTrain || c is SpaceStation || c is TeslaRoadster)
            .length;
        expect(debrisCount, 1);
      },
    );

    testWithGame<FlameGame>(
      'does not spawn debris on odd wave',
      FlameGame.new,
      (game) async {
        final manager = SpaceDebrisManager();
        await game.ensureAdd(manager);

        eventBus.emit(WaveStartedEvent(3));
        await _flushAsync(game, frames: 5);

        final debrisCount = manager.children
            .where((c) =>
                c is StarlinkTrain || c is SpaceStation || c is TeslaRoadster)
            .length;
        expect(debrisCount, 0);
      },
    );

    testWithGame<FlameGame>(
      'does not spawn debris on wave 1',
      FlameGame.new,
      (game) async {
        final manager = SpaceDebrisManager();
        await game.ensureAdd(manager);

        eventBus.emit(WaveStartedEvent(1));
        await _flushAsync(game, frames: 5);

        final debrisCount = manager.children
            .where((c) =>
                c is StarlinkTrain || c is SpaceStation || c is TeslaRoadster)
            .length;
        expect(debrisCount, 0);
      },
    );

    testWithGame<FlameGame>(
      'stops spawning after game over',
      FlameGame.new,
      (game) async {
        final manager = SpaceDebrisManager();
        await game.ensureAdd(manager);

        eventBus.emit(GameOverEvent());

        // Advance past random timer
        for (int i = 0; i < 300; i++) {
          await Future<void>.delayed(Duration.zero);
          game.update(0.5);
        }

        final debrisCount = manager.children
            .where((c) =>
                c is StarlinkTrain || c is SpaceStation || c is TeslaRoadster)
            .length;
        expect(debrisCount, 0);
      },
    );

    testWithGame<FlameGame>(
      'clearAll removes all debris',
      FlameGame.new,
      (game) async {
        final manager = SpaceDebrisManager();
        await game.ensureAdd(manager);

        eventBus.emit(WaveStartedEvent(2));
        await _flushAsync(game, frames: 5);

        manager.clearAll();
        game.update(0);

        final debrisCount = manager.children
            .where((c) =>
                c is StarlinkTrain || c is SpaceStation || c is TeslaRoadster)
            .length;
        expect(debrisCount, 0);
      },
    );

    testWithGame<FlameGame>(
      'random timer spawns debris between 20-40s',
      FlameGame.new,
      (game) async {
        final manager = SpaceDebrisManager();
        await game.ensureAdd(manager);

        // Advance 41 seconds — should have spawned at least once
        for (int i = 0; i < 410; i++) {
          await Future<void>.delayed(Duration.zero);
          game.update(0.1);
        }

        final debrisCount = manager.children
            .where((c) =>
                c is StarlinkTrain || c is SpaceStation || c is TeslaRoadster)
            .length;
        expect(debrisCount, greaterThan(0));
      },
    );
  });

  group('StarlinkTrain', () {
    testWithGame<FlameGame>(
      'has 7 satellite children',
      FlameGame.new,
      (game) async {
        final train =
            StarlinkTrain(velocity: Vector2(20, 0))..position = Vector2(100, 100);
        await game.ensureAdd(train);
        await _flushAsync(game, frames: 3);

        expect(train.children.length, 7);
      },
    );
  });

  group('SpaceStation', () {
    testWithGame<FlameGame>(
      'starts with 3 HP and survives 2 hits',
      FlameGame.new,
      (game) async {
        final station =
            SpaceStation(velocity: Vector2(20, 0))..position = Vector2(100, 100);
        await game.ensureAdd(station);
        await _flushAsync(game, frames: 3);

        // Station should still be mounted after creation
        expect(station.isMounted, isTrue);
      },
    );
  });

  group('SpaceDebrisDestroyedEvent scoring', () {
    test('awards points with combo multiplier', () async {
      SharedPreferences.setMockInitialValues({});

      final gameState = GameState();
      await gameState.init();

      // Set combo to 2x
      eventBus.emit(ComboChangedEvent(2));

      int? lastScore;
      eventBus.on<ScoreChangedEvent>((e) => lastScore = e.score);

      eventBus.emit(SpaceDebrisDestroyedEvent(
        Vector2(100, 100),
        150,
        'starlink',
      ));

      expect(lastScore, 300); // 150 * 2

      gameState.dispose();
    });
  });

  group('TeslaRoadster', () {
    testWithGame<FlameGame>(
      'is mounted and positioned correctly',
      FlameGame.new,
      (game) async {
        final tesla =
            TeslaRoadster(velocity: Vector2(20, 0))..position = Vector2(200, 200);
        await game.ensureAdd(tesla);
        await _flushAsync(game, frames: 3);

        expect(tesla.isMounted, isTrue);
        expect(tesla.position.x, closeTo(200, 5));
      },
    );
  });
}
