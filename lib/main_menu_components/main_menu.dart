import 'package:flutter/material.dart';
import 'package:pixel_adventure/main_menu_components/character_select.dart';
import 'package:pixel_adventure/main_menu_components/start_game.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  String character = 'Mask Dude';

  void setCharacter(String character) {
    this.character = character;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211F30),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Text(
                'P\'s Adventure',
                style: TextStyle(
                    fontFamily: 'IndieFlower',
                    fontSize: 50,
                    shadows: [
                      Shadow(
                          blurRadius: 10,
                          color: Colors.white,
                          offset: Offset(0, 0))
                    ]),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 5,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => StartGame(
                        chosenCharacter: character,
                      ),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    'Play',
                    style: TextStyle(fontFamily: 'IndieFlower', fontSize: 30),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 5,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CharacterSelect(
                        callbackFunc: setCharacter,
                      ),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    'Character Select',
                    style: TextStyle(fontFamily: 'IndieFlower', fontSize: 30),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 5,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to options
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text('Options',
                      style:
                          TextStyle(fontFamily: 'IndieFlower', fontSize: 30)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
