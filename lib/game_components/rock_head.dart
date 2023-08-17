import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/game_components/custom_hitbox.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum RockHeadState {
  blink,
  bottomHit,
  leftHit,
  rightHit,
  topHit,
}

class RockHead extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  RockHead({
    position,
    size,
    this.isVertical = false,
    this.offNeg = 0,
    this.offPos = 0,
  }) : super(position: position, size: size);
  late final SpriteAnimation blinkAnimation;
  late final SpriteAnimation bottomHitAnimation;
  late final SpriteAnimation leftHitAnimation;
  late final SpriteAnimation rightHitAnimation;
  late final SpriteAnimation topHitAnimation;

  // TODO : add capability to stand on top of the rock head

  bool isVertical;
  final double offNeg;
  final double offPos;
  static const double animationSpeed = 0.25;
  double moveSpeed = 150; // starts with fallSpeed
  static const double fallSpeed = 150;
  static const double resetSpeed = 50;
  static const tileSize = 16;
  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;
  final CustomHitbox customHitbox =
      CustomHitbox(offsetX: 3, offsetY: 3, width: 25, height: 25);

  //TODO : Refactor code for hitbox
  RectangleHitbox hitbox = RectangleHitbox();

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    // debugMode = true;
    priority = 1;
    hitbox = RectangleHitbox(
      position: Vector2(customHitbox.offsetX, customHitbox.offsetY),
      size: Vector2(customHitbox.width, customHitbox.height),
      collisionType: CollisionType.active,
    );
    add(hitbox);
    if (isVertical) {
      rangePos = position.y + customHitbox.offsetY + offPos * tileSize;
      rangeNeg = position.y - customHitbox.offsetY - offNeg * tileSize;
    } else {
      rangePos = position.x + offPos * tileSize;
      rangeNeg = position.x - offNeg * tileSize;
    }
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

// TODO : Refactor animation position and stop of movement at any hit
  void _moveVertically(double dt) async {
    if (position.y >= rangePos) {
      current = RockHeadState.bottomHit;
      await animationTicker?.completed;
      position.y = rangePos;
      animationTicker?.reset();
      current = RockHeadState.blink;
      hitbox.collisionType = CollisionType.inactive;
      moveSpeed = resetSpeed;
      moveDirection = -1;
    } else if (position.y <= rangeNeg) {
      hitbox.collisionType = CollisionType.active;
      moveSpeed = fallSpeed;
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

  SpriteAnimation _spriteAnimation(String state) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Rock Head/$state (42x42).png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: animationSpeed,
        textureSize: Vector2.all(42),
      ),
    );
  }

  void _loadAllAnimations() {
    blinkAnimation = _spriteAnimation('Blink');
    bottomHitAnimation = _spriteAnimation('Bottom Hit')
      ..loop = false
      ..stepTime = 0.1;
    leftHitAnimation = _spriteAnimation('Left Hit')..loop = false;
    rightHitAnimation = _spriteAnimation('Right Hit')..loop = false;
    topHitAnimation = _spriteAnimation('Top Hit')..loop = false;

    // map of all animations
    animations = {
      RockHeadState.blink: blinkAnimation,
      RockHeadState.bottomHit: bottomHitAnimation,
      RockHeadState.leftHit: leftHitAnimation,
      RockHeadState.rightHit: rightHitAnimation,
      RockHeadState.topHit: topHitAnimation,
    };
    // set current animation
    current = RockHeadState.blink;
  }
}
