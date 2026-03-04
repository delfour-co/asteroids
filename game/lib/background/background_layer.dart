import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'nebula_layer.dart';
import 'starfield.dart';

/// Background layer containing the starfield and nebula.
///
/// First layer in the hierarchy — rendered behind everything else.
class BackgroundLayer extends PositionComponent
    with HasGameReference<FlameGame> {
  @override
  Future<void> onLoad() async {
    size = game.size;
    await add(Starfield());
    await add(NebulaLayer());
  }
}
