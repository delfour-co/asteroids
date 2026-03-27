import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Very subtle CRT scanlines overlay for Tron aesthetic.
///
/// Renders thin horizontal lines across the entire screen at low opacity.
/// Priority 150 to be above game but below UI.
class ScanlinesOverlay extends PositionComponent
    with HasGameReference<FlameGame> {
  late final Paint _linePaint;

  @override
  Future<void> onLoad() async {
    size = game.size;
    priority = 150; // Above game, below UI
    _linePaint = Paint()..color = const Color.fromARGB(8, 0, 0, 0);
  }

  @override
  void render(Canvas canvas) {
    // Draw subtle dark scanlines every 2 pixels
    for (double y = 0; y < size.y; y += 2) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), _linePaint);
    }
  }
}
