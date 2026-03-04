import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/effects/neon_renderer.dart';

void main() {
  group('NeonRenderer', () {
    test('createNeonPaints returns glow and solid paints', () {
      final paints = NeonRenderer.createNeonPaints(
        color: const Color(0xFF00FFFF),
        glowRadius: 10.0,
        glowOpacity: 0.6,
        strokeWidth: 2.0,
      );

      expect(paints.glow, isNotNull);
      expect(paints.solid, isNotNull);
    });

    test('glow paint has blur filter', () {
      final paints = NeonRenderer.createNeonPaints(
        color: const Color(0xFFFF00FF),
        glowRadius: 8.0,
      );

      expect(paints.glow.maskFilter, isNotNull);
    });

    test('solid paint has no blur filter', () {
      final paints = NeonRenderer.createNeonPaints(
        color: const Color(0xFFFF00FF),
      );

      expect(paints.solid.maskFilter, isNull);
    });

    test('both paints are stroke style', () {
      final paints = NeonRenderer.createNeonPaints(
        color: const Color(0xFF00FF00),
      );

      expect(paints.glow.style, PaintingStyle.stroke);
      expect(paints.solid.style, PaintingStyle.stroke);
    });

    test('glow paint is wider than solid', () {
      final paints = NeonRenderer.createNeonPaints(
        color: const Color(0xFF00FF00),
        strokeWidth: 2.0,
      );

      expect(paints.glow.strokeWidth, greaterThan(paints.solid.strokeWidth));
    });

    test('solid paint uses exact color', () {
      const color = Color(0xFF00FFFF);
      final paints = NeonRenderer.createNeonPaints(color: color);

      expect(paints.solid.color, color);
    });
  });
}
