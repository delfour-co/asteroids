import 'dart:math';

import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/input/joystick.dart';
import 'package:asteroids_neon/ship/ship.dart';

void main() {
  setUp(() {
    eventBus.clear();
  });

  group('Ship rotation via EventBus', () {
    testWithGame<FlameGame>(
      'ship rotates when receiving joystick direction event',
      FlameGame.new,
      (game) async {
        final ship = Ship()..position = Vector2(100, 100);
        await game.ensureAdd(ship);

        expect(ship.angle, 0.0);

        // Emit joystick event pointing right (pi/2)
        eventBus.emit(JoystickDirectionEvent(
          angle: pi / 2,
          isActive: true,
          intensity: 1.0,
        ));

        expect(ship.angle, pi / 2);
      },
    );

    testWithGame<FlameGame>(
      'ship keeps angle when joystick released',
      FlameGame.new,
      (game) async {
        final ship = Ship()..position = Vector2(100, 100);
        await game.ensureAdd(ship);

        // Rotate to pi/4
        eventBus.emit(JoystickDirectionEvent(
          angle: pi / 4,
          isActive: true,
          intensity: 1.0,
        ));

        expect(ship.angle, pi / 4);

        // Release joystick
        eventBus.emit(JoystickDirectionEvent(
          angle: 0,
          isActive: false,
          intensity: 0,
        ));

        // Ship should keep its angle
        expect(ship.angle, pi / 4);
      },
    );

    testWithGame<FlameGame>(
      'ship unsubscribes on remove',
      FlameGame.new,
      (game) async {
        final ship = Ship()..position = Vector2(100, 100);
        await game.ensureAdd(ship);

        ship.removeFromParent();
        game.update(0); // Process removal

        // This should not affect the removed ship
        eventBus.emit(JoystickDirectionEvent(
          angle: pi,
          isActive: true,
          intensity: 1.0,
        ));

        // Ship angle should remain at 0 (default, since it was removed)
        expect(ship.angle, 0.0);
      },
    );
  });
}
