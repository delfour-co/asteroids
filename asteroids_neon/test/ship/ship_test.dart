import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/ship/ship.dart';

void main() {
  group('Ship', () {
    testWithGame<FlameGame>(
      'initializes with center anchor',
      FlameGame.new,
      (game) async {
        final ship = Ship();
        await game.ensureAdd(ship);

        expect(ship.anchor, Anchor.center);
      },
    );

    testWithGame<FlameGame>(
      'has correct size',
      FlameGame.new,
      (game) async {
        final ship = Ship();
        await game.ensureAdd(ship);

        expect(ship.size.x, 20.0); // 2 * halfWidth
        expect(ship.size.y, 30.0); // shipHeight
      },
    );

    testWithGame<FlameGame>(
      'renders without error',
      FlameGame.new,
      (game) async {
        final ship = Ship()..position = Vector2(100, 100);
        await game.ensureAdd(ship);

        // Trigger a game update + render cycle
        game.update(0.016);
        // If render throws, the test fails
      },
    );
  });
}
