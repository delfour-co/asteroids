import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/background/starfield.dart';

void main() {
  group('TronGrid', () {
    testWithGame<FlameGame>(
      'initializes and renders without error',
      FlameGame.new,
      (game) async {
        final grid = TronGrid();
        await game.ensureAdd(grid);

        expect(grid.isMounted, isTrue);

        // Trigger render cycle
        game.update(0.016);
      },
    );

    testWithGame<FlameGame>('size matches game size', FlameGame.new, (
      game,
    ) async {
      final grid = TronGrid();
      await game.ensureAdd(grid);

      expect(grid.size, game.size);
    });
  });
}
