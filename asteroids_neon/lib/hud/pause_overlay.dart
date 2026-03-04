import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart' show TextPainter, TextDirection, TextStyle, TextSpan, FontWeight;

import '../audio/audio_events.dart';
import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';

/// Semi-transparent overlay shown when the game is paused.
///
/// "PAUSED" text with pulsing "TAP TO RESUME" and MENU button.
/// Uses DateTime.now() for pulse animation since game.update() is frozen.
class PauseOverlay extends PositionComponent
    with HasGameReference<FlameGame>, DragCallbacks {
  bool _active = false;

  bool _soundOn = true;

  late final void Function(PauseEvent) _pauseListener;
  late final void Function(ResumeEvent) _resumeListener;
  late final void Function(MuteChangedEvent) _muteChangedListener;

  // Layout rects for tap detection
  late ui.Rect _resumeRect;
  late ui.Rect _menuRect;
  late ui.Rect _soundRect;

  @override
  Future<void> onLoad() async {
    size = game.size;
    position = Vector2.zero();
    priority = 500;

    final cx = size.x / 2;
    final cy = size.y / 2;
    _resumeRect = ui.Rect.fromCenter(
      center: ui.Offset(cx, cy + 50),
      width: 300,
      height: 50,
    );
    _menuRect = ui.Rect.fromCenter(
      center: ui.Offset(cx, cy + 120),
      width: 200,
      height: 50,
    );
    _soundRect = ui.Rect.fromCenter(
      center: ui.Offset(cx, cy + 190),
      width: 250,
      height: 50,
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

  void _pause() {
    _active = true;
  }

  void _resume() {
    _active = false;
  }

  @override
  bool containsLocalPoint(Vector2 point) => _active;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!_active) return;

    final pos = event.localPosition;
    if (_resumeRect.contains(ui.Offset(pos.x, pos.y))) {
      eventBus.emit(ResumeEvent());
    } else if (_menuRect.contains(ui.Offset(pos.x, pos.y))) {
      _active = false;
      eventBus.emit(ResumeEvent());
      eventBus.emit(ReturnToMenuEvent());
    } else if (_soundRect.contains(ui.Offset(pos.x, pos.y))) {
      eventBus.emit(MuteToggleEvent());
    }
  }

  @override
  void render(ui.Canvas canvas) {
    if (!_active) return;

    // Semi-transparent background
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, size.x, size.y),
      ui.Paint()..color = const ui.Color(0xCC000011),
    );

    final cx = size.x / 2;
    final cy = size.y / 2;

    // "PAUSED" title
    _drawText(canvas, 'PAUSED', cx, cy - 40, 56,
        GameConfig.shipColor, FontWeight.bold);

    // Pulsing "TAP TO RESUME" using real clock
    final ms = DateTime.now().millisecondsSinceEpoch;
    final pulse = 0.5 + sin(ms / 300.0) * 0.5;
    final resumeColor = ui.Color.fromARGB(
      (pulse * 255).toInt(), 255, 255, 255,
    );
    _drawText(canvas, 'TAP TO RESUME', cx, cy + 50, 24,
        resumeColor, FontWeight.normal);

    // "MENU" button
    _drawText(canvas, 'MENU', cx, cy + 120, 22,
        GameConfig.arcadeYellow, FontWeight.bold);

    // "SOUND: ON/OFF" button
    final soundLabel = _soundOn ? 'SOUND: ON' : 'SOUND: OFF';
    final soundColor = _soundOn ? GameConfig.arcadeGreen : GameConfig.arcadeRed;
    _drawText(canvas, soundLabel, cx, cy + 190, 20,
        soundColor, FontWeight.bold);
  }

  void _drawText(ui.Canvas canvas, String text, double x, double y,
      double fontSize, ui.Color color, FontWeight weight) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, ui.Offset(x - tp.width / 2, y - tp.height / 2));
  }
}
