import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:asteroids_neon/core/arcade_events.dart';
import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/core/game_config.dart';
import 'package:asteroids_neon/enemies/ufo_events.dart';
import 'package:asteroids_neon/narration/fragment_manager.dart';

void main() {
  setUp(() {
    eventBus.clear();
    SharedPreferences.setMockInitialValues({});
  });

  group('FragmentManager', () {
    test('init loads empty state', () async {
      final manager = FragmentManager();
      await manager.init();

      expect(manager.unlockedIds, isEmpty);
      expect(manager.isUnlocked(0), false);
    });

    test('init loads previously saved fragments', () async {
      SharedPreferences.setMockInitialValues({
        GameConfig.fragmentsKey: '0,1,2',
      });

      final manager = FragmentManager();
      await manager.init();

      expect(manager.isUnlocked(0), true);
      expect(manager.isUnlocked(1), true);
      expect(manager.isUnlocked(2), true);
      expect(manager.isUnlocked(3), false);
    });

    test('unlockedIds returns sorted list', () async {
      SharedPreferences.setMockInitialValues({
        GameConfig.fragmentsKey: '2,0,1',
      });

      final manager = FragmentManager();
      await manager.init();

      expect(manager.unlockedIds, [0, 1, 2]);
    });

    testWithGame<FlameGame>(
      'unlocks fragment at wave 10',
      FlameGame.new,
      (game) async {
        final manager = FragmentManager();
        await manager.init();
        await game.ensureAdd(manager);

        FragmentUnlockedEvent? event;
        eventBus.on<FragmentUnlockedEvent>((e) => event = e);

        eventBus.emit(WaveStartedEvent(10));

        expect(event, isNotNull);
        expect(event!.fragmentIndex, 0); // wave 10 / 10 - 1 = 0
        expect(manager.isUnlocked(0), true);
      },
    );

    testWithGame<FlameGame>(
      'unlocks fragment at wave 20',
      FlameGame.new,
      (game) async {
        final manager = FragmentManager();
        await manager.init();
        await game.ensureAdd(manager);

        FragmentUnlockedEvent? event;
        eventBus.on<FragmentUnlockedEvent>((e) => event = e);

        eventBus.emit(WaveStartedEvent(20));

        expect(event, isNotNull);
        expect(event!.fragmentIndex, 1); // wave 20 / 10 - 1 = 1
      },
    );

    testWithGame<FlameGame>(
      'does not unlock on non-interval waves',
      FlameGame.new,
      (game) async {
        final manager = FragmentManager();
        await manager.init();
        await game.ensureAdd(manager);

        FragmentUnlockedEvent? event;
        eventBus.on<FragmentUnlockedEvent>((e) => event = e);

        eventBus.emit(WaveStartedEvent(5));
        eventBus.emit(WaveStartedEvent(15));

        expect(event, isNull);
        expect(manager.unlockedIds, isEmpty);
      },
    );

    testWithGame<FlameGame>(
      'does not re-unlock already unlocked fragment',
      FlameGame.new,
      (game) async {
        SharedPreferences.setMockInitialValues({
          GameConfig.fragmentsKey: '0',
        });

        final manager = FragmentManager();
        await manager.init();
        await game.ensureAdd(manager);

        FragmentUnlockedEvent? event;
        eventBus.on<FragmentUnlockedEvent>((e) => event = e);

        eventBus.emit(WaveStartedEvent(10));

        expect(event, isNull); // Already unlocked, no event
      },
    );

    testWithGame<FlameGame>(
      'ignores waves below unlock interval',
      FlameGame.new,
      (game) async {
        final manager = FragmentManager();
        await manager.init();
        await game.ensureAdd(manager);

        FragmentUnlockedEvent? event;
        eventBus.on<FragmentUnlockedEvent>((e) => event = e);

        eventBus.emit(WaveStartedEvent(1));
        eventBus.emit(WaveStartedEvent(5));
        eventBus.emit(WaveStartedEvent(9));

        expect(event, isNull);
      },
    );

    testWithGame<FlameGame>(
      'persists unlocked fragments to SharedPreferences',
      FlameGame.new,
      (game) async {
        final manager = FragmentManager();
        await manager.init();
        await game.ensureAdd(manager);

        eventBus.emit(WaveStartedEvent(10));

        // Wait for async save
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final prefs = await SharedPreferences.getInstance();
        final saved = prefs.getString(GameConfig.fragmentsKey);
        expect(saved, contains('0'));
      },
    );
  });
}
