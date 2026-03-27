import 'package:flame/components.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../enemies/ufo_events.dart';

/// Manages narrative fragment unlocks based on wave progression.
///
/// Added at game root (like FlashEffect), survives restarts.
/// Listens to WaveStartedEvent and unlocks fragments every N waves.
class FragmentManager extends Component {
  final Set<int> _unlockedIds = {};

  late final void Function(WaveStartedEvent) _waveListener;

  /// Load previously unlocked fragments from SharedPreferences.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(GameConfig.fragmentsKey);
    if (stored != null && stored.isNotEmpty) {
      for (final id in stored.split(',')) {
        final parsed = int.tryParse(id.trim());
        if (parsed != null) _unlockedIds.add(parsed);
      }
    }
  }

  @override
  Future<void> onLoad() async {
    _waveListener = _onWaveStarted;
    eventBus.on<WaveStartedEvent>(_waveListener);
  }

  @override
  void onRemove() {
    eventBus.off<WaveStartedEvent>(_waveListener);
    super.onRemove();
  }

  void _onWaveStarted(WaveStartedEvent event) {
    final wave = event.wave;
    if (wave < GameConfig.fragmentUnlockInterval) return;
    if (wave % GameConfig.fragmentUnlockInterval != 0) return;

    final fragmentIndex = (wave ~/ GameConfig.fragmentUnlockInterval) - 1;
    if (isUnlocked(fragmentIndex)) return;

    _unlockedIds.add(fragmentIndex);
    _saveToPrefs();
    eventBus.emit(FragmentUnlockedEvent(fragmentIndex));
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = _unlockedIds.toList()..sort();
    await prefs.setString(GameConfig.fragmentsKey, ids.join(','));
  }

  /// All currently unlocked fragment IDs, sorted.
  List<int> get unlockedIds {
    final ids = _unlockedIds.toList()..sort();
    return ids;
  }

  /// Whether a fragment with the given [id] is already unlocked.
  bool isUnlocked(int id) => _unlockedIds.contains(id);
}
