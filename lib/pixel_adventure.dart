import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/actors/player.dart';
import 'package:pixel_adventure/game_components/jump_button.dart';
import 'package:pixel_adventure/game_components/reset_button.dart';
import 'package:pixel_adventure/game_components/fruit_display.dart';
import 'package:pixel_adventure/levels/level.dart';

const startingLevel = 0;

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  PixelAdventure({this.chosenCharacter = 'Ninja Frog'});

  @override
  Color backgroundColor() => const Color(0xFF211F30);
  // Color backgroundColor() => const Color.fromARGB(0, 0, 0, 0);
  String chosenCharacter;
  late CameraComponent cam;
  late Player player;
  late JoystickComponent joystick;
  late ButtonComponent jumpButton;
  // build with different true/false for mobile or pc
  bool showControls = true;
  List<String> levelNames = [
    // 'Level-1-2', //test level is always on top
    'Level-0-1',
    'Level-0-2',
    'Level-0-3',
    'Level-0-4',
    'Level-0-5',
    'Level-1-1',
  ];
  late Level currentLevel;

  // 0 is Level-0-1 (or level-x-x in testing)
  int currentLevelIndex = startingLevel;

  late FruitDisplay fruitDisplay;
  int currentLevelFruitsTotal = 0;
  int currentLevelFruitsCollected = 0;

  @override
  FutureOr<void> onLoad() async {
    // Load all images into cache
    await images.loadAllImages();
    player = Player(character: chosenCharacter);
    _loadLevel();

    if (showControls) {
      addJoystick();
      add(JumpButton());
      add(ResetButton());
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) {
      updateJoystick();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 10,
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );
    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
        break;
    }
  }

  void loadNextLevel() {
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      // show game credits
    }
  }

  void _loadLevel() async {
    currentLevelFruitsCollected = 0;
    currentLevelFruitsTotal = 0;
    await Future.delayed(const Duration(seconds: 1), () async {
      if (currentLevelIndex > 0) {
        currentLevel.removeFromParent();
      }
      currentLevel = Level(
        levelName: levelNames[currentLevelIndex],
        player: player,
      );
      cam = CameraComponent.withFixedResolution(
          world: currentLevel, width: 640, height: 360);
      cam.viewfinder.anchor = Anchor.topLeft;

      addAll([cam, currentLevel]);
    });
  }
}
