import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class ResetButton extends SpriteComponent
    with HasGameRef<PixelAdventure>, TapCallbacks {
  ResetButton();
  final margin = 32;
  final buttonSize = 64;

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/ResetButton.png'));
    position = Vector2(
      game.size.x - margin - buttonSize,
      game.size.y - margin - (buttonSize * 3),
    );
    priority = 10;

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.respawn();
    super.onTapDown(event);
  }
}
