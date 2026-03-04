import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../core/event_bus.dart';
import '../core/game_config.dart';

/// Event emitted when thrust state changes.
class ThrustEvent {
  final bool isThrusting;
  ThrustEvent(this.isThrusting);
}

/// Thrust button — bottom-right corner.
///
/// Filled semi-transparent cyan circle with arrow icon.
/// Uses DragCallbacks for reliable multi-touch.
class ThrustButton extends PositionComponent
    with HasGameReference, DragCallbacks {
  @override
  Future<void> onLoad() async {
    final gameSize = game.size;
    size = Vector2(90, 90);
    anchor = Anchor.center;
    position = Vector2(gameSize.x - 60, gameSize.y - 80);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    eventBus.emit(ThrustEvent(true));
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    eventBus.emit(ThrustEvent(false));
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    eventBus.emit(ThrustEvent(false));
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    const radius = 40.0;

    // Filled background
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0x3300FFFF),
    );
    // Outer ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = GameConfig.shipColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    // Arrow (triangle pointing up)
    final arrowPaint = Paint()
      ..color = GameConfig.shipColor
      ..style = PaintingStyle.fill;
    final arrow = Path()
      ..moveTo(size.x / 2, size.y / 2 - 16)
      ..lineTo(size.x / 2 - 12, size.y / 2 + 10)
      ..lineTo(size.x / 2 + 12, size.y / 2 + 10)
      ..close();
    canvas.drawPath(arrow, arrowPaint);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    return point.x >= -15 &&
        point.x <= size.x + 15 &&
        point.y >= -15 &&
        point.y <= size.y + 15;
  }
}
