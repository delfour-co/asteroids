import 'package:flame/components.dart';

import '../core/arcade_events.dart';
import '../core/event_bus.dart';
import '../core/game_state.dart';
import '../core/session_stats.dart';
import '../input/fire_button.dart';
import '../powerups/powerup.dart';
import '../powerups/powerup_manager.dart';
import 'projectile.dart';

/// Event emitted when the ship requests to fire.
/// Contains the ship's position and angle at fire time.
class ShipFireRequestEvent {
  final Vector2 position;
  final double angle;
  ShipFireRequestEvent(this.position, this.angle);
}

/// Manages projectile creation and lifecycle.
///
/// Listens to ShipFireRequestEvent to spawn projectiles.
/// Handles fire rate limiting.
class ProjectileManager extends Component {
  double _fireCooldown = 0;
  static const double _fireRate = 0.15; // seconds between shots

  bool _isFiring = false;
  bool _gameOver = false;
  bool _multiShot = false;
  bool _countdownActive = false;
  Vector2? _lastShipPos;
  double _lastShipAngle = 0;

  // Event listeners
  late final void Function(FireEvent) _fireListener;
  late final void Function(ShipFireRequestEvent) _fireRequestListener;
  late final void Function(GameOverEvent) _gameOverListener;
  late final void Function(PowerUpActiveEvent) _powerUpListener;
  late final void Function(CountdownStartedEvent) _countdownStartListener;
  late final void Function(CountdownFinishedEvent) _countdownEndListener;

  @override
  Future<void> onLoad() async {
    _fireListener = (e) => _isFiring = e.isFiring;
    _fireRequestListener = _onFireRequest;
    _gameOverListener = (_) => _gameOver = true;
    _powerUpListener = (e) {
      if (e.type == PowerUpType.multiShot) _multiShot = e.active;
    };
    _countdownStartListener = (_) => _countdownActive = true;
    _countdownEndListener = (_) => _countdownActive = false;
    eventBus.on<FireEvent>(_fireListener);
    eventBus.on<ShipFireRequestEvent>(_fireRequestListener);
    eventBus.on<GameOverEvent>(_gameOverListener);
    eventBus.on<PowerUpActiveEvent>(_powerUpListener);
    eventBus.on<CountdownStartedEvent>(_countdownStartListener);
    eventBus.on<CountdownFinishedEvent>(_countdownEndListener);
  }

  @override
  void onRemove() {
    eventBus.off<FireEvent>(_fireListener);
    eventBus.off<ShipFireRequestEvent>(_fireRequestListener);
    eventBus.off<GameOverEvent>(_gameOverListener);
    eventBus.off<PowerUpActiveEvent>(_powerUpListener);
    eventBus.off<CountdownStartedEvent>(_countdownStartListener);
    eventBus.off<CountdownFinishedEvent>(_countdownEndListener);
    super.onRemove();
  }

  void _onFireRequest(ShipFireRequestEvent event) {
    _lastShipPos = event.position;
    _lastShipAngle = event.angle;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_gameOver || _countdownActive) return;

    if (_fireCooldown > 0) {
      _fireCooldown -= dt;
    }

    if (_isFiring && _fireCooldown <= 0 && _lastShipPos != null) {
      _spawnProjectile();
      _fireCooldown = _fireRate;
    }
  }

  void _spawnProjectile() {
    final pos = _lastShipPos!;
    final angle = _lastShipAngle;

    final projectile = Projectile()..init(pos: pos, shipAngle: angle);
    parent?.add(projectile);
    eventBus.emit(ShotFiredEvent());

    // Multi-shot: fire two extra projectiles at slight angles
    if (_multiShot) {
      const spread = 0.2; // ~11 degrees
      final left = Projectile()..init(pos: pos, shipAngle: angle - spread);
      final right = Projectile()..init(pos: pos, shipAngle: angle + spread);
      parent?.add(left);
      parent?.add(right);
      eventBus.emit(ShotFiredEvent());
      eventBus.emit(ShotFiredEvent());
    }
  }
}
