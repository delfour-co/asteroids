import 'dart:math';

import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/input/action_buttons.dart';
import 'package:asteroids_neon/input/joystick.dart';
import 'package:asteroids_neon/ship/ship.dart';

void main() {
  setUp(() {
    eventBus.clear();
  });

  group('Ship thrust and inertia', () {
    testWithGame<FlameGame>(
      'thrust accelerates ship in facing direction',
      FlameGame.new,
      (game) async {
        final ship = Ship()..position = Vector2(400, 300);
        await game.ensureAdd(ship);

        // Ship faces up by default (angle = 0)
        // Start thrusting
        eventBus.emit(ThrustEvent(true));

        // Update a few frames
        for (int i = 0; i < 10; i++) {
          game.update(1 / 60);
        }

        // Ship should have moved upward (negative y)
        expect(ship.position.y, lessThan(300));
        expect(ship.velocity.length, greaterThan(0));
      },
    );

    testWithGame<FlameGame>(
      'ship drifts after releasing thrust (inertia)',
      FlameGame.new,
      (game) async {
        final ship = Ship()..position = Vector2(400, 300);
        await game.ensureAdd(ship);

        // Thrust for a bit
        eventBus.emit(ThrustEvent(true));
        for (int i = 0; i < 10; i++) {
          game.update(1 / 60);
        }

        final velocityAfterThrust = ship.velocity.length;

        // Release thrust
        eventBus.emit(ThrustEvent(false));

        // Update more frames — ship should still be moving but slowing
        game.update(1 / 60);

        expect(ship.velocity.length, greaterThan(0));
        expect(ship.velocity.length, lessThan(velocityAfterThrust));
      },
    );

    testWithGame<FlameGame>(
      'thrust direction follows ship angle',
      FlameGame.new,
      (game) async {
        final ship = Ship()..position = Vector2(400, 300);
        await game.ensureAdd(ship);

        // Rotate to face right (pi/2)
        eventBus.emit(JoystickDirectionEvent(
          angle: pi / 2,
          isActive: true,
          intensity: 1.0,
        ));

        // Thrust
        eventBus.emit(ThrustEvent(true));
        for (int i = 0; i < 10; i++) {
          game.update(1 / 60);
        }

        // Ship should have moved to the right (positive x)
        expect(ship.position.x, greaterThan(400));
      },
    );
  });

  group('Ship wrap-around', () {
    testWithGame<FlameGame>(
      'ship wraps from right edge to left',
      FlameGame.new,
      (game) async {
        final ship = Ship()
          ..position = Vector2(game.size.x + 20, 300);
        await game.ensureAdd(ship);

        game.update(1 / 60);

        // Should have wrapped to left side
        expect(ship.position.x, lessThan(0));
      },
    );

    testWithGame<FlameGame>(
      'ship wraps from left edge to right',
      FlameGame.new,
      (game) async {
        final ship = Ship()
          ..position = Vector2(-20, 300);
        await game.ensureAdd(ship);

        game.update(1 / 60);

        // Should have wrapped to right side
        expect(ship.position.x, greaterThan(game.size.x));
      },
    );

    testWithGame<FlameGame>(
      'ship wraps from bottom to top',
      FlameGame.new,
      (game) async {
        final ship = Ship()
          ..position = Vector2(400, game.size.y + 20);
        await game.ensureAdd(ship);

        game.update(1 / 60);

        expect(ship.position.y, lessThan(0));
      },
    );

    testWithGame<FlameGame>(
      'ship wraps from top to bottom',
      FlameGame.new,
      (game) async {
        final ship = Ship()
          ..position = Vector2(400, -20);
        await game.ensureAdd(ship);

        game.update(1 / 60);

        expect(ship.position.y, greaterThan(game.size.y));
      },
    );
  });
}
