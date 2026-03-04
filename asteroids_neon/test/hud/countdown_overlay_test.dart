import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/arcade_events.dart';
import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/core/game_config.dart';
import 'package:asteroids_neon/hud/countdown_overlay.dart';

void main() {
  setUp(() {
    eventBus.clear();
  });

  group('CountdownOverlay', () {
    testWithGame<FlameGame>(
      'emits CountdownStartedEvent on load',
      FlameGame.new,
      (game) async {
        bool started = false;
        eventBus.on<CountdownStartedEvent>((_) => started = true);

        final overlay = CountdownOverlay();
        await game.ensureAdd(overlay);

        expect(started, true);
      },
    );

    testWithGame<FlameGame>(
      'stays mounted during countdown',
      FlameGame.new,
      (game) async {
        final overlay = CountdownOverlay();
        await game.ensureAdd(overlay);

        // Advance partway through READY phase
        game.update(GameConfig.countdownReadyDuration * 0.5);

        expect(overlay.isMounted, true);
      },
    );

    testWithGame<FlameGame>(
      'stays mounted during GO phase',
      FlameGame.new,
      (game) async {
        final overlay = CountdownOverlay();
        await game.ensureAdd(overlay);

        // Advance into GO phase
        game.update(GameConfig.countdownReadyDuration + 0.1);

        expect(overlay.isMounted, true);
      },
    );

    testWithGame<FlameGame>(
      'emits CountdownFinishedEvent and removes self after total duration',
      FlameGame.new,
      (game) async {
        bool finished = false;
        eventBus.on<CountdownFinishedEvent>((_) => finished = true);

        final overlay = CountdownOverlay();
        await game.ensureAdd(overlay);

        final totalDuration = GameConfig.countdownReadyDuration +
            GameConfig.countdownGoDuration;

        // Advance past total duration
        game.update(totalDuration + 0.1);

        expect(finished, true);

        // removeFromParent is deferred; process removal
        game.update(0);

        expect(overlay.isMounted, false);
      },
    );

    testWithGame<FlameGame>(
      'does not emit CountdownFinishedEvent before total duration',
      FlameGame.new,
      (game) async {
        bool finished = false;
        eventBus.on<CountdownFinishedEvent>((_) => finished = true);

        final overlay = CountdownOverlay();
        await game.ensureAdd(overlay);

        // Advance to just before the end
        final totalDuration = GameConfig.countdownReadyDuration +
            GameConfig.countdownGoDuration;
        game.update(totalDuration - 0.1);

        expect(finished, false);
      },
    );
  });
}
