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

    // Pre-generate radii with occasional deep notches (craters)
    final radii = <double>[];
    for (int i = 0; i < vertices; i++) {
      if (_random.nextDouble() < 0.25) {
        // Deep concavity — crater/notch (25% chance)
        radii.add(radius * (0.45 + _random.nextDouble() * 0.15));
      } else {
        // Normal variation
        radii.add(radius * (0.7 + _random.nextDouble() * 0.3));
      }
    }

    // Smooth adjacent vertices slightly to avoid spikes
    final smoothed = <double>[];
    for (int i = 0; i < vertices; i++) {
      final prev = radii[(i - 1 + vertices) % vertices];
      final curr = radii[i];
      final next = radii[(i + 1) % vertices];
      smoothed.add(curr * 0.6 + (prev + next) * 0.2);
    }

    for (int i = 0; i < vertices; i++) {
      final r = smoothed[i];
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

  /// More vertices for larger asteroids = more detail.
  static int _verticesForRadius(double radius) {
    if (radius >= 35) return 12 + _random.nextInt(4); // large: 12-15
    if (radius >= 18) return 10 + _random.nextInt(3); // medium: 10-12
    return 8 + _random.nextInt(3); // small: 8-10
  }
}
