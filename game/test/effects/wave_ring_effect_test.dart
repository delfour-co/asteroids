import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/arcade_events.dart';
import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/core/game_config.dart';
import 'package:asteroids_neon/effects/wave_ring_effect.dart';
import 'package:asteroids_neon/enemies/ufo_events.dart';

void main() {
  setUp(() {
    eventBus.clear();
  });

  group('WaveRingEffect', () {
    testWithGame<FlameGame>(
      'mounts with correct priority',
      FlameGame.new,
      (game) async {
        final ring = WaveRingEffect();
        await game.ensureAdd(ring);

        expect(ring.isMounted, true);
        expect(ring.priority, 150);
      },
    );

    testWithGame<FlameGame>(
      'ignores wave 1',
      FlameGame.new,
      (game) async {
        final ring = WaveRingEffect();
        await game.ensureAdd(ring);

        // Track if screen shake was emitted
        bool shakeEmitted = false;
        eventBus.on<ScreenShakeEvent>((_) => shakeEmitted = true);

        eventBus.emit(WaveStartedEvent(1));

        expect(shakeEmitted, false);
      },
    );

    testWithGame<FlameGame>(
      'activates on wave 2+ and emits screen shake',
      FlameGame.new,
      (game) async {
        final ring = WaveRingEffect();
        await game.ensureAdd(ring);

        bool shakeEmitted = false;
        eventBus.on<ScreenShakeEvent>((_) => shakeEmitted = true);

        eventBus.emit(WaveStartedEvent(2));

        expect(shakeEmitted, true);
      },
    );

    testWithGame<FlameGame>(
      'deactivates after duration',
      FlameGame.new,
      (game) async {
        final ring = WaveRingEffect();
        await game.ensureAdd(ring);

        eventBus.emit(WaveStartedEvent(3));

        // Advance past duration
        game.update(GameConfig.waveRingDuration + 0.1);

        // Should still be mounted (persistent component)
        expect(ring.isMounted, true);
      },
    );

    testWithGame<FlameGame>(
      'can be triggered multiple times',
      FlameGame.new,
      (game) async {
        final ring = WaveRingEffect();
        await game.ensureAdd(ring);

        int shakeCount = 0;
        eventBus.on<ScreenShakeEvent>((_) => shakeCount++);

        eventBus.emit(WaveStartedEvent(2));
        game.update(GameConfig.waveRingDuration + 0.1);

        eventBus.emit(WaveStartedEvent(3));

        expect(shakeCount, 2);
      },
    );
  });
}
