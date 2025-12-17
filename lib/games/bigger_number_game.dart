import 'dart:math';

import 'package:flutter/material.dart';
import '../widgets/pill_icon_text.dart';

class BiggerNumberGameScreen extends StatefulWidget {
  const BiggerNumberGameScreen({super.key});

  @override
  State<BiggerNumberGameScreen> createState() =>
      _BiggerNumberGameScreenState();
}

class _BiggerNumberGameScreenState extends State<BiggerNumberGameScreen> {
  final Random _random = Random();
  late int _left;
  late int _right;
  int _score = 0;
  int _round = 1;
  String _feedback = '';
  Color _feedbackColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _generateRound();
  }

  void _generateRound() {
    int a = _random.nextInt(50) + 1;
    int b = _random.nextInt(50) + 1;
    while (b == a) {
      b = _random.nextInt(50) + 1;
    }
    setState(() {
      _left = a;
      _right = b;
    });
  }

  void _choose(bool left) {
    final correct = left ? _left > _right : _right > _left;

    setState(() {
      _round++;
      if (correct) {
        _score++;
        _feedback = 'Düzdür! Böyük ədəd seçildi ✅';
        _feedbackColor = Colors.green;
      } else {
        _feedback = 'Səhv seçim. Bir daha cəhd et 🙂';
        _feedbackColor = Colors.red;
      }
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      setState(() {
        _feedback = '';
        _feedbackColor = Colors.transparent;
      });
      _generateRound();
    });
  }

  void _reset() {
    setState(() {
      _score = 0;
      _round = 1;
      _feedback = '';
      _feedbackColor = Colors.transparent;
    });
    _generateRound();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Böyük hansıdır?'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Yenidən başla',
            onPressed: _reset,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildScoreRow(),
              const SizedBox(height: 24),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _numberCard(
                        label: 'Sol',
                        value: _left,
                        color: Colors.blue,
                        onTap: () => _choose(true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberCard(
                        label: 'Sağ',
                        value: _right,
                        color: Colors.indigo,
                        onTap: () => _choose(false),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color:
                  _feedbackColor.withOpacity(_feedback.isEmpty ? 0 : 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  _feedback,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _feedbackColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRow() {
    return Row(
      children: [
        PillIconText(
          icon: Icons.star_rate_rounded,
          color: Colors.blue,
          label: 'Xal: $_score',
        ),
        const SizedBox(width: 12),
        PillIconText(
          icon: Icons.play_circle_fill_rounded,
          color: Colors.indigo,
          label: 'Tur: $_round',
        ),
      ],
    );
  }

  Widget _numberCard({
    required String label,
    required int value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.95, end: 1),
        duration: const Duration(milliseconds: 400),
        builder: (context, v, child) {
          return Transform.scale(scale: v, child: child);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.95), color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$value',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
