import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:asteroids_neon/app.dart';
import 'package:asteroids_neon/background/background_layer.dart';
import 'package:asteroids_neon/hud/title_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AsteroidsNeonGame', () {
    testWithGame<AsteroidsNeonGame>(
      'loads BackgroundLayer and TitleScreen on start',
      AsteroidsNeonGame.new,
      (game) async {
        expect(
          game.children.whereType<BackgroundLayer>().length,
          1,
        );
        expect(
          game.children.whereType<TitleScreen>().length,
          1,
        );
      },
    );
  });
}
