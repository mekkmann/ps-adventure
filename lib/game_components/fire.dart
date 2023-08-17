import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Fire extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  Fire({
    position,
    size,
  }) : super(position: position, size: size);

  static const double animationSpeed = 0.1;

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    priority = -1;
    add(RectangleHitbox());

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Fire/On (16x32).png'),
      SpriteAnimationData.sequenced(
          amount: 3, stepTime: animationSpeed, textureSize: Vector2(16, 32)),
    );

    return super.onLoad();
  }
}
