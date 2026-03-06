import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';

/// Full-screen death sequence effect with slow-mo overlay, scanlines,
/// and "SIGNAL PERDU" text.
///
/// Added at the game root (like FlashEffect), priority 900.
/// Triggered by DeathSlowMoEvent. Persistent component, reusable.
///
/// Phase 1 (0 - 0.6s): Radial gradient overlay pulsing from impact point.
/// Phase 2 (0.6 - 1.0s): "SIGNAL PERDU" fades in with scanlines.
/// Phase 3 (1.0 - 2.5s): Hold visible, then fade out.
class DeathSequence extends PositionComponent
    with HasGameReference<FlameGame>, DragCallbacks {
  double _timer = 0;
  bool _active = false;
  Vector2 _impactPoint = Vector2.zero();

  late final double _phase1End;
  late final double _phase2End;
  late final double _totalDuration;

  late final void Function(DeathSlowMoEvent) _deathListener;

  // Pre-allocated paints
  late final Paint _overlayPaint;
  late final Paint _scanlinePaint;
  late final Paint _textGlowPaint;

  // Text style components
  static const double _fontSize = 36.0;
  static const String _signalText = 'SIGNAL PERDU';

  @override
  Future<void> onLoad() async {
    priority = 900;

    _phase1End = GameConfig.deathSlowMoDuration; // 0.6s
    _phase2End = _phase1End + 0.4; // 1.0s
    _totalDuration = GameConfig.signalLostDuration; // 2.5s

    _overlayPaint = Paint()..style = PaintingStyle.fill;

    _scanlinePaint = Paint()
      ..color = const Color(0x18000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    _textGlowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    _deathListener = _onDeath;
    eventBus.on<DeathSlowMoEvent>(_deathListener);
  }

  @override
  void onRemove() {
    eventBus.off<DeathSlowMoEvent>(_deathListener);
    super.onRemove();
  }

  /// Never intercept input — let touches pass through.
  @override
  bool containsLocalPoint(Vector2 point) => false;

  void _onDeath(DeathSlowMoEvent event) {
    _active = true;
    _timer = 0;
    _impactPoint = event.position.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_active) return;

    _timer += dt;
    if (_timer >= _totalDuration) {
      _active = false;
      _timer = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_active) return;

    final gameSize = game.size;
    final screenRect = Rect.fromLTWH(0, 0, gameSize.x, gameSize.y);

    if (_timer <= _phase1End) {
      _renderPhase1(canvas, screenRect, gameSize);
    } else if (_timer <= _phase2End) {
      _renderPhase1(canvas, screenRect, gameSize);
      _renderPhase2(canvas, screenRect, gameSize);
    } else {
      _renderPhase3(canvas, screenRect, gameSize);
    }
  }

  /// Phase 1: Radial gradient overlay pulsing from impact point.
  void _renderPhase1(Canvas canvas, Rect screenRect, Vector2 gameSize) {
    final progress = (_timer / _phase1End).clamp(0.0, 1.0);
    final pulse = 0.5 + 0.5 * _sin01(progress * 3.0);
    final opacity = progress * 0.5 * (0.7 + 0.3 * pulse);

    // Radial gradient from impact point
    final center = Offset(_impactPoint.x, _impactPoint.y);
    final maxDim = gameSize.x > gameSize.y ? gameSize.x : gameSize.y;
    final radius = maxDim * (0.3 + 0.7 * progress);

    _overlayPaint.shader = Gradient.radial(
      center,
      radius,
      [
        Color.fromRGBO(0, 0, 0, opacity),
        Color.fromRGBO(10, 0, 20, opacity * 0.8),
        Color.fromRGBO(0, 0, 0, opacity * 0.4),
      ],
      [0.0, 0.5, 1.0],
    );
    canvas.drawRect(screenRect, _overlayPaint);
    // Reset shader for other phases
    _overlayPaint.shader = null;
  }

  /// Phase 2: "SIGNAL PERDU" fades in with scanlines.
  void _renderPhase2(Canvas canvas, Rect screenRect, Vector2 gameSize) {
    final phaseProgress =
        ((_timer - _phase1End) / (_phase2End - _phase1End)).clamp(0.0, 1.0);

    // Dark overlay at full strength
    _overlayPaint.color = Color.fromRGBO(0, 0, 0, 0.55);
    canvas.drawRect(screenRect, _overlayPaint);

    // Scanlines
    _renderScanlines(canvas, gameSize, phaseProgress);

    // "SIGNAL PERDU" text fading in
    _renderSignalText(canvas, gameSize, phaseProgress);
  }

  /// Phase 3: Hold then fade out.
  void _renderPhase3(Canvas canvas, Rect screenRect, Vector2 gameSize) {
    final holdEnd = _totalDuration - 0.5;
    final double fadeProgress;
    if (_timer < holdEnd) {
      fadeProgress = 1.0;
    } else {
      fadeProgress =
          1.0 - ((_timer - holdEnd) / (_totalDuration - holdEnd)).clamp(0.0, 1.0);
    }

    // Dark overlay fading out
    _overlayPaint.color = Color.fromRGBO(0, 0, 0, 0.55 * fadeProgress);
    canvas.drawRect(screenRect, _overlayPaint);

    // Scanlines fading out
    _renderScanlines(canvas, gameSize, fadeProgress);

    // Text fading out
    _renderSignalText(canvas, gameSize, fadeProgress);
  }

  void _renderScanlines(Canvas canvas, Vector2 gameSize, double opacity) {
    if (opacity <= 0) return;
    _scanlinePaint.color = Color.fromRGBO(0, 0, 0, 0.1 * opacity);

    for (double y = 0; y < gameSize.y; y += 4.0) {
      canvas.drawLine(Offset(0, y), Offset(gameSize.x, y), _scanlinePaint);
    }
  }

  void _renderSignalText(Canvas canvas, Vector2 gameSize, double opacity) {
    if (opacity <= 0) return;

    final cx = gameSize.x / 2;
    final cy = gameSize.y / 2;

    // Build text paragraph
    final paragraphBuilder = ParagraphBuilder(ParagraphStyle(
      textAlign: TextAlign.center,
      fontSize: _fontSize,
      fontFamily: 'monospace',
    ))
      ..pushStyle(TextStyle(
        color: Color.fromRGBO(0, 255, 100, opacity),
        fontSize: _fontSize,
        fontFamily: 'monospace',
        letterSpacing: 6.0,
      ))
      ..addText(_signalText);

    final paragraph = paragraphBuilder.build()
      ..layout(ParagraphConstraints(width: gameSize.x));

    final textY = cy - _fontSize / 2;

    // Green glow behind text
    _textGlowPaint.color = Color.fromRGBO(0, 255, 100, 0.3 * opacity);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy), width: 360, height: 60),
      _textGlowPaint,
    );

    canvas.drawParagraph(paragraph, Offset(0, textY));
  }

  /// Sine mapped to 0..1 range for pulsing effects.
  double _sin01(double t) {
    return 0.5 + 0.5 * sin(t * 2.0 * pi);
  }
}
