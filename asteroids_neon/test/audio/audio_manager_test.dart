import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';

import 'package:asteroids_neon/audio/audio_manager.dart';
import 'package:asteroids_neon/audio/audio_config.dart';
import 'package:asteroids_neon/audio/audio_events.dart';
import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/input/fire_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    eventBus.clear();
  });

  group('AudioManager', () {
    testWithGame<FlameGame>(
      'initializes with mute=false by default',
      FlameGame.new,
      (game) async {
        final manager = AudioManager();
        await game.ensureAdd(manager);

        expect(manager.isMuted, false);
      },
    );

    testWithGame<FlameGame>(
      'initializes with saved mute preference',
      FlameGame.new,
      (game) async {
        SharedPreferences.setMockInitialValues({AudioConfig.muteKey: true});

        final manager = AudioManager();
        await game.ensureAdd(manager);

        expect(manager.isMuted, true);
      },
    );

    testWithGame<FlameGame>(
      'toggles mute on MuteToggleEvent',
      FlameGame.new,
      (game) async {
        final manager = AudioManager();
        await game.ensureAdd(manager);

        expect(manager.isMuted, false);

        eventBus.emit(MuteToggleEvent());
        expect(manager.isMuted, true);

        eventBus.emit(MuteToggleEvent());
        expect(manager.isMuted, false);
      },
    );

    testWithGame<FlameGame>(
      'emits MuteChangedEvent on toggle',
      FlameGame.new,
      (game) async {
        final manager = AudioManager();
        await game.ensureAdd(manager);

        bool? received;
        eventBus.on<MuteChangedEvent>((e) => received = e.isMuted);

        eventBus.emit(MuteToggleEvent());
        expect(received, true);

        eventBus.emit(MuteToggleEvent());
        expect(received, false);
      },
    );

    testWithGame<FlameGame>(
      'persists mute state to SharedPreferences',
      FlameGame.new,
      (game) async {
        final manager = AudioManager();
        await game.ensureAdd(manager);

        eventBus.emit(MuteToggleEvent());

        // Give async SharedPreferences save time to complete
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool(AudioConfig.muteKey), true);
      },
    );

    testWithGame<FlameGame>(
      'fire cooldown prevents rapid fire SFX',
      FlameGame.new,
      (game) async {
        final manager = AudioManager();
        await game.ensureAdd(manager);

        // First fire should go through (cooldown starts)
        eventBus.emit(FireEvent(true));

        // Immediately fire again — should be blocked by cooldown
        // We just verify no crash; actual audio is try/caught
        eventBus.emit(FireEvent(true));

        // Advance past cooldown
        game.update(0.1);

        // Should work again
        eventBus.emit(FireEvent(true));
      },
    );

    testWithGame<FlameGame>(
      'fire event with isFiring=false is ignored',
      FlameGame.new,
      (game) async {
        final manager = AudioManager();
        await game.ensureAdd(manager);

        // Should not crash or play anything
        eventBus.emit(FireEvent(false));
      },
    );

    testWithGame<FlameGame>(
      'cleans up listeners on remove',
      FlameGame.new,
      (game) async {
        final manager = AudioManager();
        await game.ensureAdd(manager);

        manager.removeFromParent();
        game.update(0); // process removal

        // After removal, emitting events should not crash
        eventBus.emit(MuteToggleEvent());
        eventBus.emit(FireEvent(true));

        // Mute state should not have changed since listener was removed
        expect(manager.isMuted, false);
      },
    );
  });
}
