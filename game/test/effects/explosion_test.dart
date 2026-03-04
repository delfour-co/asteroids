import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/effects/explosion.dart';

void main() {
  group('Explosion', () {
    testWithGame<FlameGame>(
      'removes itself after duration',
      FlameGame.new,
      (game) async {
        final explosion = Explosion(
          color: const Color(0xFFFF00FF),
          particleCount: 8,
          maxSpeed: 100,
          duration: 0.5,
        )..position = Vector2(200, 200);
        await game.ensureAdd(explosion);

        // Advance past duration
        for (int i = 0; i < 40; i++) {
          game.update(1 / 60);
        }

        expect(explosion.isMounted, false);
      },
    );

    testWithGame<FlameGame>(
      'stays mounted before duration expires',
      FlameGame.new,
      (game) async {
        final explosion = Explosion(
          color: const Color(0xFFFF00FF),
          particleCount: 8,
          maxSpeed: 100,
          duration: 1.0,
        )..position = Vector2(200, 200);
        await game.ensureAdd(explosion);

        // Advance less than duration
        for (int i = 0; i < 30; i++) {
          game.update(1 / 60);
        }

        expect(explosion.isMounted, true);
      },
    );

    testWithGame<FlameGame>(
      'renders without error',
      FlameGame.new,
      (game) async {
        final explosion = Explosion(
          color: const Color(0xFF00FFFF),
          particleCount: 12,
          maxSpeed: 150,
        )..position = Vector2(200, 200);
        await game.ensureAdd(explosion);

        game.update(1 / 60);
        // No throw = success
      },
    );
  });
}
