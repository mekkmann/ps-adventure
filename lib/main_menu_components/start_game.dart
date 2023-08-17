import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class StartGame extends StatelessWidget {
  StartGame({super.key, required this.chosenCharacter});

  String chosenCharacter;
  PixelAdventure pixelAdventure = PixelAdventure();

  // TODO : Figure out how to return to main menu
  @override
  Widget build(BuildContext context) {
    pixelAdventure.chosenCharacter = chosenCharacter;
    return GameWidget(game: pixelAdventure);
  }
}
