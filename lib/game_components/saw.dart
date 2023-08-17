import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Saw extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  Saw({
    position,
    size,
    this.isVertical = false,
    this.isStatic = true,
    this.offNeg = 0,
    this.offPos = 0,
  }) : super(position: position, size: size);

  bool isVertical;
  bool isStatic;
  final double offNeg;
  final double offPos;
  static const double sawSpinSpeed = 0.05;
  static const double moveSpeed = 50;
  static const tileSize = 16;
  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    priority = -1;
    add(CircleHitbox());
    if (!isStatic) {
      if (isVertical) {
        rangePos = position.y + offPos * tileSize;
        rangeNeg = position.y - offNeg * tileSize;
      } else {
        rangePos = position.x + offPos * tileSize;
        rangeNeg = position.x - offNeg * tileSize;
      }
    }

    SpriteAnimation phAnim = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Saw/On (38x38).png'),
      SpriteAnimationData.sequenced(
          amount: 8, stepTime: sawSpinSpeed, textureSize: Vector2.all(38)),
    );

    animation = phAnim.reversed();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!isStatic) {
      if (isVertical) {
        _moveVertically(dt);
      } else {
        _moveHorizontally(dt);
      }
    }
    super.update(dt);
  }

  void _moveVertically(double dt) {
    if (position.y >= rangePos) {
      moveDirection = -1;
    } else if (position.y <= rangeNeg) {
      moveDirection = 1;
    }
    position.y += moveDirection * moveSpeed * dt;
  }

  void _moveHorizontally(double dt) {
    if (position.x >= rangePos) {
      moveDirection = -1;
    } else if (position.x <= rangeNeg) {
      moveDirection = 1;
    }
    position.x += moveDirection * moveSpeed * dt;
  }
}
