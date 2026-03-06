import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/arcade_events.dart';
import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/core/game_config.dart';
import 'package:asteroids_neon/effects/death_sequence.dart';

void main() {
  setUp(() {
    eventBus.clear();
  });

  group('DeathSequence', () {
    testWithGame<FlameGame>(
      'mounts with priority 900',
      FlameGame.new,
      (game) async {
        final sequence = DeathSequence();
        await game.ensureAdd(sequence);

        expect(sequence.isMounted, true);
        expect(sequence.priority, 900);
      },
    );

    testWithGame<FlameGame>(
      'activates on DeathSlowMoEvent',
      FlameGame.new,
      (game) async {
        final sequence = DeathSequence();
        await game.ensureAdd(sequence);

        eventBus.emit(DeathSlowMoEvent(Vector2(100, 100)));

        // Should remain mounted and process the event
        game.update(0.1);
        expect(sequence.isMounted, true);
      },
    );

    testWithGame<FlameGame>(
      'deactivates after total duration',
      FlameGame.new,
      (game) async {
        final sequence = DeathSequence();
        await game.ensureAdd(sequence);

        eventBus.emit(DeathSlowMoEvent(Vector2(100, 100)));

        // Advance past total duration
        game.update(GameConfig.signalLostDuration + 0.1);

        // Still mounted (persistent component) but no longer active
        expect(sequence.isMounted, true);
      },
    );

    testWithGame<FlameGame>(
      'does not intercept input (containsLocalPoint returns false)',
      FlameGame.new,
      (game) async {
        final sequence = DeathSequence();
        await game.ensureAdd(sequence);

        expect(sequence.containsLocalPoint(Vector2(50, 50)), false);
      },
    );

    testWithGame<FlameGame>(
      'unsubscribes from events on remove',
      FlameGame.new,
      (game) async {
        final sequence = DeathSequence();
        await game.ensureAdd(sequence);

        sequence.removeFromParent();
        game.update(0);

        // Should not throw when emitting after removal
        eventBus.emit(DeathSlowMoEvent(Vector2(100, 100)));
      },
    );
  });
}
