import 'dart:math';
import 'dart:ui' as ui;

import 'package:d4_dark_ds/d4_dark_ds.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart'
    show FontWeight, TextStyle, TextSpan, TextPainter, TextDirection;

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
      28,
      D4DsColors.cyan,
      weight: FontWeight.bold,
      glow: true,
      letterSpacing: 2.0,
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
        // Wave label — dimmed
        PanelRenderer.drawTextLeft(
          canvas,
          'WAVE ${fragment.waveRequired}',
          _leftMargin,
          y,
          11,
          D4DsColors.textDimmed,
          letterSpacing: 1.0,
        );
        y += 18;

        // Fragment title — cyan
        PanelRenderer.drawTextLeft(
          canvas,
          fragment.title,
          _leftMargin,
          y,
          16,
          D4DsColors.cyan,
          weight: FontWeight.bold,
        );
        y += _lineHeight;

        // First line preview — secondary text
        final firstLine = fragment.text.split('\n').first;
        PanelRenderer.drawTextLeft(
          canvas,
          firstLine,
          _leftMargin,
          y,
          13,
          D4DsColors.textSecondary,
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
          14,
          D4DsColors.textDimmed,
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
      12,
      D4DsColors.textDimmed,
    );
  }

  void _renderDetail(ui.Canvas canvas, NarrativeFragment fragment) {
    final cx = size.x / 2;
    final panelRect = ui.Rect.fromCenter(
      center: ui.Offset(cx, size.y / 2),
      width: size.x * 0.7,
      height: size.y * 0.75,
    );
    final contentLeft = panelRect.left + 32;
    final contentRight = panelRect.right - 32;
    final contentWidth = contentRight - contentLeft;

    // Clip for scrolling
    canvas.save();
    canvas.clipRect(
      ui.Rect.fromLTWH(0, _panelTop, size.x, _panelBottom - _panelTop - 50),
    );

    double y = _panelTop + 30 - _detailScroll;

    // Title — left-aligned, cyan bold
    PanelRenderer.drawTextLeft(
      canvas,
      fragment.title.toUpperCase(),
      contentLeft,
      y,
      20,
      D4DsColors.cyan,
      weight: FontWeight.bold,
      glow: true,
      letterSpacing: 1.5,
    );
    y += 28;

    // Wave label — dimmed
    PanelRenderer.drawTextLeft(
      canvas,
      'WAVE ${fragment.waveRequired}',
      contentLeft,
      y,
      12,
      D4DsColors.textDimmed,
      letterSpacing: 1.0,
    );
    y += 24;

    // Separator
    PanelRenderer.drawSeparator(canvas, contentLeft, contentRight, y);
    y += 24;

    // Narrative text — left-aligned, wrapped, secondary color
    final tp = TextPainter(
      text: TextSpan(
        text: fragment.text,
        style: TextStyle(
          color: D4DsColors.textSecondary,
          fontSize: 15,
          fontFamily: D4DsTypography.monoFont,
          height: 1.6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: contentWidth);
    tp.paint(canvas, ui.Offset(contentLeft, y));

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
    final pulseColor = ui.Color.fromARGB((pulse * 255).toInt(), 0, 255, 255);
    PanelRenderer.drawTextCentered(
      canvas,
      'TAP TO GO BACK',
      cx,
      _panelBottom - 20,
      14,
      pulseColor,
      letterSpacing: 1.5,
    );
  }
}

class _EntryRect {
  final NarrativeFragment fragment;
  final ui.Rect rect;
  _EntryRect({required this.fragment, required this.rect});
}
