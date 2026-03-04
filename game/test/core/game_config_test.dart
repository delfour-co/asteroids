import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/core/game_config.dart';

void main() {
  group('GameConfig', () {
    test('ship constants are accessible', () {
      expect(GameConfig.shipMaxSpeed, 300.0);
      expect(GameConfig.startingLives, 3);
      expect(GameConfig.extraLifeScore, 15000);
    });

    test('scoring constants are accessible', () {
      expect(GameConfig.largeAsteroidPoints, 20);
      expect(GameConfig.mediumAsteroidPoints, 50);
      expect(GameConfig.smallAsteroidPoints, 100);
      expect(GameConfig.ufoPoints, 500);
    });

    test('visual constants are accessible', () {
      expect(GameConfig.shipColor, const Color(0xFF00FFFF));
      expect(GameConfig.backgroundColor, const Color(0xFF000011));
      expect(GameConfig.glowRadius, 10.0);
      expect(GameConfig.glowOpacity, 0.6);
    });

    test('starfield constants are accessible', () {
      expect(GameConfig.starCount, 150);
      expect(GameConfig.starMinSize, greaterThan(0));
      expect(GameConfig.starMaxSize, greaterThan(GameConfig.starMinSize));
      expect(GameConfig.starMinOpacity, greaterThanOrEqualTo(0));
      expect(GameConfig.starMaxOpacity, lessThanOrEqualTo(1.0));
    });
  });
}
