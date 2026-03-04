import 'package:asteroids_neon/asteroids/asteroid.dart';
import 'package:asteroids_neon/core/event_bus.dart';
import 'package:asteroids_neon/core/game_config.dart';
import 'package:asteroids_neon/core/game_state.dart';
import 'package:asteroids_neon/ship/ship.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    eventBus.clear();
    SharedPreferences.setMockInitialValues({});
  });

  group('GameState scoring', () {
    test('initial score is 0', () async {
      final state = GameState();
      await state.init();
      expect(state.score, 0);
      state.dispose();
    });

    test('score increases on asteroid destroyed', () async {
      final state = GameState();
      await state.init();
      eventBus.emit(AsteroidDestroyedEvent(
        Vector2.zero(),
        AsteroidSize.large,
      ));
      expect(state.score, AsteroidSize.large.points);
      state.dispose();
    });

    test('score accumulates across multiple asteroids', () async {
      final state = GameState();
      await state.init();
      eventBus.emit(AsteroidDestroyedEvent(
        Vector2.zero(),
        AsteroidSize.large,
      ));
      eventBus.emit(AsteroidDestroyedEvent(
        Vector2.zero(),
        AsteroidSize.small,
      ));
      expect(state.score, AsteroidSize.large.points + AsteroidSize.small.points);
      state.dispose();
    });

    test('emits ScoreChangedEvent on score change', () async {
      final state = GameState();
      await state.init();
      int? lastScore;
      eventBus.on<ScoreChangedEvent>((e) => lastScore = e.score);

      eventBus.emit(AsteroidDestroyedEvent(
        Vector2.zero(),
        AsteroidSize.medium,
      ));
      expect(lastScore, AsteroidSize.medium.points);
      state.dispose();
    });
  });

  group('GameState lives', () {
    test('initial lives equals startingLives', () async {
      final state = GameState();
      await state.init();
      expect(state.lives, GameConfig.startingLives);
      state.dispose();
    });

    test('lives decrease on ship destroyed', () async {
      final state = GameState();
      await state.init();
      eventBus.emit(ShipDestroyedEvent(Vector2.zero()));
      expect(state.lives, GameConfig.startingLives - 1);
      state.dispose();
    });

    test('emits GameOverEvent when lives reach 0', () async {
      final state = GameState();
      await state.init();
      bool gameOver = false;
      eventBus.on<GameOverEvent>((_) => gameOver = true);

      for (int i = 0; i < GameConfig.startingLives; i++) {
        eventBus.emit(ShipDestroyedEvent(Vector2.zero()));
      }
      expect(gameOver, true);
      state.dispose();
    });
  });

  group('GameState extra life', () {
    test('awards extra life at extraLifeScore threshold', () async {
      final state = GameState();
      await state.init();
      bool gotExtraLife = false;
      eventBus.on<ExtraLifeEvent>((_) => gotExtraLife = true);

      // Score enough for extra life (100 points per small asteroid)
      final needed =
          (GameConfig.extraLifeScore / AsteroidSize.small.points).ceil();
      for (int i = 0; i < needed; i++) {
        eventBus.emit(AsteroidDestroyedEvent(
          Vector2.zero(),
          AsteroidSize.small,
        ));
      }

      expect(gotExtraLife, true);
      expect(state.lives, GameConfig.startingLives + 1);
      state.dispose();
    });
  });

  group('GameState high score', () {
    test('saves high score on game over', () async {
      final state = GameState();
      await state.init();

      // Score some points
      eventBus.emit(AsteroidDestroyedEvent(
        Vector2.zero(),
        AsteroidSize.large,
      ));
      final expectedScore = AsteroidSize.large.points;

      // Trigger game over
      for (int i = 0; i < GameConfig.startingLives; i++) {
        eventBus.emit(ShipDestroyedEvent(Vector2.zero()));
      }

      expect(state.highScore, expectedScore);
      state.dispose();
    });

    test('loads persisted high score on init', () async {
      SharedPreferences.setMockInitialValues({'high_score': 5000});
      final state = GameState();
      await state.init();
      expect(state.highScore, 5000);
      state.dispose();
    });
  });
}
