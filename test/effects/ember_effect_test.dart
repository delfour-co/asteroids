import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/effects/ember_effect.dart';

void main() {
  setUp(() {
    eventBus.clear();
  });

  group('EmberEffect', () {
    testWithGame<FlameGame>(
      'mounts successfully with given particle count',
      FlameGame.new,
      (game) async {
        final ember = EmberEffect(
          color: const Color(0xFFFF00FF),
          particleCount: 5,
        );
        await game.ensureAdd(ember);

        expect(ember.isMounted, true);
      },
    );

    testWithGame<FlameGame>(
      'stays alive during particle lifetime',
      FlameGame.new,
      (game) async {
        final ember = EmberEffect(
          color: const Color(0xFFFF00FF),
          particleCount: 3,
        );
        await game.ensureAdd(ember);

        // Advance a small amount — particles should still be alive
        game.update(0.5);

        expect(ember.isMounted, true);
      },
    );

    testWithGame<FlameGame>(
      'removes itself after all particles expire',
      FlameGame.new,
      (game) async {
        final ember = EmberEffect(
          color: const Color(0xFFFF00FF),
          particleCount: 3,
        );
        await game.ensureAdd(ember);

        // Advance well past max lifetime (2.5s)
        game.update(3.0);
        // Process deferred removal
        game.update(0);

        expect(ember.isMounted, false);
      },
    );

    testWithGame<FlameGame>(
      'works with zero particles (edge case)',
      FlameGame.new,
      (game) async {
        final ember = EmberEffect(
          color: const Color(0xFFFF00FF),
          particleCount: 0,
        );
        await game.ensureAdd(ember);

        // With 0 particles, should remove immediately on first update
        game.update(0.01);
        game.update(0);

        expect(ember.isMounted, false);
      },
    );
  });
}
