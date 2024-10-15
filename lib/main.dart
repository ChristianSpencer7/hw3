import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Game',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const CardGame(),
    );
  }
}

class CardGame extends StatefulWidget {
  const CardGame({super.key});

  @override
  State<CardGame> createState() => _CardGameState();
}

class _CardGameState extends State<CardGame> {
  late Image _cardDesign;
  late Image _card1;
  late Image _card2;
  late Image _card3;
  late Image _card4;
  late Image _card5;
  late Image _card6;
  late Image _card7;
  late Image _card8;

  late List<Image> _cardImages;
  late List<Image> _shuffledCards;
  late List<bool> _cardFlipped;
  late List<int> _flippedIndices;

  int _remainingTime = 120;
  Timer? _timer;
  int _matches = 0;

  @override
  void initState() {
    super.initState();

    _cardDesign = Image.asset('lib/assets/images/back-card-design.png', fit: BoxFit.cover);
    _card1 = Image.asset('lib/assets/images/2-hearts.png', fit: BoxFit.cover);
    _card2 = Image.asset('lib/assets/images/3_spades.png', fit: BoxFit.cover);
    _card3 = Image.asset('lib/assets/images/4_spades.png', fit: BoxFit.cover);
    _card4 = Image.asset('lib/assets/images/7_hearts.png', fit: BoxFit.cover);
    _card5 = Image.asset('lib/assets/images/10_diamonds.png', fit: BoxFit.cover);
    _card6 = Image.asset('lib/assets/images/queen_clubs.png', fit: BoxFit.cover);
    _card7 = Image.asset('lib/assets/images/king_clubs.png', fit: BoxFit.cover);
    _card8 = Image.asset('lib/assets/images/ace_spades.png', fit: BoxFit.cover);

    _cardImages = [
      _card1, _card1, _card2, _card2, _card3, _card3, _card4, _card4,
      _card5, _card5, _card6, _card6, _card7, _card7, _card8, _card8,
    ];

    _shuffledCards = List.from(_cardImages);
    _shuffledCards.shuffle(Random());

    _cardFlipped = List<bool>.filled(16, false);
    _flippedIndices = [];

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer?.cancel();
          _showGameOverDialog(false);
        }
      });
    });
  }

  void _flipCard(int index) {
    if (_flippedIndices.length < 2 && !_cardFlipped[index]) {
      setState(() {
        _cardFlipped[index] = true;
        _flippedIndices.add(index);
      });

      if (_flippedIndices.length == 2) {
        _checkForMatch();
      }
    }
  }

  void _checkForMatch() {
    int firstIndex = _flippedIndices[0];
    int secondIndex = _flippedIndices[1];

    if (_shuffledCards[firstIndex] == _shuffledCards[secondIndex]) {
      _matches++;
      _flippedIndices.clear();
      if (_matches == 8) {
        _timer?.cancel();
        _showGameOverDialog(true);
      }
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _cardFlipped[firstIndex] = false;
          _cardFlipped[secondIndex] = false;
        });
        _flippedIndices.clear();
      });
    }
  }

  void _showGameOverDialog(bool won) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(won ? 'You Won!' : 'Game Over'),
          content: Text(won
              ? 'Congratulations! You found all the pairs.'
              : 'Time\'s up! Try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restartGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void _restartGame() {
    setState(() {
      _shuffledCards.shuffle(Random());
      _cardFlipped = List<bool>.filled(16, false);
      _flippedIndices.clear();
      _matches = 0;
      _remainingTime = 60;
      _startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 91, 11),
      appBar: AppBar(
        title: const Text('Find the Pairs'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Time Remaining: $_remainingTime',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              children: List.generate(16, (index) {
                return Center(
                  child: GestureDetector(
                    onTap: () {
                      if (_flippedIndices.length < 2) {
                        _flipCard(index);
                      }
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return RotationYAnimation(
                          child: child,
                          animation: animation,
                          isFlipped: _cardFlipped[index],
                        );
                      },
                      child: _cardFlipped[index]
                          ? _shuffledCards[index]
                          : _cardDesign,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class RotationYAnimation extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final bool isFlipped;

  const RotationYAnimation({
    Key? key,
    required this.child,
    required this.animation,
    required this.isFlipped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final angle = animation.value * pi; // Rotate from 0 to pi (halfway flip)
        final transform = isFlipped
            ? Matrix4.rotationY(angle) // Front to back
            : Matrix4.rotationY(angle - pi); // Back to front

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: child,
    );
  }
}
