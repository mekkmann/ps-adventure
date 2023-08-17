import 'package:flutter/material.dart';

class CharacterSelect extends StatelessWidget {
  const CharacterSelect({super.key, required this.callbackFunc});

  final Function callbackFunc;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211F30),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width / 5,
              child: ElevatedButton(
                onPressed: () => callbackFunc('Virtual Guy'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    'Virtual Guy',
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
                onPressed: () => callbackFunc('Pink Man'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    'Pink Man',
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
                onPressed: () => callbackFunc('Ninja Frog'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    'Ninja Frog',
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
                onPressed: () => callbackFunc('Mask Dude'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text('Mask Dude',
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
