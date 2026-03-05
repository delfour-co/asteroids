import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../enemies/ufo_events.dart';

/// Expanding neon ring effect triggered at each wave transition (wave 2+).
///
/// Added at the game root (like FlashEffect) so it survives restarts.
class WaveRingEffect extends PositionComponent
    with HasGameReference<FlameGame> {
  double _timer = 0;
  bool _active = false;

  late final void Function(WaveStartedEvent) _waveListener;

  // Pre-allocated paints
  late final Paint _ringPaint;
  late final Paint _glowPaint;

  @override
  Future<void> onLoad() async {
    priority = 150;

    _ringPaint = Paint()
      ..color = GameConfig.waveRingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    _glowPaint = Paint()
      ..color = GameConfig.waveRingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    _waveListener = _onWaveStarted;
    eventBus.on<WaveStartedEvent>(_waveListener);
  }

  @override
  void onRemove() {
    eventBus.off<WaveStartedEvent>(_waveListener);
    super.onRemove();
  }

  void _onWaveStarted(WaveStartedEvent event) {
    // Skip wave 1 (during countdown)
    if (event.wave <= 1) return;
    _active = true;
    _timer = 0;
    eventBus.emit(ScreenShakeEvent(GameConfig.waveRingShakeIntensity));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_active) return;

    _timer += dt;
    if (_timer >= GameConfig.waveRingDuration) {
      _active = false;
      _timer = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_active) return;

    final gameSize = game.size;
    final cx = gameSize.x / 2;
    final cy = gameSize.y / 2;
    final maxRadius = sqrt(cx * cx + cy * cy);

    final progress = (_timer / GameConfig.waveRingDuration).clamp(0.0, 1.0);
    // Ease-out: 1 - (1 - t)^2
    final eased = 1.0 - (1.0 - progress) * (1.0 - progress);
    final radius = eased * maxRadius;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    final center = Offset(cx, cy);

    _glowPaint.color = GameConfig.waveRingColor.withValues(alpha: opacity * 0.4);
    canvas.drawCircle(center, radius, _glowPaint);

    _ringPaint.color = GameConfig.waveRingColor.withValues(alpha: opacity);
    canvas.drawCircle(center, radius, _ringPaint);
  }
}
