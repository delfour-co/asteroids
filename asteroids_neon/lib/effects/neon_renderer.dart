import 'dart:ui';

/// Reusable neon glow rendering utility.
///
/// Uses MaskFilter.blur + double draw: first a blurred halo,
/// then a solid core on top for the neon vector look.
class NeonRenderer {
  /// Create a pair of [Paint] objects for neon glow rendering.
  ///
  /// Returns a record (glowPaint, solidPaint).
  /// Pre-allocate these as class properties — NEVER create in render().
  static ({Paint glow, Paint solid}) createNeonPaints({
    required Color color,
    double glowRadius = 10.0,
    double glowOpacity = 0.6,
    double strokeWidth = 2.0,
  }) {
    final glowPaint = Paint()
      ..color = color.withValues(alpha: glowOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4.0
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius);

    final solidPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    return (glow: glowPaint, solid: solidPaint);
  }

  /// Draw a path with neon glow effect.
  ///
  /// Call within render() after canvas.save().
  static void drawNeonPath(
    Canvas canvas,
    Path path,
    Paint glowPaint,
    Paint solidPaint,
  ) {
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, solidPaint);
  }
}
