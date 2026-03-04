import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/powerups/powerup.dart';

void main() {
  setUp(() {
    eventBus.clear();
  });

  group('PowerUp', () {
    test('initializes with center anchor', () {
      final powerUp = PowerUp(type: PowerUpType.shield);
      expect(powerUp.anchor, Anchor.center);
    });

    test('has correct size', () {
      final powerUp = PowerUp(type: PowerUpType.shield);
      expect(powerUp.size.x, 28); // radius 14 * 2
      expect(powerUp.size.y, 28);
    });

    testWithGame<FlameGame>(
      'removes itself after lifetime',
      FlameGame.new,
      (game) async {
        final powerUp = PowerUp(type: PowerUpType.multiShot)
          ..position = Vector2(200, 200);
        await game.ensureAdd(powerUp);

        // Advance past 8 second lifetime
        for (int i = 0; i < 500; i++) {
          game.update(1 / 60);
        }

        expect(powerUp.isMounted, false);
      },
    );

    testWithGame<FlameGame>(
      'renders without error for each type',
      FlameGame.new,
      (game) async {
        for (final type in PowerUpType.values) {
          final powerUp = PowerUp(type: type)
            ..position = Vector2(200, 200);
          await game.ensureAdd(powerUp);
          game.update(1 / 60);
        }
      },
    );
  });

  group('PowerUpType', () {
    test('has three types', () {
      expect(PowerUpType.values.length, 3);
    });

    test('each type has a color', () {
      for (final type in PowerUpType.values) {
        expect(type.color, isNotNull);
      }
    });

    test('each type has a label', () {
      expect(PowerUpType.shield.label, 'S');
      expect(PowerUpType.multiShot.label, 'M');
      expect(PowerUpType.slowMo.label, '~');
    });
  });
}
