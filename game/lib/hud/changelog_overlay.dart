import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart'
    show TextPainter, TextDirection, TextStyle, TextSpan, FontWeight;

/// Scrollable changelog overlay with arcade terminal style.
class ChangelogOverlay extends PositionComponent
    with HasGameReference, DragCallbacks {
  final void Function() onDismiss;

  ChangelogOverlay({required this.onDismiss});

  double _scrollOffset = 0;
  double _maxScroll = 0;
  double _dragTotal = 0;
  static const _dragThreshold = 8.0;

  static const _titleY = 60.0;
  static const _contentTop = 110.0;
  static const _footerHeight = 60.0;
  static const _lineHeight = 26.0;
  static const _versionGap = 16.0;
  static const _leftMargin = 32.0;

  static const List<_ChangelogVersion> _versions = [
    _ChangelogVersion('v1.3.0', 'Audio', [
      '+ Ambient synth music (reactive volume)',
      '+ 14 sound effects (fire, explosions, dash...)',
      '+ Sound ON/OFF toggle in pause menu',
      '* Pause now fully freezes the game',
      '* Return to menu no longer causes blank screen',
    ]),
    _ChangelogVersion('v1.2.0', 'Space Vestiges & Galaxy', [
      '+ Starlink satellite train (150 pts)',
      '+ Space Station ISS/MIR — 3 HP (300 pts)',
      '+ Tesla Roadster + Starman (250 pts)',
      '+ Space debris spawn every 2 waves',
      '+ Galaxy background (Antennae nebula)',
      '+ Changelog screen',
    ]),
    _ChangelogVersion('v1.1.0', 'Arcade Polish', [
      '+ INSERT COIN title screen',
      '+ READY..GO countdown',
      '+ Wave announcement',
      '+ Combo system (up to 8x)',
      '+ Score popups',
      '+ Screen shake & flash effects',
      '+ Pause & return to menu',
      '+ Leaderboard Top 10',
      '+ Credits screen',
    ]),
    _ChangelogVersion('v1.0.0', 'Initial Release', [
      '+ Ship with thrust & inertia',
      '+ Asteroids (3 sizes)',
      '+ Dash ability',
      '+ UFOs: Scout, Hunter, Boss',
      '+ Power-ups: shield, multi-shot, slow-mo',
      '+ Starfield background',
    ]),
  ];

  @override
  Future<void> onLoad() async {
    size = game.size;
    position = Vector2.zero();
    priority = 300;

    // Calculate total content height
    double totalHeight = 0;
    for (final version in _versions) {
      totalHeight += _lineHeight; // version title
      totalHeight += version.lines.length * _lineHeight;
      totalHeight += _versionGap;
    }
    final viewportHeight = size.y - _contentTop - _footerHeight;
    _maxScroll = (totalHeight - viewportHeight).clamp(0, double.infinity);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _dragTotal = 0;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _dragTotal += event.localDelta.y.abs();
    _scrollOffset = (_scrollOffset - event.localDelta.y)
        .clamp(0, _maxScroll);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    // Only dismiss if it was a tap (not a real scroll)
    if (_dragTotal < _dragThreshold) {
      onDismiss();
      removeFromParent();
    }
  }

  @override
  void render(ui.Canvas canvas) {
    // Background
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, size.x, size.y),
      ui.Paint()..color = const ui.Color(0xFA000011),
    );

    // Fixed title (centered)
    _drawTextCentered(canvas, 'CHANGELOG', size.x / 2, _titleY, 36,
        const ui.Color(0xFFFFFF00), FontWeight.bold);

    // Clip scrollable area
    final clipRect = ui.Rect.fromLTWH(
        0, _contentTop, size.x, size.y - _contentTop - _footerHeight);
    canvas.save();
    canvas.clipRect(clipRect);

    double y = _contentTop + 14 - _scrollOffset;
    for (final version in _versions) {
      // Version header (left-aligned)
      _drawTextLeft(canvas, '${version.tag} — ${version.name}',
          _leftMargin, y, 20,
          const ui.Color(0xFF00FFFF), FontWeight.bold);
      y += _lineHeight;

      // Description lines (left-aligned, indented)
      for (final line in version.lines) {
        _drawTextLeft(canvas, '  $line',
            _leftMargin, y, 16,
            const ui.Color(0xFFFFFFFF), FontWeight.normal);
        y += _lineHeight;
      }
      y += _versionGap;
    }

    canvas.restore();

    // Footer (centered)
    _drawTextCentered(canvas, 'TAP TO CLOSE', size.x / 2, size.y - 40, 18,
        const ui.Color(0x88FFFFFF), FontWeight.normal);
  }

  void _drawTextCentered(ui.Canvas canvas, String text, double x, double y,
      double fontSize, ui.Color color, FontWeight weight) {
    final tp = _layoutText(text, fontSize, color, weight);
    tp.paint(canvas, ui.Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _drawTextLeft(ui.Canvas canvas, String text, double x, double y,
      double fontSize, ui.Color color, FontWeight weight) {
    final tp = _layoutText(text, fontSize, color, weight);
    tp.paint(canvas, ui.Offset(x, y - tp.height / 2));
  }

  TextPainter _layoutText(String text, double fontSize, ui.Color color,
      FontWeight weight) {
    return TextPainter(
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
  }
}

class _ChangelogVersion {
  final String tag;
  final String name;
  final List<String> lines;

  const _ChangelogVersion(this.tag, this.name, this.lines);
}
