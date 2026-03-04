import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';

/// Shakes the camera viewfinder on ScreenShakeEvent.
///
/// Added at the game root so it survives restarts.
class ScreenShakeManager extends Component with HasGameReference<FlameGame> {
  static final Random _random = Random();

  double _timer = 0;
  double _intensity = 0;

  late final void Function(ScreenShakeEvent) _shakeListener;

  @override
  Future<void> onLoad() async {
    _shakeListener = _onShake;
    eventBus.on<ScreenShakeEvent>(_shakeListener);
  }

  @override
  void onRemove() {
    eventBus.off<ScreenShakeEvent>(_shakeListener);
    super.onRemove();
  }

  void _onShake(ScreenShakeEvent event) {
    // Take the strongest shake if multiple overlap
    if (event.intensity > _intensity || _timer <= 0) {
      _intensity = event.intensity;
      _timer = GameConfig.shakeDuration;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    final viewfinder = game.camera.viewfinder;

    if (_timer > 0) {
      _timer -= dt;
      final progress = (_timer / GameConfig.shakeDuration).clamp(0.0, 1.0);
      final currentIntensity = _intensity * progress;

      final offsetX = (_random.nextDouble() - 0.5) * 2 * currentIntensity;
      final offsetY = (_random.nextDouble() - 0.5) * 2 * currentIntensity;

      viewfinder.position = Vector2(
        game.size.x / 2 + offsetX,
        game.size.y / 2 + offsetY,
      );

      if (_timer <= 0) {
        _intensity = 0;
        viewfinder.position = Vector2(game.size.x / 2, game.size.y / 2);
      }
    }
  }
}
