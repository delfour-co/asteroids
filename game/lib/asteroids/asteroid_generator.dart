import 'dart:math';
import 'dart:ui';

/// Generates procedural irregular polygon shapes for asteroids.
///
/// Creates shapes with concavities (craters/notches) for a more
/// detailed, rocky appearance similar to classic arcade asteroids.
class AsteroidGenerator {
  static final Random _random = Random();

  /// Generate a random irregular polygon path for an asteroid.
  ///
  /// [radius] — average radius of the asteroid.
  /// [numVertices] — number of vertices (more = more detail).
  /// Returns a closed Path with concavities for a rocky look.
  static Path generateShape(double radius, {int? numVertices}) {
    final vertices = numVertices ?? _verticesForRadius(radius);
    final path = Path();
    final angleStep = (2 * pi) / vertices;

    // Gentle variation for geometric but not perfect shapes
    final radii = <double>[];
    for (int i = 0; i < vertices; i++) {
      radii.add(radius * (0.85 + _random.nextDouble() * 0.15));
    }

    for (int i = 0; i < vertices; i++) {
      final r = radii[i];
      final a = angleStep * i;
      final x = cos(a) * r;
      final y = sin(a) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  static int _verticesForRadius(double radius) {
    if (radius >= 35) return 6 + _random.nextInt(3); // large: 6-8
    if (radius >= 18) return 5 + _random.nextInt(2); // medium: 5-6
    return 4 + _random.nextInt(2); // small: 4-5
  }
}
