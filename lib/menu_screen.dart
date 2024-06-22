import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fruits_memory/memory_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuScreen extends StatefulWidget {
  final SharedPreferences prefs;

  const MenuScreen({required this.prefs, Key? key}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isSoundOn = true;

  void _playBackgroundMusic() async {
    await audioPlayer.play(AssetSource('background.wav'));
    audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void _toggleSound() {
    setState(() {
      isSoundOn = !isSoundOn;
      if (isSoundOn) {
        _playBackgroundMusic();
      } else {
        audioPlayer.stop();
      }
    });
  }

  @override
  void dispose() {
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Memory Game',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 50.0,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MemoryGame(prefs: widget.prefs)),
                        );
                      },
                      icon: const Icon(
                        Icons.play_circle_filled,
                        color: Colors.white,
                        size: 50.0,
                      ),
                      label: const Text(
                        'Start Game',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          fixedSize: const Size(230, 60)),
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      'Good luck!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 20.0,
                right: 20.0,
                child: IconButton(
                  onPressed: _toggleSound,
                  icon: Icon(
                    isSoundOn ? Icons.volume_up : Icons.volume_off,
                    color: Colors.white,
                    size: 30.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
