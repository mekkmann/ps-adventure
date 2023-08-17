import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class MenuButton extends SpriteComponent
    with HasGameRef<PixelAdventure>, TapCallbacks {
  MenuButton();
  final margin = 32;
  final buttonSize = 64;

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/MenuButton.png'));
    position = Vector2(
      game.size.x - margin - buttonSize,
      game.size.y - margin - (buttonSize * 6),
    );
    priority = 10;

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    // game.overlays.remove(overlayName)
    super.onTapDown(event);
  }
}
