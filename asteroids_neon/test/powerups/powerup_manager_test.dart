import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/core/game_config.dart';
import 'package:asteroids_neon/core/game_state.dart';
import 'package:asteroids_neon/powerups/powerup.dart';
import 'package:asteroids_neon/powerups/powerup_manager.dart';

void main() {
  setUp(() {
    eventBus.clear();
    GameConfig.enemySpeedMultiplier = 1.0;
  });

  group('PowerUpManager', () {
    testWithGame<FlameGame>(
      'activates shield on collection',
      FlameGame.new,
      (game) async {
        final manager = PowerUpManager();
        await game.ensureAdd(manager);

        PowerUpActiveEvent? event;
        eventBus.on<PowerUpActiveEvent>((e) => event = e);

        eventBus.emit(PowerUpCollectedEvent(PowerUpType.shield));

        expect(event, isNotNull);
        expect(event!.type, PowerUpType.shield);
        expect(event!.active, true);
        expect(manager.isActive(PowerUpType.shield), true);
      },
    );

    testWithGame<FlameGame>(
      'activates slow-mo and changes speed multiplier',
      FlameGame.new,
      (game) async {
        final manager = PowerUpManager();
        await game.ensureAdd(manager);

        eventBus.emit(PowerUpCollectedEvent(PowerUpType.slowMo));

        expect(GameConfig.enemySpeedMultiplier, 0.5);
        expect(manager.isActive(PowerUpType.slowMo), true);
      },
    );

    testWithGame<FlameGame>(
      'deactivates effect after duration expires',
      FlameGame.new,
      (game) async {
        final manager = PowerUpManager();
        await game.ensureAdd(manager);

        eventBus.emit(PowerUpCollectedEvent(PowerUpType.shield));
        expect(manager.isActive(PowerUpType.shield), true);

        // Advance past upgrade duration (12s)
        for (int i = 0; i < 800; i++) {
          game.update(1 / 60);
        }

        expect(manager.isActive(PowerUpType.shield), false);
      },
    );

    testWithGame<FlameGame>(
      'slow-mo resets speed multiplier on expiration',
      FlameGame.new,
      (game) async {
        final manager = PowerUpManager();
        await game.ensureAdd(manager);

        eventBus.emit(PowerUpCollectedEvent(PowerUpType.slowMo));
        expect(GameConfig.enemySpeedMultiplier, 0.5);

        // Advance past duration
        for (int i = 0; i < 800; i++) {
          game.update(1 / 60);
        }

        expect(GameConfig.enemySpeedMultiplier, 1.0);
      },
    );

    testWithGame<FlameGame>(
      'clears all effects on game over',
      FlameGame.new,
      (game) async {
        final manager = PowerUpManager();
        await game.ensureAdd(manager);

        eventBus.emit(PowerUpCollectedEvent(PowerUpType.shield));
        eventBus.emit(PowerUpCollectedEvent(PowerUpType.slowMo));

        eventBus.emit(GameOverEvent());

        expect(manager.isActive(PowerUpType.shield), false);
        expect(manager.isActive(PowerUpType.slowMo), false);
        expect(GameConfig.enemySpeedMultiplier, 1.0);
      },
    );

    testWithGame<FlameGame>(
      'emits deactivation events on game over',
      FlameGame.new,
      (game) async {
        final manager = PowerUpManager();
        await game.ensureAdd(manager);

        eventBus.emit(PowerUpCollectedEvent(PowerUpType.multiShot));

        final deactivations = <PowerUpType>[];
        eventBus.on<PowerUpActiveEvent>((e) {
          if (!e.active) deactivations.add(e.type);
        });

        eventBus.emit(GameOverEvent());

        expect(deactivations, contains(PowerUpType.multiShot));
      },
    );
  });
}
