import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/background/shooting_star.dart';
import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/enemies/ufo_events.dart';

void main() {
  setUp(() {
    eventBus.clear();
  });

  group('ShootingStarManager', () {
    testWithGame<FlameGame>(
      'mounts successfully',
      FlameGame.new,
      (game) async {
        final manager = ShootingStarManager();
        await game.ensureAdd(manager);

        expect(manager.isMounted, true);
      },
    );

    testWithGame<FlameGame>(
      'survives update without errors',
      FlameGame.new,
      (game) async {
        final manager = ShootingStarManager();
        await game.ensureAdd(manager);

        // Run several updates to trigger spawn logic
        for (int i = 0; i < 100; i++) {
          game.update(0.5);
        }

        expect(manager.isMounted, true);
      },
    );

    testWithGame<FlameGame>(
      'responds to WaveStartedEvent without errors',
      FlameGame.new,
      (game) async {
        final manager = ShootingStarManager();
        await game.ensureAdd(manager);

        // Emit several wave events to decrease intervals
        for (int i = 1; i <= 10; i++) {
          eventBus.emit(WaveStartedEvent(i));
        }

        // Should still work after interval changes
        game.update(1.0);

        expect(manager.isMounted, true);
      },
    );

    testWithGame<FlameGame>(
      'unsubscribes from events on remove',
      FlameGame.new,
      (game) async {
        final manager = ShootingStarManager();
        await game.ensureAdd(manager);

        manager.removeFromParent();
        game.update(0);

        // Should not throw when emitting after removal
        eventBus.emit(WaveStartedEvent(5));
      },
    );
  });
}
