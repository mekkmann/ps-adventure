import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/game_components/background_tile.dart';
import 'package:pixel_adventure/game_components/checkpoint.dart';
import 'package:pixel_adventure/game_components/collision_block.dart';
import 'package:pixel_adventure/game_components/fire.dart';
import 'package:pixel_adventure/game_components/fruit.dart';
import 'package:pixel_adventure/game_components/fruit_display.dart';
import 'package:pixel_adventure/game_components/moving_platform.dart';
import 'package:pixel_adventure/game_components/rock_head.dart';
import 'package:pixel_adventure/game_components/saw.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

import '../actors/player.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  Level({required this.levelName, required this.player});
  final String levelName;
  final Player player;
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];
  List<MovingPlatform> movingPlatforms = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);

    _scrollingBackground();

    _spawnObjects();

    _addCollisions();
    game.fruitDisplay.updateScore();
    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');

    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('Background Color');

      final backgroundTile = BackgroundTile(
          color: backgroundColor ?? 'Gray', position: Vector2(0, 0));
      add(backgroundTile);
    }
  }

  void _spawnObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Collected Fruits':

            // Just a placeholder for the level names
            add(TextComponent(text: game.levelNames[game.currentLevelIndex]));

            // Actual FruitDisplay ("Collected Fruits")
            game.fruitDisplay = FruitDisplay(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(game.fruitDisplay);
            // Fake fruit for UI
            final fakeFruit = SpriteComponent.fromImage(
              game.images.fromCache('Items/Fruits/Apple.png'),
              position: Vector2(spawnPoint.x + 40, spawnPoint.y - 15),
              size: Vector2(64, 64),
              srcPosition: Vector2.zero(),
              srcSize: Vector2.all(32),
            );
            add(fakeFruit);
            break;
          case 'Moving Platform':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offsetNeg = spawnPoint.properties.getValue('offsetNeg');
            final offsetPos = spawnPoint.properties.getValue('offsetPos');
            MovingPlatform movPlat = MovingPlatform(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              isVertical: isVertical,
              offNeg: offsetNeg,
              offPos: offsetPos,
            );
            add(movPlat);
            movingPlatforms.add(movPlat);
            break;
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            player.scale.x = 1;
            add(player);
            break;
          case 'Rock Head':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offsetNeg = spawnPoint.properties.getValue('offsetNeg');
            final offsetPos = spawnPoint.properties.getValue('offsetPos');
            final rockHead = RockHead(
                isVertical: isVertical,
                offNeg: offsetNeg,
                offPos: offsetPos,
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2(spawnPoint.width, spawnPoint.height));
            add(rockHead);
            break;
          case 'Fruit':
            final fruit = Fruit(
                fruit: spawnPoint.name,
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2(spawnPoint.width, spawnPoint.height));
            add(fruit);
            game.currentLevelFruitsTotal++;
            break;
          case 'Saw':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offsetNeg = spawnPoint.properties.getValue('offsetNeg');
            final offsetPos = spawnPoint.properties.getValue('offsetPos');
            final isStatic = spawnPoint.properties.getValue('isStatic');
            final saw = Saw(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              isVertical: isVertical,
              isStatic: isStatic,
              offNeg: offsetNeg,
              offPos: offsetPos,
            );
            add(saw);
            break;
          case 'Fire':
            final fire = Fire(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(fire);
            break;
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(checkpoint);
            break;
          default:
        }
      }
      player.movingPlatforms = movingPlatforms;
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }
}
