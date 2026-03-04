import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/asteroids/asteroid.dart';
import 'package:asteroids_neon/core/arcade_events.dart';
import 'package:asteroids_neon/core/combo_manager.dart';
import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/core/game_config.dart';
import 'package:asteroids_neon/enemies/ufo_events.dart';
import 'package:flame/components.dart';

void main() {
  setUp(() {
    eventBus.clear();
  });

  group('ComboManager', () {
    testWithGame<FlameGame>(
      'multiplier starts at 1',
      FlameGame.new,
      (game) async {
        final combo = ComboManager();
        await game.ensureAdd(combo);

        expect(combo.multiplier, 1);
      },
    );

    testWithGame<FlameGame>(
      'multiplier increases on asteroid destroyed',
      FlameGame.new,
      (game) async {
        final combo = ComboManager();
        await game.ensureAdd(combo);

        // First kill -> killCount=1, multiplier stays 1 (clamp(1,8)=1)
        eventBus.emit(AsteroidDestroyedEvent(
          Vector2.zero(),
          AsteroidSize.large,
        ));
        expect(combo.multiplier, 1);

        // Second kill -> killCount=2, multiplier=2
        eventBus.emit(AsteroidDestroyedEvent(
          Vector2.zero(),
          AsteroidSize.medium,
        ));
        expect(combo.multiplier, 2);
      },
    );

    testWithGame<FlameGame>(
      'multiplier increases on UFO destroyed',
      FlameGame.new,
      (game) async {
        final combo = ComboManager();
        await game.ensureAdd(combo);

        eventBus.emit(UfoDestroyedEvent(Vector2.zero(), 500));
        eventBus.emit(UfoDestroyedEvent(Vector2.zero(), 500));
        expect(combo.multiplier, 2);
      },
    );

    testWithGame<FlameGame>(
      'multiplier increases with mixed kill types',
      FlameGame.new,
      (game) async {
        final combo = ComboManager();
        await game.ensureAdd(combo);

        eventBus.emit(AsteroidDestroyedEvent(
          Vector2.zero(),
          AsteroidSize.small,
        ));
        eventBus.emit(UfoDestroyedEvent(Vector2.zero(), 500));
        eventBus.emit(AsteroidDestroyedEvent(
          Vector2.zero(),
          AsteroidSize.large,
        ));
        expect(combo.multiplier, 3);
      },
    );

    testWithGame<FlameGame>(
      'multiplier does not exceed max (${GameConfig.comboMaxMultiplier})',
      FlameGame.new,
      (game) async {
        final combo = ComboManager();
        await game.ensureAdd(combo);

        // Send more kills than max multiplier
        for (int i = 0; i < GameConfig.comboMaxMultiplier + 5; i++) {
          eventBus.emit(AsteroidDestroyedEvent(
            Vector2.zero(),
            AsteroidSize.small,
          ));
        }
        expect(combo.multiplier, GameConfig.comboMaxMultiplier);
      },
    );

    testWithGame<FlameGame>(
      'multiplier resets after combo timeout',
      FlameGame.new,
      (game) async {
        final combo = ComboManager();
        await game.ensureAdd(combo);

        // Build up combo
        eventBus.emit(AsteroidDestroyedEvent(
          Vector2.zero(),
          AsteroidSize.small,
        ));
        eventBus.emit(AsteroidDestroyedEvent(
          Vector2.zero(),
          AsteroidSize.small,
        ));
        expect(combo.multiplier, 2);

        // Advance past the combo timeout
        game.update(GameConfig.comboTimeout + 0.1);

        expect(combo.multiplier, 1);
      },
    );

    testWithGame<FlameGame>(
      'multiplier does not reset before timeout',
      FlameGame.new,
      (game) async {
        final combo = ComboManager();
        await game.ensureAdd(combo);

        eventBus.emit(AsteroidDestroyedEvent(
          Vector2.zero(),
          AsteroidSize.small,
        ));
        eventBus.emit(AsteroidDestroyedEvent(
          Vector2.zero(),
          AsteroidSize.small,
        ));
        expect(combo.multiplier, 2);

        // Advance time but NOT past timeout
        game.update(GameConfig.comboTimeout - 0.5);

        expect(combo.multiplier, 2);
      },
    );

    testWithGame<FlameGame>(
      'emits ComboChangedEvent on multiplier change',
      FlameGame.new,
      (game) async {
        final combo = ComboManager();
        await game.ensureAdd(combo);

        final events = <int>[];
        eventBus.on<ComboChangedEvent>((e) => events.add(e.multiplier));

        // First kill: killCount=1, multiplier stays 1 -> no event (no change)
        eventBus.emit(AsteroidDestroyedEvent(
          Vector2.zero(),
          AsteroidSize.small,
        ));
        expect(events, isEmpty);

        // Second kill: multiplier changes to 2 -> event emitted
        eventBus.emit(AsteroidDestroyedEvent(
          Vector2.zero(),
          AsteroidSize.small,
        ));
        expect(events, [2]);

        // Third kill: multiplier changes to 3 -> event emitted
        eventBus.emit(AsteroidDestroyedEvent(
          Vector2.zero(),
          AsteroidSize.small,
        ));
        expect(events, [2, 3]);
      },
    );

    testWithGame<FlameGame>(
      'emits ComboChangedEvent with multiplier 1 on timeout reset',
      FlameGame.new,
      (game) async {
        final combo = ComboManager();
        await game.ensureAdd(combo);

        // Build combo
        eventBus.emit(AsteroidDestroyedEvent(
          Vector2.zero(),
          AsteroidSize.small,
        ));
        eventBus.emit(AsteroidDestroyedEvent(
          Vector2.zero(),
          AsteroidSize.small,
        ));

        final events = <int>[];
        eventBus.on<ComboChangedEvent>((e) => events.add(e.multiplier));

        // Let timeout expire
        game.update(GameConfig.comboTimeout + 0.1);

        expect(events, [1]);
      },
    );
  });
}
