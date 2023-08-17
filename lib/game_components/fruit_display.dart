import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class FruitDisplay extends TextComponent with HasGameRef<PixelAdventure> {
  FruitDisplay({position, size}) : super(position: position, size: size);

  void updateScore() {
    text =
        '${game.currentLevelFruitsCollected} / ${game.currentLevelFruitsTotal}';
  }
}
