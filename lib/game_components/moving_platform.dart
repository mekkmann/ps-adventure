import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/actors/player.dart';
import 'package:pixel_adventure/game_components/custom_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class MovingPlatform extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  MovingPlatform({
    position,
    size,
    this.isVertical = false,
    this.offNeg = 0,
    this.offPos = 0,
  }) : super(position: position, size: size);
  bool isVertical;
  final double offNeg;
  final double offPos;
  static const double animationSpeed = 0.05;
  static const double moveSpeed = 50;
  static const tileSize = 16;
  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;
  final CustomHitbox hitbox =
      CustomHitbox(offsetX: 0, offsetY: 2, width: 32, height: 5);

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    priority = -1;
    add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.active));
    if (isVertical) {
      rangePos = position.y + offPos * tileSize;
      rangeNeg = position.y - offNeg * tileSize;
    } else {
      rangePos = position.x + offPos * tileSize;
      rangeNeg = position.x - offNeg * tileSize;
    }

    SpriteAnimation phAnim = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Platforms/Brown On (32x8).png'),
      SpriteAnimationData.sequenced(
          amount: 8, stepTime: animationSpeed, textureSize: Vector2(32, 8)),
    );

    animation = phAnim.reversed();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isVertical) {
      _moveVertically(dt);
    } else {
      _moveHorizontally(dt);
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

  void playerFollow(Player player, double dt) {
    if (moveDirection == 1) {
      player.x += 50 * dt;
    } else {
      player.x += -50 * dt;
    }
  }
}
