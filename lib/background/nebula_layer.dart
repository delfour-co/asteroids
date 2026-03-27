import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../core/event_bus.dart';
import '../enemies/ufo_events.dart';

/// Minimal wave-based overlay that shifts from transparent to a subtle
/// cyan tint as waves progress. Replaces the old NebulaLayer.
///
/// All paints are pre-allocated — nothing created in render().
class WaveOverlay extends PositionComponent with HasGameReference<FlameGame> {
  late final void Function(WaveStartedEvent) _waveListener;
  late final Paint _waveOverlayPaint;
  double _waveIntensity = 0.0;

  @override
  Future<void> onLoad() async {
    size = game.size;

    _waveOverlayPaint = Paint()
      ..color = const Color.fromRGBO(0, 0, 0, 0)
      ..style = PaintingStyle.fill;

    _waveListener = _onWaveStarted;
    eventBus.on<WaveStartedEvent>(_waveListener);
  }

  @override
  void onRemove() {
    eventBus.off<WaveStartedEvent>(_waveListener);
    super.onRemove();
  }

  void _onWaveStarted(WaveStartedEvent event) {
    // Gradually increase intensity over 50 waves (0.0 -> 1.0)
    _waveIntensity = (event.wave / 50.0).clamp(0.0, 1.0);
    // Shift overlay from transparent to slight cyan tint (max 0.03 opacity)
    final opacity = _waveIntensity * 0.03;
    _waveOverlayPaint.color = Color.fromRGBO(0, 255, 255, opacity);
  }

  @override
  void render(Canvas canvas) {
    if (_waveIntensity > 0) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _waveOverlayPaint);
    }
  }
}
