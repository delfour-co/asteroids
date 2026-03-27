import 'dart:ui' as ui;

import 'package:d4_dark_ds/d4_dark_ds.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/painting.dart' show FontWeight;

import 'panel_renderer.dart';

/// Scrollable changelog overlay with arcade terminal style.
class ChangelogOverlay extends PositionComponent
    with HasGameReference, DragCallbacks {
  final void Function() onDismiss;

  ChangelogOverlay({required this.onDismiss});

  double _scrollOffset = 0;
  double _maxScroll = 0;
  double _dragTotal = 0;
  static const _dragThreshold = 8.0;

  static const _lineHeight = 16.0;
  static const _versionGap = 20.0;

  // Panel-relative layout values (computed in onLoad)
  late double _panelTop;
  late double _panelBottom;
  late double _titleY;
  late double _contentTop;
  late double _footerHeight;

  static const List<_ChangelogVersion> _versions = [
    _ChangelogVersion('v1.9.0', 'D4 Dark Design System', [
      '+ Integrated d4_dark_ds shared design system',
      '* Redesigned all overlays with proper typography',
      '* Credits: two-column layout with tech stack & assets',
      '* Game over: violet TAP TO RESTART, dual-color stats',
      '* Title screen: two-line NEON / ASTEROIDS, bigger INSERT COIN',
      '* Cosmetics: neon glow selection with lock icons',
      '* Brighter Tron grid on menu & gameplay',
      '* Flattened project structure (removed game/ wrapper)',
    ]),
    _ChangelogVersion('v1.8.0', 'Design System Alignment', [
      '* Aligned UI with Delfour.co design system',
      '* Pure black background (#000000)',
      '* Standardised panels, buttons, glows & borders',
      '* Shared panel renderer (less code, more consistent)',
      '* Rounded dialog corners (16px) and button corners (8px)',
    ]),
    _ChangelogVersion('v1.7.0', 'Session Stats & Feel', [
      '+ Post-game stats screen (accuracy, combos, kills...)',
      '+ Projectile laser trails',
      '+ Impact spark particles on hit',
      '+ Haptic feedback (hit, death, game over)',
    ]),
    _ChangelogVersion('v1.6.1', 'Play Games & Polish', [
      '+ Google Play Games Services sign-in',
      '+ 12 achievements (wave milestones, dash, UFO...)',
      '+ 2 leaderboards (High Score, Best Wave)',
      '+ Splash screen video on launch (skippable)',
      '+ Title screen logo image',
      '* Projectiles no longer wrap around screen',
      '* Fix PGS async calls & Crashlytics tracing',
    ]),
    _ChangelogVersion('v1.5.0', 'Narration & Beyond', [
      '+ 10 narrative fragments (unlock every 10 waves)',
      '+ Ship Log journal on title screen',
      '+ "SIGNAL PERDU" death sequence',
      '+ Shooting stars background',
      '+ Explosive asteroids (wave 5+)',
      '+ Magnetic asteroids (wave 8+)',
      '+ Perfect kill bonus (close range)',
      '+ Knockback on explosive blasts',
      '+ Ship color cosmetics (unlock via waves)',
      '+ Evolving nebula background',
      '* Renamed to Neon Asteroids',
    ]),
    _ChangelogVersion('v1.4.0', 'Polish', [
      '+ Interactive tutorial on first launch',
      '+ Neon ring wave transition (wave 2+)',
      '+ Ember particles after explosions',
    ]),
    _ChangelogVersion('v1.3.1', 'Stability', [
      '+ Firebase Crashlytics crash reporting',
      '* Fix audio player dispose crash',
    ]),
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

    // Compute panel-relative layout
    _panelTop = size.y * 0.125;
    _panelBottom = size.y * 0.875;
    _titleY = _panelTop + 40;
    _contentTop = _panelTop + 80;
    _footerHeight = size.y - _panelBottom + 40;
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
    _scrollOffset = (_scrollOffset - event.localDelta.y).clamp(0, _maxScroll);
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
    PanelRenderer.drawOverlayBackground(canvas, size.x, size.y);

    // Panel
    final panelRect = ui.Rect.fromCenter(
      center: ui.Offset(size.x / 2, size.y / 2),
      width: size.x * 0.7,
      height: size.y * 0.75,
    );
    PanelRenderer.drawPanel(canvas, panelRect, title: 'CHANGELOG');
    PanelRenderer.drawScanlines(canvas, panelRect);

    final contentLeft = panelRect.left + 32;
    final contentRight = panelRect.right - 32;

    // Fixed title
    PanelRenderer.drawTextLeft(
      canvas,
      'CHANGELOG',
      contentLeft,
      _titleY,
      20,
      D4DsColors.cyan,
      weight: FontWeight.bold,
      glow: true,
      letterSpacing: 1.5,
    );

    // Separator below title
    PanelRenderer.drawSeparator(
      canvas,
      contentLeft,
      contentRight,
      _titleY + 22,
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

    double y = _contentTop + 6 - _scrollOffset;
    for (final version in _versions) {
      // Version tag — dimmed label
      PanelRenderer.drawTextLeft(
        canvas,
        version.tag,
        contentLeft,
        y,
        10,
        D4DsColors.textDimmed,
        letterSpacing: 1.0,
      );
      y += 16;

      // Version name — primary bold
      PanelRenderer.drawTextLeft(
        canvas,
        version.name,
        contentLeft,
        y,
        15,
        D4DsColors.textPrimary,
        weight: FontWeight.bold,
      );
      y += 22;

      // Description lines — secondary, indented
      for (final line in version.lines) {
        PanelRenderer.drawTextLeft(
          canvas,
          line,
          contentLeft + 12,
          y,
          11,
          D4DsColors.textSecondary,
        );
        y += _lineHeight;
      }
      y += _versionGap;
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
      'TAP TO CLOSE',
      size.x / 2,
      _panelBottom - 20,
      12,
      D4DsColors.textDimmed,
    );
  }
}

class _ChangelogVersion {
  final String tag;
  final String name;
  final List<String> lines;

  const _ChangelogVersion(this.tag, this.name, this.lines);
}
