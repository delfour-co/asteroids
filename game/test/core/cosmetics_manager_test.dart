import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:asteroids_neon/core/cosmetics_manager.dart';
import 'package:asteroids_neon/core/game_config.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CosmeticsManager', () {
    test('init with defaults: cyan unlocked, selected index 0', () async {
      final manager = CosmeticsManager();
      await manager.init();

      expect(manager.unlockedIndices, [0]);
      expect(manager.selectedIndex, 0);
      expect(manager.selectedColor, GameConfig.shipColors[0]);
    });

    test('init loads previously unlocked colors', () async {
      SharedPreferences.setMockInitialValues({
        GameConfig.unlockedColorsKey: '0,1,2',
        GameConfig.selectedColorKey: 1,
      });

      final manager = CosmeticsManager();
      await manager.init();

      expect(manager.unlockedIndices, [0, 1, 2]);
      expect(manager.selectedIndex, 1);
      expect(manager.selectedColor, GameConfig.shipColors[1]);
    });

    test('isUnlocked returns correct values', () async {
      SharedPreferences.setMockInitialValues({
        GameConfig.unlockedColorsKey: '0,2',
      });

      final manager = CosmeticsManager();
      await manager.init();

      expect(manager.isUnlocked(0), true);
      expect(manager.isUnlocked(1), false);
      expect(manager.isUnlocked(2), true);
    });

    test('unlock adds new color and persists', () async {
      final manager = CosmeticsManager();
      await manager.init();

      manager.unlock(1);

      expect(manager.isUnlocked(1), true);
      expect(manager.unlockedIndices, [0, 1]);
    });

    test('unlock ignores already unlocked index', () async {
      final manager = CosmeticsManager();
      await manager.init();

      manager.unlock(0); // Already unlocked

      expect(manager.unlockedIndices, [0]);
    });

    test('unlock ignores invalid index', () async {
      final manager = CosmeticsManager();
      await manager.init();

      manager.unlock(-1);
      manager.unlock(100);

      expect(manager.unlockedIndices, [0]);
    });

    test('select changes selected color', () async {
      final manager = CosmeticsManager();
      await manager.init();
      manager.unlock(1);

      manager.select(1);

      expect(manager.selectedIndex, 1);
      expect(manager.selectedColor, GameConfig.shipColors[1]);
    });

    test('select ignores locked color', () async {
      final manager = CosmeticsManager();
      await manager.init();

      manager.select(2); // Not unlocked

      expect(manager.selectedIndex, 0); // Unchanged
    });

    test('checkWaveUnlocks unlocks correct colors', () async {
      final manager = CosmeticsManager();
      await manager.init();

      // Wave 10 unlocks index 1
      manager.checkWaveUnlocks(10);
      expect(manager.isUnlocked(1), true);

      // Wave 20 unlocks index 2
      manager.checkWaveUnlocks(20);
      expect(manager.isUnlocked(2), true);
    });

    test('checkWaveUnlocks with high wave unlocks multiple colors', () async {
      final manager = CosmeticsManager();
      await manager.init();

      manager.checkWaveUnlocks(50);

      // Colors within shipColors range should be unlocked
      for (int i = 0; i < GameConfig.cosmeticUnlockWaves.length; i++) {
        final colorIndex = i + 1;
        if (colorIndex < GameConfig.shipColors.length) {
          expect(manager.isUnlocked(colorIndex), true);
        }
      }
    });

    test('init resets to 0 if selected color is locked', () async {
      SharedPreferences.setMockInitialValues({
        GameConfig.unlockedColorsKey: '0',
        GameConfig.selectedColorKey: 3, // Not unlocked
      });

      final manager = CosmeticsManager();
      await manager.init();

      expect(manager.selectedIndex, 0);
    });

    test('persists selection to SharedPreferences', () async {
      final manager = CosmeticsManager();
      await manager.init();
      manager.unlock(2);

      manager.select(2);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(GameConfig.selectedColorKey), 2);
    });
  });
}
