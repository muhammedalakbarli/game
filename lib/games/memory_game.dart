import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final List<String> _icons = [
    '🐶', '🐱', '🐵', '🦊', '🐼', '🐸',
  ];

  late List<String> _cards;
  late List<bool> _revealed;
  late List<bool> _matched;

  int? _firstIndex;
  int moves = 0;
  int pairs = 0;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    final temp = [..._icons, ..._icons];
    temp.shuffle(Random());

    _cards = temp;
    _revealed = List.generate(temp.length, (_) => false);
    _matched = List.generate(temp.length, (_) => false);

    pairs = 0;
    moves = 0;
    _firstIndex = null;
    setState(() {});
  }

  void _tapCard(int index) {
    if (_revealed[index] || _matched[index]) return;

    setState(() => _revealed[index] = true);

    if (_firstIndex == null) {
      _firstIndex = index;
    } else {
      moves++;

      final first = _firstIndex!;
      final second = index;

      if (_cards[first] == _cards[second]) {
        _matched[first] = true;
        _matched[second] = true;
        pairs++;

        if (pairs == _icons.length) {
          Future.delayed(const Duration(milliseconds: 800), () {
            _showWinDialog();
          });
        }
      } else {
        Timer(const Duration(milliseconds: 700), () {
          setState(() {
            _revealed[first] = false;
            _revealed[second] = false;
          });
        });
      }

      _firstIndex = null;
    }

    setState(() {});
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("🎉 Təbriklər!"),
        content: Text("Bütün cütləri tapdın!\nHərəkət sayı: $moves"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startNewGame();
            },
            child: const Text("Yenidən oyna"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Kart ölçüsünü ekrana görə hesablamaq (mükəmməl balans)
    final cardSize = (width - 60) / 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F2FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F2FF),
        elevation: 0,
        title: const Text(
          "Yaddaş kartları",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
            onPressed: _startNewGame,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 6),

          // Statistik göstəricilər
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _infoTag("Cüt: $pairs / 6", Icons.favorite, Colors.pink),
              const SizedBox(width: 10),
              _infoTag("Hərəkət: $moves", Icons.directions_run, Colors.deepPurple),
            ],
          ),

          const SizedBox(height: 12),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 sütun
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.78,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final revealed = _revealed[index] || _matched[index];

                return GestureDetector(
                  onTap: () => _tapCard(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: revealed ? Colors.white : const Color(0xFF8E6FDB),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        revealed ? _cards[index] : "❓",
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTag(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
