import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/core/game_state.dart';
import 'package:asteroids_neon/enemies/ufo_boss.dart';
import 'package:asteroids_neon/enemies/ufo_events.dart';
import 'package:asteroids_neon/enemies/ufo_hunter.dart';
import 'package:asteroids_neon/enemies/ufo_manager.dart';
import 'package:asteroids_neon/enemies/ufo_scout.dart';

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

  group('UfoManager', () {
    testWithGame<FlameGame>(
      'does not spawn UFOs before scout start wave',
      FlameGame.new,
      (game) async {
        final manager = UfoManager();
        await game.ensureAdd(manager);

        eventBus.emit(WaveStartedEvent(1));
        for (int i = 0; i < 300; i++) {
          game.update(1 / 60);
        }

        final ufos = manager.children.whereType<UfoScout>().length;
        expect(ufos, 0);
      },
    );

    testWithGame<FlameGame>(
      'spawns scouts after scout start wave',
      FlameGame.new,
      (game) async {
        final manager = UfoManager();
        await game.ensureAdd(manager);

        eventBus.emit(WaveStartedEvent(4));

        // Advance enough for spawn timer to trigger, with async processing
        for (int i = 0; i < 120; i++) {
          await Future<void>.delayed(Duration.zero);
          game.update(0.5);
        }

        final scouts = manager.children.whereType<UfoScout>().length;
        expect(scouts, greaterThan(0));
      },
    );

    testWithGame<FlameGame>(
      'spawns boss on wave 5',
      FlameGame.new,
      (game) async {
        final manager = UfoManager();
        await game.ensureAdd(manager);

        eventBus.emit(WaveStartedEvent(5));

        await _flushAsync(game, frames: 5);

        final bosses = manager.children.whereType<UfoBoss>().length;
        expect(bosses, 1);
      },
    );

    testWithGame<FlameGame>(
      'spawns boss on wave 10',
      FlameGame.new,
      (game) async {
        final manager = UfoManager();
        await game.ensureAdd(manager);

        eventBus.emit(WaveStartedEvent(10));

        await _flushAsync(game, frames: 5);

        final bosses = manager.children.whereType<UfoBoss>().length;
        expect(bosses, 1);
      },
    );

    testWithGame<FlameGame>(
      'does not spawn boss on non-multiple-of-5 wave',
      FlameGame.new,
      (game) async {
        final manager = UfoManager();
        await game.ensureAdd(manager);

        eventBus.emit(WaveStartedEvent(7));

        await _flushAsync(game, frames: 5);

        final bosses = manager.children.whereType<UfoBoss>().length;
        expect(bosses, 0);
      },
    );

    testWithGame<FlameGame>(
      'clearAll removes all UFOs',
      FlameGame.new,
      (game) async {
        final manager = UfoManager();
        await game.ensureAdd(manager);

        eventBus.emit(WaveStartedEvent(5));
        await _flushAsync(game, frames: 5);

        manager.clearAll();
        game.update(0);

        expect(manager.children.whereType<UfoBoss>().length, 0);
      },
    );

    testWithGame<FlameGame>(
      'stops spawning after game over',
      FlameGame.new,
      (game) async {
        final manager = UfoManager();
        await game.ensureAdd(manager);

        eventBus.emit(WaveStartedEvent(4));
        eventBus.emit(GameOverEvent());

        for (int i = 0; i < 60; i++) {
          await Future<void>.delayed(Duration.zero);
          game.update(0.5);
        }

        final scouts = manager.children.whereType<UfoScout>().length;
        expect(scouts, 0);
      },
    );
  });
}
