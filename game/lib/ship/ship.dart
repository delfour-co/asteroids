import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../asteroids/asteroid.dart';
import '../asteroids/explosive_asteroid.dart';
import '../asteroids/magnetic_asteroid.dart';
import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_config.dart';
import '../effects/neon_renderer.dart';
import '../input/action_buttons.dart';
import '../input/dash_button.dart';
import '../input/joystick.dart';
import '../powerups/powerup.dart';
import '../powerups/powerup_manager.dart';
import '../projectiles/projectile_manager.dart';

/// Event emitted when the ship is destroyed by an asteroid.
class ShipDestroyedEvent {
  final Vector2 position;
  ShipDestroyedEvent(this.position);
}

/// The player's neon ship.
///
/// Rendered as a triangular polygon with cyan glow effect.
/// Listens to JoystickDirectionEvent for rotation.
/// Listens to ThrustEvent for acceleration.
/// Listens to DashEvent for dash boost.
/// Applies space inertia (drift) and screen wrap-around.
class Ship extends PositionComponent
    with HasGameReference, CollisionCallbacks {
  // Ship dimensions
  static const double _shipHeight = 30.0;
  static const double _shipHalfWidth = 10.0;

  // Pre-allocated path and paints (NEVER created in render)
  late final Path _shipPath;
  late final Paint _glowPaint;
  late final Paint _solidPaint;

  // Physics — pre-allocated vectors
  final Vector2 _velocity = Vector2.zero();
  bool _isThrusting = false;

  // Invulnerability after respawn
  bool _invulnerable = false;
  double _invulnerableTimer = 0;
  static const double _invulnerableDuration = 2.0;

  // Dash
  bool _isDashing = false;
  double _dashTimer = 0;

  // Dash trail positions
  final List<Vector2> _trailPositions = [];
  static const int _maxTrailLength = 8;

  // Thrust flame
  double _thrustFlicker = 0;

  // Shield power-up
  bool _shieldActive = false;

  // Countdown blocking
  bool _countdownActive = false;

  // Ship color (from cosmetics)
  final Color _color;

  // Event listener references for cleanup
  late final void Function(JoystickDirectionEvent) _joystickListener;
  late final void Function(ThrustEvent) _thrustListener;
  late final void Function(DashEvent) _dashListener;
  late final void Function(PowerUpActiveEvent) _powerUpListener;
  late final void Function(CountdownStartedEvent) _countdownStartListener;
  late final void Function(CountdownFinishedEvent) _countdownEndListener;

  Ship({Color? color}) : _color = color ?? GameConfig.shipColor {
    size = Vector2(_shipHalfWidth * 2, _shipHeight);
    anchor = Anchor.center;
  }

  /// Current velocity (read-only for testing).
  Vector2 get velocity => _velocity;

  /// Whether ship is currently invulnerable.
  bool get invulnerable => _invulnerable;

  @override
  Future<void> onLoad() async {
    // Build ship shape path (triangle, nose pointing up)
    _shipPath = Path()
      ..moveTo(0, -_shipHeight / 2) // Nose (top center)
      ..lineTo(-_shipHalfWidth, _shipHeight / 2) // Bottom left
      ..lineTo(_shipHalfWidth, _shipHeight / 2) // Bottom right
      ..close();

    // Pre-allocate neon paints
    final paints = NeonRenderer.createNeonPaints(
      color: _color,
      glowRadius: GameConfig.glowRadius,
      glowOpacity: GameConfig.glowOpacity,
    );
    _glowPaint = paints.glow;
    _solidPaint = paints.solid;

    // Add hitbox for collision detection
    await add(PolygonHitbox([
      Vector2(0, -_shipHeight / 2),
      Vector2(-_shipHalfWidth, _shipHeight / 2),
      Vector2(_shipHalfWidth, _shipHeight / 2),
    ]));

    // Subscribe to events
    _joystickListener = _onJoystickDirection;
    _thrustListener = _onThrust;
    _dashListener = _onDash;
    _powerUpListener = (e) {
      if (e.type == PowerUpType.shield) _shieldActive = e.active;
    };
    _countdownStartListener = (_) => _countdownActive = true;
    _countdownEndListener = (_) => _countdownActive = false;
    eventBus.on<JoystickDirectionEvent>(_joystickListener);
    eventBus.on<ThrustEvent>(_thrustListener);
    eventBus.on<DashEvent>(_dashListener);
    eventBus.on<PowerUpActiveEvent>(_powerUpListener);
    eventBus.on<CountdownStartedEvent>(_countdownStartListener);
    eventBus.on<CountdownFinishedEvent>(_countdownEndListener);

    // Start invulnerable
    _invulnerable = true;
    _invulnerableTimer = _invulnerableDuration;
  }

  @override
  void onRemove() {
    eventBus.off<JoystickDirectionEvent>(_joystickListener);
    eventBus.off<ThrustEvent>(_thrustListener);
    eventBus.off<DashEvent>(_dashListener);
    eventBus.off<PowerUpActiveEvent>(_powerUpListener);
    eventBus.off<CountdownStartedEvent>(_countdownStartListener);
    eventBus.off<CountdownFinishedEvent>(_countdownEndListener);
    super.onRemove();
  }

  void _onJoystickDirection(JoystickDirectionEvent event) {
    if (_countdownActive) return;
    if (event.isActive) {
      angle = event.angle;
    }
  }

  void _onThrust(ThrustEvent event) {
    if (_countdownActive) return;
    _isThrusting = event.isThrusting;
  }

  void _onDash(DashEvent event) {
    if (_countdownActive) return;
    if (_isDashing) return;
    _isDashing = true;
    _invulnerable = true;
    _dashTimer = GameConfig.dashDuration;
    _trailPositions.clear();

    // Instant velocity boost in facing direction
    final dashSpeed = GameConfig.shipMaxVelocity * 3;
    _velocity.x = sin(angle) * dashSpeed;
    _velocity.y = -cos(angle) * dashSpeed;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Asteroid && !_invulnerable) {
      eventBus.emit(ShipDestroyedEvent(position.clone()));
      removeFromParent();
    } else if (other is Asteroid && _isDashing) {
      other.destroy(byDash: true);
    } else if (other is ExplosiveAsteroid && !_invulnerable) {
      eventBus.emit(ShipDestroyedEvent(position.clone()));
      removeFromParent();
    } else if (other is ExplosiveAsteroid && _isDashing) {
      other.destroy(byDash: true);
    } else if (other is MagneticAsteroid && !_invulnerable) {
      eventBus.emit(ShipDestroyedEvent(position.clone()));
      removeFromParent();
    } else if (other is MagneticAsteroid && _isDashing) {
      other.destroy(byDash: true);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update dash
    if (_isDashing) {
      _dashTimer -= dt;
      // Record trail
      _trailPositions.insert(0, position.clone());
      if (_trailPositions.length > _maxTrailLength) {
        _trailPositions.removeLast();
      }
      if (_dashTimer <= 0) {
        _isDashing = false;
        // Keep invulnerable briefly after dash
        _invulnerableTimer = 0.3;
      }
    } else {
      // Fade trail
      if (_trailPositions.isNotEmpty) {
        _trailPositions.removeLast();
      }
    }

    // Update invulnerability (only non-dash invulnerability)
    if (_invulnerable && !_isDashing && !_shieldActive) {
      _invulnerableTimer -= dt;
      if (_invulnerableTimer <= 0) {
        _invulnerable = false;
      }
    }

    // Shield keeps invulnerable
    if (_shieldActive && !_invulnerable) {
      _invulnerable = true;
    }

    // Thrust flame animation
    if (_isThrusting) {
      _thrustFlicker += dt * 20;
    }

    // Apply thrust in ship's facing direction (reduced during dash)
    if (_isThrusting && !_isDashing) {
      final dx = sin(angle) * GameConfig.shipAcceleration * dt;
      final dy = -cos(angle) * GameConfig.shipAcceleration * dt;
      _velocity.x += dx;
      _velocity.y += dy;

      // Clamp velocity to max
      if (_velocity.length > GameConfig.shipMaxVelocity) {
        _velocity.normalize();
        _velocity.scale(GameConfig.shipMaxVelocity);
      }
    }

    // Apply drag (space inertia — gradual slowdown)
    _velocity.scale(_isDashing ? 0.995 : GameConfig.shipDrag);

    // Stop very small velocities to avoid infinite tiny drifting
    if (_velocity.length < 0.5) {
      _velocity.setZero();
    }

    // Apply velocity to position
    position.x += _velocity.x * dt;
    position.y += _velocity.y * dt;

    // Emit position for projectile system
    eventBus.emit(ShipFireRequestEvent(position, angle));

    // Wrap-around screen edges
    _wrapAround();
  }

  void _wrapAround() {
    final gameSize = game.size;

    if (position.x < -_shipHalfWidth) {
      position.x = gameSize.x + _shipHalfWidth;
    } else if (position.x > gameSize.x + _shipHalfWidth) {
      position.x = -_shipHalfWidth;
    }

    if (position.y < -_shipHeight / 2) {
      position.y = gameSize.y + _shipHeight / 2;
    } else if (position.y > gameSize.y + _shipHeight / 2) {
      position.y = -_shipHeight / 2;
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw dash trail
    if (_trailPositions.isNotEmpty) {
      final trailPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      for (int i = 0; i < _trailPositions.length; i++) {
        final t = _trailPositions[i];
        final opacity = (1.0 - i / _maxTrailLength) * 0.5;
        trailPaint.color = _color.withValues(alpha: opacity);
        final dx = t.x - position.x;
        final dy = t.y - position.y;
        canvas.save();
        canvas.translate(size.x / 2 + dx, size.y / 2 + dy);
        canvas.drawPath(_shipPath, trailPaint);
        canvas.restore();
      }
    }

    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);

    // Blink when invulnerable (but not during dash or shield)
    if (_invulnerable && !_isDashing && !_shieldActive) {
      final show =
          ((_invulnerableTimer * 8).toInt() % 2 == 0); // 8Hz blink
      if (!show) {
        canvas.restore();
        return;
      }
    }

    // Thrust flame behind ship
    if (_isThrusting && !_isDashing) {
      final flicker = (sin(_thrustFlicker) * 0.3 + 0.7);
      final flameLen = 8.0 + flicker * 10.0;
      final flamePaint = Paint()
        ..color = Color.fromARGB(
          (180 * flicker).toInt(), 255, 140, 0,
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      final flamePath = Path()
        ..moveTo(-4, _shipHeight / 2)
        ..lineTo(0, _shipHeight / 2 + flameLen)
        ..lineTo(4, _shipHeight / 2);
      canvas.drawPath(flamePath, flamePaint);
      // Inner white core
      final corePaint = Paint()
        ..color = Color.fromARGB(
          (200 * flicker).toInt(), 255, 255, 200,
        );
      final corePath = Path()
        ..moveTo(-2, _shipHeight / 2)
        ..lineTo(0, _shipHeight / 2 + flameLen * 0.6)
        ..lineTo(2, _shipHeight / 2);
      canvas.drawPath(corePath, corePaint);
    }

    NeonRenderer.drawNeonPath(canvas, _shipPath, _glowPaint, _solidPaint);

    // Shield ring
    if (_shieldActive) {
      final shieldPaint = Paint()
        ..color = const Color(0x6600AAFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset.zero, _shipHeight * 0.7, shieldPaint);
      canvas.drawCircle(
        Offset.zero,
        _shipHeight * 0.7,
        Paint()
          ..color = const Color(0xFF00AAFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }

    canvas.restore();
  }
}
