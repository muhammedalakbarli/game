import 'dart:math';
import 'package:flutter/material.dart';

class CountryGuessGameScreen extends StatefulWidget {
  const CountryGuessGameScreen({super.key});

  @override
  State<CountryGuessGameScreen> createState() => _CountryGuessGameScreenState();
}

class _CountryGuessGameScreenState extends State<CountryGuessGameScreen> {
  final Random _random = Random();

  final List<String> _countries = [
    "PAKISTAN",
    "BANGLADESH",
    "INDIA",
    "INDONESIA",
    "PHILIPPINES",
    "VIETNAM",
    "THAILAND",
    "CYPRUS",
    "KAZAKHSTAN",
    "SRI LANKA",
    "QATAR",
    "MYANMAR",
    "CHINA",
    "SINGAPORE",
    "BHUTAN",
    "SOUTH KOREA",
    "JAPAN",
    "TURKEY",
    "AFGHANISTAN",
    "SAUDI ARABIA",
    "NEPAL",
    "NORTH KOREA",
    "IRAN",
    "IRAQ",
  ];

  late String _scrambled;
  late String _correctCountry;
  late List<String> _options;

  int _score = 0;
  int _lives = 3;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    _correctCountry = _countries[_random.nextInt(_countries.length)];
    _scrambled = _scramble(_correctCountry);

    final Set<String> opt = {_correctCountry};
    while (opt.length < 4) {
      opt.add(_countries[_random.nextInt(_countries.length)]);
    }
    _options = opt.toList()..shuffle();

    setState(() {});
  }

  String _scramble(String country) {
    final letters = country.replaceAll(' ', '').split('');
    letters.shuffle();
    return letters.join(' ');
  }

  void _check(String answer) {
    if (answer == _correctCountry) {
      setState(() => _score += 10);
    } else {
      setState(() => _lives -= 1);
    }

    if (_lives > 0) {
      Future.delayed(const Duration(milliseconds: 500), _newRound);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ölkəni tap"),
        centerTitle: true,
      ),
      body: _lives == 0
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Oyun bitdi!",
              style: TextStyle(fontSize: 26),
            ),
            Text("Xal: $_score"),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _score = 0;
                  _lives = 3;
                  _newRound();
                });
              },
              child: const Text("Yenidən oyna"),
            )
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Hərfləri düz: $_scrambled",
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text("Can: $_lives ❤️   Xal: $_score ⭐"),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: _options
                    .map(
                      (o) => ElevatedButton(
                    onPressed: () => _check(o),
                    child: Text(o),
                  ),
                )
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
