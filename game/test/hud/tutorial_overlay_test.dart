import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/hud/tutorial_overlay.dart';

void main() {
  setUp(() {
    eventBus.clear();
  });

  group('TutorialOverlay', () {
    testWithGame<FlameGame>(
      'mounts with correct priority',
      FlameGame.new,
      (game) async {
        final overlay = TutorialOverlay(onDismiss: () {});
        await game.ensureAdd(overlay);

        expect(overlay.isMounted, true);
        expect(overlay.priority, 250);
      },
    );

    testWithGame<FlameGame>(
      'always intercepts touches (containsLocalPoint returns true)',
      FlameGame.new,
      (game) async {
        final overlay = TutorialOverlay(onDismiss: () {});
        await game.ensureAdd(overlay);

        expect(overlay.containsLocalPoint(Vector2(100, 100)), true);
        expect(overlay.containsLocalPoint(Vector2(0, 0)), true);
      },
    );

    testWithGame<FlameGame>(
      'covers full game size',
      FlameGame.new,
      (game) async {
        final overlay = TutorialOverlay(onDismiss: () {});
        await game.ensureAdd(overlay);

        expect(overlay.size.x, game.size.x);
        expect(overlay.size.y, game.size.y);
      },
    );

    testWithGame<FlameGame>(
      'onDismiss callback is provided and overlay is functional',
      FlameGame.new,
      (game) async {
        bool dismissed = false;
        final overlay = TutorialOverlay(onDismiss: () => dismissed = true);
        await game.ensureAdd(overlay);

        // Call onDismiss directly to verify callback works
        overlay.onDismiss();
        expect(dismissed, true);
      },
    );

    testWithGame<FlameGame>(
      'position is at origin',
      FlameGame.new,
      (game) async {
        final overlay = TutorialOverlay(onDismiss: () {});
        await game.ensureAdd(overlay);

        expect(overlay.position.x, 0);
        expect(overlay.position.y, 0);
      },
    );
  });
}
