import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart' show TextPainter, TextDirection, TextStyle, TextSpan;

import '../audio/audio_events.dart';
import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';
import 'panel_renderer.dart';

/// Semi-transparent overlay shown when the game is paused.
class PauseOverlay extends PositionComponent
    with HasGameReference<FlameGame>, DragCallbacks {
  bool _active = false;
  bool _soundOn = true;

  late final void Function(PauseEvent) _pauseListener;
  late final void Function(ResumeEvent) _resumeListener;
  late final void Function(MuteChangedEvent) _muteChangedListener;

  // Layout rects for tap detection
  late ui.Rect _menuBtnRect;
  late ui.Rect _soundRect;

  @override
  Future<void> onLoad() async {
    size = game.size;
    position = Vector2.zero();
    priority = 500;

    final cx = size.x / 2;
    final cy = size.y / 2;

    // MENU button — bottom of panel
    const menuW = 200.0;
    const menuH = 42.0;
    final panelBottom = cy + size.y * 0.65 / 2;
    _menuBtnRect = ui.Rect.fromCenter(
      center: ui.Offset(cx, panelBottom - 40),
      width: menuW,
      height: menuH,
    );

    // Sound toggle — exact same position as pause button (replaces it visually)
    _soundRect = ui.Rect.fromLTWH(
      size.x - 60, 40, 44, 44,
    );

    _pauseListener = (_) => _pause();
    _resumeListener = (_) => _resume();
    _muteChangedListener = (e) => _soundOn = !e.isMuted;
    eventBus.on<PauseEvent>(_pauseListener);
    eventBus.on<ResumeEvent>(_resumeListener);
    eventBus.on<MuteChangedEvent>(_muteChangedListener);
  }

  @override
  void onRemove() {
    eventBus.off<PauseEvent>(_pauseListener);
    eventBus.off<ResumeEvent>(_resumeListener);
    eventBus.off<MuteChangedEvent>(_muteChangedListener);
    super.onRemove();
  }

  void _pause() => _active = true;
  void _resume() => _active = false;

  @override
  bool containsLocalPoint(Vector2 point) => _active;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!_active) return;

    final pos = event.localPosition;
    final offset = ui.Offset(pos.x, pos.y);

    // Sound toggle (check first — it's inside the panel area)
    if (_soundRect.contains(offset)) {
      eventBus.emit(MuteToggleEvent());
      return;
    }

    // Menu button
    if (_menuBtnRect.contains(offset)) {
      _active = false;
      eventBus.emit(ResumeEvent());
      eventBus.emit(ReturnToMenuEvent());
      return;
    }

    // Tap anywhere else resumes
    eventBus.emit(ResumeEvent());
  }

  @override
  void render(ui.Canvas canvas) {
    if (!_active) return;

    final cx = size.x / 2;
    final cy = size.y / 2;

    PanelRenderer.drawOverlayBackground(canvas, size.x, size.y);

    final panelRect = ui.Rect.fromCenter(
      center: ui.Offset(cx, cy),
      width: size.x * 0.55,
      height: size.y * 0.65,
    );
    PanelRenderer.drawPanel(canvas, panelRect, title: 'PAUSED');
    PanelRenderer.drawScanlines(canvas, panelRect);

    PanelRenderer.drawTronTitle(canvas, 'PAUSED', cx, cy - 60, 52);

    final ms = DateTime.now().millisecondsSinceEpoch;
    final pulse = 0.5 + sin(ms / 300.0) * 0.5;
    PanelRenderer.drawTextCentered(canvas, 'TAP TO RESUME', cx, cy + 10, 18,
        ui.Color.fromARGB((pulse * 200).toInt(), 0, 255, 255),
        letterSpacing: 1.5);

    PanelRenderer.drawGlowButton(canvas, _menuBtnRect, 'MENU', GameConfig.arcadeYellow);

    // version label stays as-is (it's custom positioning)
    final vtp = TextPainter(
      text: const TextSpan(
        text: 'v1.8.0',
        style: TextStyle(
          color: ui.Color(0x6600FFFF),
          fontSize: 11,
          fontFamily: 'JetBrainsMono',
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    vtp.paint(canvas, ui.Offset(size.x - 16 - vtp.width, 12));

    _drawSpeakerIcon(canvas);
  }

  void _drawSpeakerIcon(ui.Canvas canvas) {
    final cx = _soundRect.center.dx;
    final cy = _soundRect.center.dy;
    final color = _soundOn
        ? const ui.Color(0xAAFFFFFF)
        : const ui.Color(0x44888888);

    // Ring around speaker (same style as pause button)
    const ringRadius = 20.0;
    final center = ui.Offset(cx, cy);
    final ringGlow = ui.Paint()
      ..color = const ui.Color(0x2200FFFF)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = ui.StrokeCap.round
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3);
    final ringPaint = ui.Paint()
      ..color = const ui.Color(0x6600FFFF)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = ui.StrokeCap.round;
    final ringRect = ui.Rect.fromCircle(center: center, radius: ringRadius);
    canvas.drawArc(ringRect, 0.4, 2.34, false, ringGlow);
    canvas.drawArc(ringRect, 0.4, 2.34, false, ringPaint);
    canvas.drawArc(ringRect, -2.74, 2.34, false, ringGlow);
    canvas.drawArc(ringRect, -2.74, 2.34, false, ringPaint);
    // Tick marks
    final tickPaint = ui.Paint()
      ..color = const ui.Color(0x4400FFFF)
      ..strokeWidth = 1.0
      ..strokeCap = ui.StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final a = i * pi / 2;
      canvas.drawLine(
        ui.Offset(cx + cos(a) * (ringRadius + 1), cy + sin(a) * (ringRadius + 1)),
        ui.Offset(cx + cos(a) * (ringRadius + 4), cy + sin(a) * (ringRadius + 4)),
        tickPaint,
      );
    }

    final paint = ui.Paint()
      ..color = color
      ..style = ui.PaintingStyle.fill;

    // Speaker body — centered and fits inside ring (radius 20)
    final sx = cx - 2; // shift left slightly to center visually
    canvas.drawRect(
      ui.Rect.fromLTWH(sx - 6, cy - 3, 5, 6),
      paint,
    );
    final conePath = ui.Path()
      ..moveTo(sx - 1, cy - 3)
      ..lineTo(sx + 4, cy - 7)
      ..lineTo(sx + 4, cy + 7)
      ..lineTo(sx - 1, cy + 3)
      ..close();
    canvas.drawPath(conePath, paint);

    if (_soundOn) {
      final wavePaint = ui.Paint()
        ..color = color
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = ui.StrokeCap.round;
      canvas.drawArc(
        ui.Rect.fromCenter(center: ui.Offset(sx + 6, cy), width: 7, height: 10),
        -0.8, 1.6, false, wavePaint,
      );
      canvas.drawArc(
        ui.Rect.fromCenter(center: ui.Offset(sx + 6, cy), width: 14, height: 18),
        -0.8, 1.6, false, wavePaint,
      );
    } else {
      final slashPaint = ui.Paint()
        ..color = color
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = ui.StrokeCap.round;
      canvas.drawLine(
        ui.Offset(sx + 6, cy - 6),
        ui.Offset(sx + 13, cy + 6),
        slashPaint,
      );
    }
  }
}
