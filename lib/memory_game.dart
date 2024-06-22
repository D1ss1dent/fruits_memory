import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryGame extends StatefulWidget {
  final SharedPreferences prefs;

  const MemoryGame({required this.prefs, Key? key}) : super(key: key);

  @override
  _MemoryGameState createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  late List<bool> blockStatusList;
  late List<int> sequenceList;
  late List<int> userInputList;
  late int currentLevel;
  int bestLevel = 1;
  late bool isGameStarted;
  late bool isUserTurn;
  late Timer timer;
  late bool isRedBlocksShowing;
  int redBlockIndex = 0;
  List<String> imagePaths = [
    'assets/apple.png',
    'assets/banana.png',
    'assets/grape.png',
    'assets/limon.png',
    'assets/mango.png',
    'assets/orange.png',
    'assets/pear.png',
    'assets/strawberry.png',
    'assets/watermelon.png',
  ];
  bool canTapBlocks = true;
  bool canTapDuringShow = false;
  @override
  void initState() {
    super.initState();
    resetGame();
    bestLevel = widget.prefs.getInt('bestLevel') ?? 1;
  }

  void saveBestLevel(int level) {
    widget.prefs.setInt('bestLevel', level);
    setState(() {
      bestLevel = level;
    });
  }

  void resetGame() {
    setState(() {
      blockStatusList = List.generate(9, (index) => false);
      sequenceList = [];
      userInputList = [];
      currentLevel = 1;
      isGameStarted = false;
      isUserTurn = false;
      isRedBlocksShowing = false;
    });
  }

  void startGame() {
    setState(() {
      isGameStarted = true;
      isUserTurn = false;
    });
    generateNextSequence();
  }

  void generateNextSequence() {
    setState(() {
      sequenceList = [];
      for (int i = 0; i < currentLevel; i++) {
        sequenceList.add(Random().nextInt(9));
      }
      userInputList = [];
    });

    startRedBlocks();
  }

  void showRedBlocks() {
    redBlockIndex = 0;
    canTapDuringShow = false;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (redBlockIndex < sequenceList.length) {
        int currentBlock = sequenceList[redBlockIndex];
        setState(() {
          blockStatusList[currentBlock] = true;
        });
        Timer(const Duration(milliseconds: 500), () {
          setState(() {
            blockStatusList[currentBlock] = false;
          });
        });
        redBlockIndex++;
      } else {
        timer.cancel();
        setState(() {
          isUserTurn = true;
          isRedBlocksShowing = false;
          resetBlockColors();
          canTapDuringShow = true;
        });
      }
    });
  }

  void startRedBlocks() {
    setState(() {
      isRedBlocksShowing = true;
    });
    showRedBlocks();
  }

  void resetBlockColors() {
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        blockStatusList = List.generate(9, (index) => false);
      });
    });
  }

  void showCorrectGuessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Congratulations!',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'You guessed the sequence correctly!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  currentLevel++;
                  if (currentLevel > bestLevel) {
                    bestLevel = currentLevel;
                    saveBestLevel(bestLevel);
                  }
                  generateNextSequence();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void checkUserInput(int blockIndex) {
    if (isUserTurn && canTapBlocks) {
      if (canTapDuringShow) {
        if (userInputList.length < sequenceList.length) {
          setState(() {
            canTapBlocks = false;
            blockStatusList[blockIndex] = true;
            userInputList.add(blockIndex);
          });

          if (userInputList.length == sequenceList.length) {
            bool isCorrect = true;

            for (int i = 0; i < sequenceList.length; i++) {
              if (userInputList[i] != sequenceList[i]) {
                isCorrect = false;
                break;
              }
            }

            if (isCorrect) {
              showCorrectGuessDialog(context);
            } else {
              showGameOverDialog(context);
            }
          }

          Timer(const Duration(milliseconds: 500), () {
            setState(() {
              blockStatusList[blockIndex] = false;
              canTapBlocks = true;
            });
          });
        }
      }
    }
  }

  void showGameOverDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Failing',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'You chose the wrong fruit. Try again!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Play Again',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double gridViewSize = MediaQuery.of(context).size.width * 0.8;

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/background.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            isRedBlocksShowing ? 'Remember' : 'Guess',
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Current level: $currentLevel',
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'The best result: $bestLevel',
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: gridViewSize + 60,
                      height: gridViewSize + 60,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 10,
                            top: 10,
                            right: 10,
                            bottom: 10,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                              itemCount: 9,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    checkUserInput(index);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        imagePaths[index],
                                        color: blockStatusList[index]
                                            ? null
                                            : Colors.grey,
                                        width:
                                            blockStatusList[index] ? 130 : 110,
                                        height:
                                            blockStatusList[index] ? 130 : 110,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ElevatedButton(
                          onPressed: isGameStarted ? null : startGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(
                            isGameStarted ? 'Guess' : 'Start Game',
                            style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
