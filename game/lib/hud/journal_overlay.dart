import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart' show FontWeight;

import '../hud/panel_renderer.dart';
import '../narration/fragment_data.dart';

/// Scrollable journal overlay with list view and detail view.
///
/// List: unlocked fragments show title + first line, tappable.
/// Detail: full fragment text in terminal style, tap to go back.
/// Locked fragments show "WAVE XX — ???" in dim color.
class JournalOverlay extends PositionComponent
    with HasGameReference<FlameGame>, DragCallbacks {
  final List<int> unlockedIds;
  final void Function() onDismiss;

  JournalOverlay({required this.unlockedIds, required this.onDismiss});

  bool _isUnlocked(NarrativeFragment f) =>
      f.waveRequired == 0 || unlockedIds.contains(f.id);

  // List view state
  double _scrollOffset = 0;
  double _maxScroll = 0;
  double _dragTotal = 0;
  static const _dragThreshold = 8.0;

  // Detail view state
  NarrativeFragment? _selectedFragment;
  double _detailScroll = 0;
  double _detailMaxScroll = 0;

  static const _lineHeight = 26.0;
  static const _entryGap = 16.0;

  // Panel-relative layout values (computed in onLoad)
  late double _panelTop;
  late double _panelBottom;
  late double _titleY;
  late double _contentTop;
  late double _footerHeight;
  late double _leftMargin;

  // Hit-test rects for unlocked entries
  final List<_EntryRect> _entryRects = [];
  Vector2 _dragStartPos = Vector2.zero();

  @override
  Future<void> onLoad() async {
    size = game.size;
    position = Vector2.zero();
    priority = 300;

    // Compute panel-relative layout
    _panelTop = size.y * 0.125;
    _panelBottom = size.y * 0.875;
    _titleY = _panelTop + 40;
    _contentTop = _panelTop + 80;
    _footerHeight = size.y - _panelBottom + 40;
    _leftMargin = size.x * 0.15 + 20;

    _recalcListScroll();
  }

  void _recalcListScroll() {
    double totalHeight = 0;
    for (final fragment in FragmentData.fragments) {
      totalHeight += _lineHeight;
      if (_isUnlocked(fragment)) {
        totalHeight += _lineHeight;
      }
      totalHeight += _entryGap;
    }
    final viewportHeight = size.y - _contentTop - _footerHeight;
    _maxScroll = (totalHeight - viewportHeight).clamp(0, double.infinity);
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _dragTotal = 0;
    _dragStartPos = event.localPosition.clone();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _dragTotal += event.localDelta.y.abs();
    if (_selectedFragment != null) {
      _detailScroll = (_detailScroll - event.localDelta.y).clamp(
        0,
        _detailMaxScroll,
      );
    } else {
      _scrollOffset = (_scrollOffset - event.localDelta.y).clamp(0, _maxScroll);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (_dragTotal >= _dragThreshold) return; // Was a scroll, not a tap

    if (_selectedFragment != null) {
      // In detail view — tap goes back to list
      _selectedFragment = null;
      _detailScroll = 0;
      return;
    }

    // In list view — check if tap is on an unlocked entry
    final pos = _dragStartPos;
    for (final entry in _entryRects) {
      if (entry.rect.contains(ui.Offset(pos.x, pos.y))) {
        _selectedFragment = entry.fragment;
        _detailScroll = 0;
        // Calculate detail max scroll
        final lines = entry.fragment.text.split('\n');
        final detailHeight = 180.0 + lines.length * 28.0 + 40;
        final viewH = size.y - _footerHeight;
        _detailMaxScroll = (detailHeight - viewH).clamp(0, double.infinity);
        return;
      }
    }

    // Tap outside any entry — dismiss
    onDismiss();
    removeFromParent();
  }

  @override
  void render(ui.Canvas canvas) {
    // Background
    PanelRenderer.drawOverlayBackground(canvas, size.x, size.y);

    // Panel
    final panelRect = ui.Rect.fromCenter(
      center: ui.Offset(size.x / 2, size.y / 2),
      width: size.x * 0.7,
      height: size.y * 0.75,
    );
    PanelRenderer.drawPanel(canvas, panelRect, title: 'SHIP LOG');
    PanelRenderer.drawScanlines(canvas, panelRect);

    if (_selectedFragment != null) {
      _renderDetail(canvas, _selectedFragment!);
    } else {
      _renderList(canvas);
    }
  }

  void _renderList(ui.Canvas canvas) {
    // Fixed title
    PanelRenderer.drawTextCentered(
      canvas,
      'SHIP LOG',
      size.x / 2,
      _titleY,
      36,
      const ui.Color(0xFF00FF66),
      weight: FontWeight.bold,
      glow: true,
    );

    // Clip scrollable area
    final clipRect = ui.Rect.fromLTWH(
      0,
      _contentTop,
      size.x,
      size.y - _contentTop - _footerHeight,
    );
    canvas.save();
    canvas.clipRect(clipRect);

    _entryRects.clear();
    double y = _contentTop + 14 - _scrollOffset;

    for (final fragment in FragmentData.fragments) {
      final unlocked = _isUnlocked(fragment);
      final entryStartY = y;

      if (unlocked) {
        PanelRenderer.drawTextLeft(
          canvas,
          'WAVE ${fragment.waveRequired} — ${fragment.title}',
          _leftMargin,
          y,
          20,
          const ui.Color(0xFF00FFFF),
          weight: FontWeight.bold,
        );
        y += _lineHeight;

        final firstLine = fragment.text.split('\n').first;
        PanelRenderer.drawTextLeft(
          canvas,
          '  $firstLine',
          _leftMargin,
          y,
          16,
          const ui.Color(0xFF00FF66),
        );
        y += _lineHeight;

        // Store hit rect for this entry
        _entryRects.add(
          _EntryRect(
            fragment: fragment,
            rect: ui.Rect.fromLTWH(
              0,
              entryStartY - 6,
              size.x,
              y - entryStartY + 6,
            ),
          ),
        );
      } else {
        final waveNum = fragment.waveRequired.toString().padLeft(3, '0');
        PanelRenderer.drawTextLeft(
          canvas,
          'WAVE $waveNum — ???',
          _leftMargin,
          y,
          20,
          const ui.Color(0x66448844),
        );
        y += _lineHeight;
      }
      y += _entryGap;
    }

    canvas.restore();

    // Separator line above footer
    PanelRenderer.drawSeparator(
      canvas,
      size.x * 0.3,
      size.x * 0.7,
      _panelBottom - 40,
    );

    // Footer
    PanelRenderer.drawTextCentered(
      canvas,
      'TAP ENTRY TO READ  •  TAP OUTSIDE TO CLOSE',
      size.x / 2,
      _panelBottom - 20,
      14,
      const ui.Color(0x8800FF66),
    );
  }

  void _renderDetail(ui.Canvas canvas, NarrativeFragment fragment) {
    final cx = size.x / 2;

    // Clip for scrolling
    canvas.save();
    canvas.clipRect(
      ui.Rect.fromLTWH(0, _panelTop, size.x, _panelBottom - _panelTop - 50),
    );

    double y = _panelTop + 30 - _detailScroll;

    // "MEMORY FRAGMENT" header
    PanelRenderer.drawTextCentered(
      canvas,
      'MEMORY FRAGMENT',
      cx,
      y,
      28,
      const ui.Color(0xFF00FF66),
      weight: FontWeight.bold,
      glow: true,
    );
    y += 50;

    // Title in cyan
    PanelRenderer.drawTextCentered(
      canvas,
      fragment.title,
      cx,
      y,
      24,
      const ui.Color(0xFF00FFFF),
      weight: FontWeight.bold,
      glow: true,
    );
    y += 20;

    // Wave subtitle
    PanelRenderer.drawTextCentered(
      canvas,
      'WAVE ${fragment.waveRequired}',
      cx,
      y,
      16,
      const ui.Color(0x8800FFFF),
    );
    y += 40;

    // Separator line
    canvas.drawLine(
      ui.Offset(size.x * 0.2, y),
      ui.Offset(size.x * 0.8, y),
      ui.Paint()
        ..color = const ui.Color(0x4400FF66)
        ..strokeWidth = 1.0,
    );
    y += 30;

    // Full text, line by line
    final lines = fragment.text.split('\n');
    for (final line in lines) {
      if (line.isEmpty) {
        y += 14; // Empty line gap
      } else {
        PanelRenderer.drawTextCentered(
          canvas,
          line,
          cx,
          y,
          18,
          const ui.Color(0xFF00FF66),
        );
        y += 28;
      }
    }

    canvas.restore();

    // Separator line above footer
    PanelRenderer.drawSeparator(
      canvas,
      size.x * 0.3,
      size.x * 0.7,
      _panelBottom - 40,
    );

    // Pulsing footer
    final ms = DateTime.now().millisecondsSinceEpoch;
    final pulse = 0.5 + sin(ms / 300.0) * 0.5;
    final pulseColor = ui.Color.fromARGB((pulse * 255).toInt(), 0, 255, 102);
    PanelRenderer.drawTextCentered(
      canvas,
      'TAP TO GO BACK',
      cx,
      _panelBottom - 20,
      18,
      pulseColor,
    );
  }
}

class _EntryRect {
  final NarrativeFragment fragment;
  final ui.Rect rect;
  _EntryRect({required this.fragment, required this.rect});
}
