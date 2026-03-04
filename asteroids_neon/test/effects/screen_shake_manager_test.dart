import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/arcade_events.dart';
import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/core/game_config.dart';
import 'package:asteroids_neon/effects/screen_shake_manager.dart';

void main() {
  setUp(() {
    eventBus.clear();
  });

  group('ScreenShakeManager', () {
    testWithGame<FlameGame>(
      'responds to ScreenShakeEvent by offsetting viewfinder',
      FlameGame.new,
      (game) async {
        final manager = ScreenShakeManager();
        await game.ensureAdd(manager);

        final centerX = game.size.x / 2;
        final centerY = game.size.y / 2;

        // Emit a shake event
        eventBus.emit(ScreenShakeEvent(GameConfig.shakeIntensityLarge));

        // Update to apply shake
        game.update(0.01);

        final vfPos = game.camera.viewfinder.position;
        // The viewfinder should have been displaced from center
        // (with a large intensity, it's extremely unlikely to land exactly on center)
        final displaced = (vfPos.x - centerX).abs() > 0.001 ||
            (vfPos.y - centerY).abs() > 0.001;
        expect(displaced, true);
      },
    );

    testWithGame<FlameGame>(
      'resets viewfinder position after shake duration',
      FlameGame.new,
      (game) async {
        final manager = ScreenShakeManager();
        await game.ensureAdd(manager);

        final centerX = game.size.x / 2;
        final centerY = game.size.y / 2;

        eventBus.emit(ScreenShakeEvent(GameConfig.shakeIntensityMedium));

        // Advance past the shake duration
        game.update(GameConfig.shakeDuration + 0.1);

        final vfPos = game.camera.viewfinder.position;
        expect(vfPos.x, closeTo(centerX, 0.01));
        expect(vfPos.y, closeTo(centerY, 0.01));
      },
    );

    testWithGame<FlameGame>(
      'stronger shake overrides weaker one',
      FlameGame.new,
      (game) async {
        final manager = ScreenShakeManager();
        await game.ensureAdd(manager);

        // Start a weak shake
        eventBus.emit(ScreenShakeEvent(GameConfig.shakeIntensitySmall));
        game.update(0.05);

        // Override with a stronger shake
        eventBus.emit(ScreenShakeEvent(GameConfig.shakeIntensityBoss));
        game.update(0.01);

        // The manager should still be shaking (timer was reset)
        final centerX = game.size.x / 2;
        final centerY = game.size.y / 2;
        final vfPos = game.camera.viewfinder.position;
        final displaced = (vfPos.x - centerX).abs() > 0.001 ||
            (vfPos.y - centerY).abs() > 0.001;
        expect(displaced, true);
      },
    );
  });
}
