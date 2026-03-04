import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/core/game_state.dart';
import 'package:asteroids_neon/input/fire_button.dart';
import 'package:asteroids_neon/projectiles/projectile.dart';
import 'package:asteroids_neon/projectiles/projectile_manager.dart';

Future<void> _flushAsync(FlameGame game) async {
  await Future<void>.delayed(Duration.zero);
  game.update(1 / 60);
  await Future<void>.delayed(Duration.zero);
  game.update(1 / 60);
}

void main() {
  setUp(() {
    eventBus.clear();
  });

  group('ProjectileManager', () {
    testWithGame<FlameGame>(
      'spawns projectile when firing',
      FlameGame.new,
      (game) async {
        final container = Component();
        await game.ensureAdd(container);
        final manager = ProjectileManager();
        await container.ensureAdd(manager);

        eventBus.emit(ShipFireRequestEvent(Vector2(200, 200), 0));
        eventBus.emit(FireEvent(true));

        game.update(1 / 60);
        await _flushAsync(game);

        final projectiles = container.children.whereType<Projectile>();
        expect(projectiles.length, 1);
      },
    );

    testWithGame<FlameGame>(
      'does not fire without ship position',
      FlameGame.new,
      (game) async {
        final container = Component();
        await game.ensureAdd(container);
        final manager = ProjectileManager();
        await container.ensureAdd(manager);

        eventBus.emit(FireEvent(true));
        game.update(1 / 60);
        await _flushAsync(game);

        final projectiles = container.children.whereType<Projectile>();
        expect(projectiles.length, 0);
      },
    );

    testWithGame<FlameGame>(
      'respects fire rate cooldown',
      FlameGame.new,
      (game) async {
        final container = Component();
        await game.ensureAdd(container);
        final manager = ProjectileManager();
        await container.ensureAdd(manager);

        eventBus.emit(ShipFireRequestEvent(Vector2(200, 200), 0));
        eventBus.emit(FireEvent(true));

        game.update(1 / 60); // Fire first
        game.update(1 / 60); // Too soon
        await _flushAsync(game);

        final projectiles = container.children.whereType<Projectile>();
        expect(projectiles.length, 1);
      },
    );

    testWithGame<FlameGame>(
      'fires again after cooldown expires',
      FlameGame.new,
      (game) async {
        final container = Component();
        await game.ensureAdd(container);
        final manager = ProjectileManager();
        await container.ensureAdd(manager);

        eventBus.emit(ShipFireRequestEvent(Vector2(200, 200), 0));
        eventBus.emit(FireEvent(true));

        game.update(1 / 60); // Fire first
        await _flushAsync(game);
        game.update(0.2); // Wait past cooldown
        await _flushAsync(game);

        final projectiles = container.children.whereType<Projectile>();
        expect(projectiles.length, 2);
      },
    );

    testWithGame<FlameGame>(
      'stops firing after game over',
      FlameGame.new,
      (game) async {
        final container = Component();
        await game.ensureAdd(container);
        final manager = ProjectileManager();
        await container.ensureAdd(manager);

        eventBus.emit(ShipFireRequestEvent(Vector2(200, 200), 0));
        eventBus.emit(FireEvent(true));
        eventBus.emit(GameOverEvent());

        game.update(1 / 60);
        await _flushAsync(game);

        final projectiles = container.children.whereType<Projectile>();
        expect(projectiles.length, 0);
      },
    );

    testWithGame<FlameGame>(
      'stops firing when fire event is false',
      FlameGame.new,
      (game) async {
        final container = Component();
        await game.ensureAdd(container);
        final manager = ProjectileManager();
        await container.ensureAdd(manager);

        eventBus.emit(ShipFireRequestEvent(Vector2(200, 200), 0));
        eventBus.emit(FireEvent(true));
        game.update(1 / 60); // Fire once
        await _flushAsync(game);

        eventBus.emit(FireEvent(false));
        game.update(0.2);
        await _flushAsync(game);

        final projectiles = container.children.whereType<Projectile>();
        expect(projectiles.length, 1);
      },
    );
  });
}
