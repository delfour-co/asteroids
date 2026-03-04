import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/arcade_events.dart';
import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/core/game_state.dart';
import 'package:asteroids_neon/hud/pause_overlay.dart';
import 'package:asteroids_neon/hud/pause_button.dart';
import 'package:asteroids_neon/hud/menu_button.dart';

void main() {
  setUp(() {
    eventBus.clear();
  });

  group('PauseOverlay', () {
    testWithGame<FlameGame>(
      'does not intercept touches when inactive',
      FlameGame.new,
      (game) async {
        final overlay = PauseOverlay();
        await game.ensureAdd(overlay);

        // When not active, containsLocalPoint should return false
        // so Flame won't route drag events to this component.
        expect(overlay.containsLocalPoint(Vector2(100, 100)), false);
      },
    );

    testWithGame<FlameGame>(
      'intercepts touches when active (paused)',
      FlameGame.new,
      (game) async {
        final overlay = PauseOverlay();
        await game.ensureAdd(overlay);

        eventBus.emit(PauseEvent());

        expect(overlay.containsLocalPoint(Vector2(100, 100)), true);
      },
    );
  });

  group('PauseButton', () {
    testWithGame<FlameGame>(
      'does not intercept touches when hidden',
      FlameGame.new,
      (game) async {
        final button = PauseButton();
        await game.ensureAdd(button);

        // Simulate game over — button hides
        eventBus.emit(GameOverEvent());

        expect(button.containsLocalPoint(Vector2(10, 10)), false);
      },
    );

    testWithGame<FlameGame>(
      'intercepts touches inside bounds when visible',
      FlameGame.new,
      (game) async {
        final button = PauseButton();
        await game.ensureAdd(button);

        // Visible by default — point inside bounds should hit
        expect(button.containsLocalPoint(Vector2(22, 22)), true);
      },
    );

    testWithGame<FlameGame>(
      'does not intercept touches outside bounds even when visible',
      FlameGame.new,
      (game) async {
        final button = PauseButton();
        await game.ensureAdd(button);

        // Visible but point is outside the 44x44 button area
        expect(button.containsLocalPoint(Vector2(200, 200)), false);
      },
    );
  });

  group('MenuButton', () {
    testWithGame<FlameGame>(
      'does not intercept touches when hidden',
      FlameGame.new,
      (game) async {
        final button = MenuButton();
        await game.ensureAdd(button);

        // Hidden by default (only visible on game over)
        expect(button.containsLocalPoint(Vector2(10, 10)), false);
      },
    );

    testWithGame<FlameGame>(
      'intercepts touches when visible',
      FlameGame.new,
      (game) async {
        final button = MenuButton();
        await game.ensureAdd(button);

        eventBus.emit(GameOverEvent());

        expect(button.containsLocalPoint(Vector2(10, 10)), true);
      },
    );
  });
}
