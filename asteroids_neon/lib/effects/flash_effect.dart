import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';

/// Full-screen white flash that fades out.
///
/// Triggered by BossFlashEvent. Added at the game root.
class FlashEffect extends PositionComponent with HasGameReference<FlameGame> {
  double _timer = 0;
  bool _active = false;

  late final void Function(BossFlashEvent) _flashListener;

  @override
  Future<void> onLoad() async {
    _flashListener = (_) => _trigger();
    eventBus.on<BossFlashEvent>(_flashListener);
    // Render on top of everything
    priority = 1000;
  }

  @override
  void onRemove() {
    eventBus.off<BossFlashEvent>(_flashListener);
    super.onRemove();
  }

  void _trigger() {
    _active = true;
    _timer = GameConfig.flashDuration;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_active) {
      _timer -= dt;
      if (_timer <= 0) {
        _active = false;
        _timer = 0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_active) return;
    final opacity = (_timer / GameConfig.flashDuration).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = Color.fromARGB((opacity * 200).toInt(), 255, 255, 255);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, game.size.x, game.size.y),
      paint,
    );
  }
}
