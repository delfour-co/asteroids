import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import 'game_config.dart';

/// Manages unlocked ship colors and the currently selected color.
///
/// Plain Dart class — NOT a Component. Call [init] once at startup.
class CosmeticsManager {
  List<int> _unlockedIndices = [0]; // Cyan always unlocked
  int _selectedIndex = 0;

  List<int> get unlockedIndices => List.unmodifiable(_unlockedIndices);
  int get selectedIndex => _selectedIndex;
  Color get selectedColor => GameConfig.shipColors[_selectedIndex];

  /// Load persisted state from SharedPreferences.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Unlocked colors — comma-separated indices (default: "0")
    final raw = prefs.getString(GameConfig.unlockedColorsKey) ?? '0';
    _unlockedIndices = raw
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();
    if (_unlockedIndices.isEmpty) {
      _unlockedIndices = [0];
    }

    // Selected color index
    _selectedIndex = prefs.getInt(GameConfig.selectedColorKey) ?? 0;
    if (!_unlockedIndices.contains(_selectedIndex)) {
      _selectedIndex = 0;
    }
  }

  /// Whether the color at [index] is unlocked.
  bool isUnlocked(int index) => _unlockedIndices.contains(index);

  /// Unlock a color by index and persist.
  void unlock(int index) {
    if (index < 0 || index >= GameConfig.shipColors.length) return;
    if (_unlockedIndices.contains(index)) return;
    _unlockedIndices.add(index);
    _unlockedIndices.sort();
    _saveUnlocked();
  }

  /// Select a color by index and persist.
  void select(int index) {
    if (!isUnlocked(index)) return;
    _selectedIndex = index;
    _saveSelected();
  }

  /// Check wave milestones and unlock corresponding colors.
  ///
  /// [GameConfig.cosmeticUnlockWaves] maps wave thresholds to color index+1:
  /// wave 10 -> index 1, wave 20 -> index 2, etc.
  void checkWaveUnlocks(int wave) {
    for (int i = 0; i < GameConfig.cosmeticUnlockWaves.length; i++) {
      if (wave >= GameConfig.cosmeticUnlockWaves[i]) {
        unlock(i + 1);
      }
    }
  }

  Future<void> _saveUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      GameConfig.unlockedColorsKey,
      _unlockedIndices.join(','),
    );
  }

  Future<void> _saveSelected() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(GameConfig.selectedColorKey, _selectedIndex);
  }
}
