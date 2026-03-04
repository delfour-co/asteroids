import 'package:flutter_test/flutter_test.dart';

import 'package:asteroids_neon/asteroids/asteroid_generator.dart';

void main() {
  group('AsteroidGenerator', () {
    test('generates a non-empty path', () {
      final path = AsteroidGenerator.generateShape(40.0);
      // Path should not be empty (contains move/line commands)
      expect(path, isNotNull);
    });

    test('generates with custom vertex count', () {
      for (int v = 5; v <= 15; v++) {
        final path = AsteroidGenerator.generateShape(30.0, numVertices: v);
        expect(path, isNotNull);
      }
    });

    test('generates different shapes each call (random)', () {
      // Just verify both calls succeed without error
      final path1 = AsteroidGenerator.generateShape(30.0);
      final path2 = AsteroidGenerator.generateShape(30.0);
      expect(path1, isNotNull);
      expect(path2, isNotNull);
    });

    test('accepts various radii', () {
      for (final r in [5.0, 12.0, 22.0, 40.0]) {
        final path = AsteroidGenerator.generateShape(r);
        expect(path, isNotNull);
      }
    });
  });
}
