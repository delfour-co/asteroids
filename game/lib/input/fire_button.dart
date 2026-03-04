import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../core/event_bus.dart';

/// Event emitted when fire state changes.
class FireEvent {
  final bool isFiring;
  FireEvent(this.isFiring);
}

/// Fire button — bottom-right, left of thrust button.
///
/// Filled semi-transparent magenta circle with crosshair icon.
/// Uses DragCallbacks for reliable multi-touch.
class FireButton extends PositionComponent
    with HasGameReference, DragCallbacks {
  static const Color _magenta = Color(0xFFFF00FF);

  @override
  Future<void> onLoad() async {
    final gameSize = game.size;
    size = Vector2(90, 90);
    anchor = Anchor.center;
    // Left of thrust button, same Y
    position = Vector2(gameSize.x - 160, gameSize.y - 80);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    eventBus.emit(FireEvent(true));
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    eventBus.emit(FireEvent(false));
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    eventBus.emit(FireEvent(false));
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    const radius = 40.0;

    // Filled background
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0x33FF00FF),
    );
    // Outer ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = _magenta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    // Scope reticle
    final reticlePaint = Paint()
      ..color = _magenta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    // Inner scope circle (large enough to be visible)
    canvas.drawCircle(center, 16, reticlePaint);
    // 4 tick marks pointing inward
    const cx = 45.0; // size.x / 2
    const cy = 45.0; // size.y / 2
    canvas.drawLine(const Offset(cx, cy - 26), const Offset(cx, cy - 16), reticlePaint);
    canvas.drawLine(const Offset(cx, cy + 16), const Offset(cx, cy + 26), reticlePaint);
    canvas.drawLine(const Offset(cx - 26, cy), const Offset(cx - 16, cy), reticlePaint);
    canvas.drawLine(const Offset(cx + 16, cy), const Offset(cx + 26, cy), reticlePaint);
    // Center dot
    canvas.drawCircle(center, 2.5, Paint()..color = _magenta);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    return point.x >= -15 &&
        point.x <= size.x + 15 &&
        point.y >= -15 &&
        point.y <= size.y + 15;
  }
}
