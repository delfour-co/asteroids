import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../core/event_bus.dart';
import 'package:d4_dark_ds/d4_dark_ds.dart';

import '../hud/title_screen.dart';
import '../core/arcade_events.dart';

/// A single sparse star dot.
class _StarDot {
  final double x;
  final double y;
  final double radius;
  final Paint paint;

  _StarDot({
    required this.x,
    required this.y,
    required this.radius,
    required this.paint,
  });
}

/// A grid line that can interpolate between perspective and flat positions.
class _AnimLine {
  // Perspective mode endpoints
  final Offset perspStart;
  final Offset perspEnd;
  final double perspOpacity;

  // Flat mode endpoints
  final Offset flatStart;
  final Offset flatEnd;
  final double flatOpacity;

  _AnimLine({
    required this.perspStart,
    required this.perspEnd,
    required this.perspOpacity,
    required this.flatStart,
    required this.flatEnd,
    required this.flatOpacity,
  });

  Offset lerpStart(double t) => Offset.lerp(perspStart, flatStart, t)!;
  Offset lerpEnd(double t) => Offset.lerp(perspEnd, flatEnd, t)!;
  double lerpOpacity(double t) =>
      perspOpacity + (flatOpacity - perspOpacity) * t;
}

/// Tron-style grid background with animated transition between:
/// - **Menu mode**: perspective grid with horizon line
/// - **Game mode**: flat top-down orthogonal grid
class TronGrid extends PositionComponent with HasGameReference<FlameGame> {
  // 0.0 = perspective (menu), 1.0 = flat (game)
  double _transition = 0.0;
  double _targetTransition = 0.0;
  static const double _transitionSpeed = 1.2; // seconds for full transition

  final List<_StarDot> _stars = [];
  final List<_AnimLine> _hLines = [];
  final List<_AnimLine> _vLines = [];

  late final Paint _bgPaint;
  late final Paint _linePaint;
  late final Paint _horizonGlowPaint;
  late final Paint _horizonLinePaint;

  double _horizonY = 0;

  late final void Function(StartGameEvent) _startListener;
  late final void Function(ReturnToMenuEvent) _menuListener;

  @override
  Future<void> onLoad() async {
    size = game.size;

    final w = size.x;
    final h = size.y;
    final rng = Random(77);

    _horizonY = h * 0.42;

    _bgPaint = Paint()..color = D4DsColors.background;
    _linePaint = Paint()..strokeWidth = 0.8;

    _horizonGlowPaint = Paint()
      ..color = const Color.fromRGBO(0, 255, 255, 0.25)
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    _horizonLinePaint = Paint()
      ..color = const Color.fromRGBO(0, 255, 255, 0.50)
      ..strokeWidth = 1.0;

    _buildHLines(w, h);
    _buildVLines(w, h);
    _buildStars(w, h, rng);

    _startListener = (_) => _targetTransition = 1.0;
    _menuListener = (_) => _targetTransition = 0.0;
    eventBus.on<StartGameEvent>(_startListener);
    eventBus.on<ReturnToMenuEvent>(_menuListener);
  }

  @override
  void onRemove() {
    eventBus.off<StartGameEvent>(_startListener);
    eventBus.off<ReturnToMenuEvent>(_menuListener);
    super.onRemove();
  }

  // ── Build horizontal lines (same count, different positions) ──

  void _buildHLines(double w, double h) {
    const count = 16;
    final groundHeight = h - _horizonY;
    const flatSpacing = 60.0;

    for (int i = 0; i < count; i++) {
      // Perspective: quadratic spacing from horizon downward
      final t = (i + 1) / count;
      final perspY = _horizonY + (t * t) * groundHeight;
      final perspOpacity = 0.08 + t * 0.14;

      // Flat: evenly spaced across entire screen
      final flatY = (i + 1) * flatSpacing;
      const flatOpacity = 0.18;

      _hLines.add(
        _AnimLine(
          perspStart: Offset(0, perspY),
          perspEnd: Offset(w, perspY),
          perspOpacity: perspOpacity,
          flatStart: Offset(0, flatY),
          flatEnd: Offset(w, flatY),
          flatOpacity: flatOpacity,
        ),
      );
    }
  }

  // ── Build vertical lines (same count, different positions) ──

  void _buildVLines(double w, double h) {
    const halfCount = 14;
    const totalCount = halfCount * 2 + 1; // 29 lines
    final cx = w / 2;
    final bottomSpacing = w / (halfCount * 2);
    const flatSpacing = 60.0;

    for (int idx = 0; idx < totalCount; idx++) {
      final i = idx - halfCount; // -14 to +14

      // Perspective: converge toward center at horizon
      final bottomX = cx + i * bottomSpacing;
      const horizonSpread = 0.3;
      final horizonX = cx + i * bottomSpacing * horizonSpread;
      final centerDist = i.abs() / halfCount;
      final perspOpacity = (0.16 - centerDist * 0.08).clamp(0.06, 0.18);

      // Flat: evenly spaced parallel vertical lines
      final flatX = cx + i * flatSpacing;
      const flatOpacity = 0.18;

      _vLines.add(
        _AnimLine(
          perspStart: Offset(horizonX, _horizonY),
          perspEnd: Offset(bottomX, h),
          perspOpacity: perspOpacity,
          flatStart: Offset(flatX, 0),
          flatEnd: Offset(flatX, h),
          flatOpacity: flatOpacity,
        ),
      );
    }
  }

  // ── Stars ──

  void _buildStars(double w, double h, Random rng) {
    for (int i = 0; i < 30; i++) {
      _stars.add(
        _StarDot(
          x: rng.nextDouble() * w,
          y: rng.nextDouble() * h,
          radius: 0.5 + rng.nextDouble() * 1.0,
          paint: Paint()
            ..color = Color.fromRGBO(
              255,
              255,
              255,
              0.1 + rng.nextDouble() * 0.2,
            ),
        ),
      );
    }
  }

  // ── Update ──

  @override
  void update(double dt) {
    super.update(dt);

    // Animate transition with ease-in-out
    if (_transition != _targetTransition) {
      final speed = 1.0 / _transitionSpeed; // per second
      if (_transition < _targetTransition) {
        _transition = (_transition + speed * dt).clamp(0.0, _targetTransition);
      } else {
        _transition = (_transition - speed * dt).clamp(_targetTransition, 1.0);
      }
    }
  }

  // ── Render ──

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _bgPaint);

    final t = _easeInOut(_transition);

    // Stars (dim in perspective upper half, show everywhere in flat)
    for (final star in _stars) {
      if (star.y > _horizonY * 0.9 && t < 0.5) continue;
      canvas.drawCircle(Offset(star.x, star.y), star.radius, star.paint);
    }

    // Vertical lines
    for (final line in _vLines) {
      final opacity = line.lerpOpacity(t);
      if (opacity <= 0) continue;
      _linePaint.color = Color.fromRGBO(0, 255, 255, opacity);
      canvas.drawLine(line.lerpStart(t), line.lerpEnd(t), _linePaint);
    }

    // Horizontal lines
    for (final line in _hLines) {
      final opacity = line.lerpOpacity(t);
      if (opacity <= 0) continue;
      _linePaint.color = Color.fromRGBO(0, 255, 255, opacity);
      canvas.drawLine(line.lerpStart(t), line.lerpEnd(t), _linePaint);
    }

    // Horizon (fade out during transition)
    final horizonAlpha = 1.0 - t;
    if (horizonAlpha > 0.01) {
      _horizonGlowPaint.color = Color.fromRGBO(
        0,
        255,
        255,
        0.25 * horizonAlpha,
      );
      canvas.drawLine(
        Offset(0, _horizonY),
        Offset(size.x, _horizonY),
        _horizonGlowPaint,
      );
      _horizonLinePaint.color = Color.fromRGBO(
        0,
        255,
        255,
        0.50 * horizonAlpha,
      );
      canvas.drawLine(
        Offset(0, _horizonY),
        Offset(size.x, _horizonY),
        _horizonLinePaint,
      );
    }
  }

  /// Smooth ease-in-out curve.
  double _easeInOut(double t) {
    return t < 0.5 ? 2 * t * t : 1 - (-2 * t + 2) * (-2 * t + 2) / 2;
  }
}
