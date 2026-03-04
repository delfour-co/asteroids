import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/game_config.dart';
import 'package:asteroids_neon/hud/wave_announcement.dart';

void main() {
  group('WaveAnnouncement', () {
    testWithGame<FlameGame>(
      'shows correct text for wave number',
      FlameGame.new,
      (game) async {
        final announcement = WaveAnnouncement(wave: 5);
        await game.ensureAdd(announcement);

        expect(announcement.text, 'WAVE 5');
      },
    );

    testWithGame<FlameGame>(
      'shows correct text for wave 1',
      FlameGame.new,
      (game) async {
        final announcement = WaveAnnouncement(wave: 1);
        await game.ensureAdd(announcement);

        expect(announcement.text, 'WAVE 1');
      },
    );

    testWithGame<FlameGame>(
      'stays mounted during total duration',
      FlameGame.new,
      (game) async {
        final announcement = WaveAnnouncement(wave: 3);
        await game.ensureAdd(announcement);

        final totalDuration = GameConfig.waveAnnounceFadeIn +
            GameConfig.waveAnnounceHold +
            GameConfig.waveAnnounceFadeOut;

        // Advance to just before total duration
        game.update(totalDuration - 0.1);

        expect(announcement.isMounted, true);
      },
    );

    testWithGame<FlameGame>(
      'auto-removes after total duration',
      FlameGame.new,
      (game) async {
        final announcement = WaveAnnouncement(wave: 2);
        await game.ensureAdd(announcement);

        final totalDuration = GameConfig.waveAnnounceFadeIn +
            GameConfig.waveAnnounceHold +
            GameConfig.waveAnnounceFadeOut;

        // Advance past total duration
        game.update(totalDuration + 0.1);

        // removeFromParent is deferred; process removal
        game.update(0);

        expect(announcement.isMounted, false);
      },
    );

    testWithGame<FlameGame>(
      'positions itself at screen center',
      FlameGame.new,
      (game) async {
        final announcement = WaveAnnouncement(wave: 1);
        await game.ensureAdd(announcement);

        expect(announcement.position.x, closeTo(game.size.x / 2, 0.01));
        expect(announcement.position.y, closeTo(game.size.y / 2, 0.01));
      },
    );
  });
}
