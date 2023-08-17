import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/game_components/checkpoint.dart';
import 'package:pixel_adventure/game_components/collision_block.dart';
import 'package:pixel_adventure/game_components/custom_hitbox.dart';
import 'package:pixel_adventure/game_components/fire.dart';
import 'package:pixel_adventure/game_components/fruit.dart';
import 'package:pixel_adventure/game_components/moving_platform.dart';
import 'package:pixel_adventure/game_components/rock_head.dart';
import 'package:pixel_adventure/game_components/saw.dart';
import 'package:pixel_adventure/game_components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState {
  idle,
  running,
  jumping,
  falling,
  hit,
  appearing,
  disappearing
}

// GroupComponent is a good way of using a lot of animations/states and switching between them
class Player extends SpriteAnimationGroupComponent
    with HasGameReference<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  Player({this.character = 'Ninja Frog', position}) : super(position: position);

  String character;
  final double stepTime = 0.05; // 50ms/20fps
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

  final double _gravity = 19.6;
  final double _jumpForce = 350;
  final double _terminalVelocity = 300;
  double horizontalMovement = 0;
  double moveSpeed = 125;
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool reachedCheckpoint = false;
  List<CollisionBlock> collisionBlocks = [];
  List<MovingPlatform> movingPlatforms = [];
  CustomHitbox hitbox =
      CustomHitbox(offsetX: 10, offsetY: 4, width: 14, height: 28);
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    startingPosition = Vector2(position.x, position.y);
    add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height)));
    // debugMode = true;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    // if (!gotHit && !reachedCheckpoint) {
    //   _updatePlayerMovement(dt);
    //   _updatePlayerState();
    //   _checkHorizontalCollisions();
    //   _applyGravity(dt);
    //   _checkVerticalCollisions(dt);
    // }
    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotHit && !reachedCheckpoint) {
        _updatePlayerMovement(fixedDeltaTime);
        _updatePlayerState();
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions(fixedDeltaTime);
      }
      accumulatedTime -= fixedDeltaTime;
    }
    // super.update(dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;

    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);
    final isRKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyR);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;
    isRKeyPressed ? respawn() : null;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckpoint) {
      if (other is Fruit) {
        other.collidedWithPlayer();
        game.fruitDisplay.updateScore();
      }
      if (other is Saw || other is Fire || other is RockHead) {
        respawn();
      }
      if (other is Checkpoint &&
          game.currentLevelFruitsCollected == game.currentLevelFruitsTotal) {
        _reachedCheckpoint();
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);
    jumpingAnimation = _spriteAnimation('Jump', 1);
    fallingAnimation = _spriteAnimation('Fall', 1);
    // ..loop targets the specific return
    hitAnimation = _spriteAnimation('Hit', 7)..loop = false;
    appearingAnimation = _specialSpriteAnimation('Appearing', 7)..loop = false;
    disappearingAnimation = _specialSpriteAnimation('Desappearing', 7);

    // map of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
    };
    // set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _specialSpriteAnimation(String state, int amountOfFrames) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amountOfFrames,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
      ),
    );
  }

  SpriteAnimation _spriteAnimation(String state, int amountOfFrames) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amountOfFrames,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    }
    if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }
    // check if running, set to running
    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;

    // check if falling, set to falling
    // compare against _gravity because then we've fallen more than one frame
    if (velocity.y > _gravity) playerState = PlayerState.falling;

    // check if jumping, set to jumping
    if (velocity.y < 0) playerState = PlayerState.jumping;

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) _playerJump(dt);
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions(double dt) {
    for (var movPlat in movingPlatforms) {
      if (checkMovingPlatformCollision(this, movPlat)) {
        if (velocity.y > 0) {
          velocity.y = 0;
          position.y = movPlat.y - hitbox.height - movPlat.hitbox.offsetY;
          isOnGround = true;

          if (velocity.x == 0) {
            movPlat.playerFollow(this, dt);
          }
          break;
        }
      }
    }
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
            break;
          }
        }
      }
    }
  }

  void respawn() async {
    gotHit = true;
    current = PlayerState.hit;

    await animationTicker?.completed;
    animationTicker?.reset();

    scale.x = 1;
    position = startingPosition - Vector2.all(32);
    current = PlayerState.appearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    velocity = Vector2.zero();
    position = startingPosition;
    _updatePlayerState();

    Future.delayed(const Duration(milliseconds: 400), () => gotHit = false);
  }

  void _reachedCheckpoint() {
    reachedCheckpoint = true;
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }
    current = PlayerState.disappearing;
    Future.delayed(const Duration(milliseconds: 350), () {
      reachedCheckpoint = false;
      removeFromParent();
      Future.delayed(const Duration(seconds: 3), () {
        game.loadNextLevel();
      });
    });
  }
}
