import 'dart:math';
import 'package:flutter/material.dart';

import '../widgets/pill_icon_text.dart';

/// ======================== RİYAZİYYAT OYUNU ========================

class MathGameScreen extends StatefulWidget {
  const MathGameScreen({super.key});

  @override
  State<MathGameScreen> createState() => _MathGameScreenState();
}

class _MathGameScreenState extends State<MathGameScreen> {
  final Random _random = Random();

  late int _a;
  late int _b;
  late String _op;
  late int _correctAnswer;
  late List<int> _options;

  int _score = 0;
  int _question = 1;
  String _feedback = '';
  Color _feedbackColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    setState(() {
      _feedback = '';
      _feedbackColor = Colors.transparent;
    });

    final ops = ['+', '-', '×', '÷'];
    _op = ops[_random.nextInt(ops.length)];

    switch (_op) {
      case '+':
        _a = _random.nextInt(5) + 1; // 1..5
        _b = _random.nextInt(5) + 1;
        _correctAnswer = _a + _b;
        break;
      case '-':
        _a = _random.nextInt(8) + 2; // 2..9
        _b = _random.nextInt(_a - 1) + 1; // 1..a-1
        _correctAnswer = _a - _b;
        break;
      case '×':
        _a = _random.nextInt(4) + 1; // 1..4
        _b = _random.nextInt(4) + 1;
        _correctAnswer = _a * _b;
        break;
      case '÷':
        _b = _random.nextInt(4) + 1; // 1..4
        final k = _random.nextInt(4) + 1; // 1..4
        _correctAnswer = k;
        _a = _b * _correctAnswer;
        break;
      default:
        _a = 1;
        _b = 1;
        _correctAnswer = 2;
    }

    // 4 cavab variantı
    final set = <int>{_correctAnswer};
    while (set.length < 4) {
      final delta = _random.nextInt(3) + 1;
      final sign = _random.nextBool() ? 1 : -1;
      final candidate = max(1, _correctAnswer + sign * delta);
      set.add(candidate);
    }
    _options = set.toList()..shuffle(_random);
    setState(() {});
  }

  void _onAnswerTap(int value) {
    if (value == _correctAnswer) {
      _score += 1;
      _question += 1;
      _feedback = 'Düzdür! 🎉';
      _feedbackColor = Colors.green;
      _generateQuestion();
    } else {
      _feedback = 'Səhv cavab 😿';
      _feedbackColor = Colors.redAccent;
      setState(() {});
    }
  }

  void _resetGame() {
    setState(() {
      _score = 0;
      _question = 1;
      _feedback = '';
      _feedbackColor = Colors.transparent;
    });
    _generateQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7DD),
        elevation: 0,
        title: const Text(
          'Riyaziyyat oyunu',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Yenidən başla',
            icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Xal və sual
            Row(
              children: [
                PillIconText(
                  icon: Icons.star_rounded,
                  label: 'Xal: $_score',
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                PillIconText(
                  icon: Icons.help_outline_rounded,
                  label: 'Sual: $_question',
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Sual kartı
            _buildQuestionCard(),
            const SizedBox(height: 16),

            if (_feedback.isNotEmpty)
              Center(
                child: Text(
                  _feedback,
                  style: TextStyle(
                    color: _feedbackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Kiçik cavab düymələri – Wrap ilə
            Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _options
                    .map(
                      (v) => _AnswerChip(
                    value: v,
                    onTap: () => _onAnswerTap(v),
                  ),
                )
                    .toList(),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFFF5722)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCatsRow(_a),
          const SizedBox(height: 8),
          Text(
            _op,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildCatsRow(_b),
          const SizedBox(height: 10),
          const Text(
            '=?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatsRow(int count) {
    const maxVisible = 8;
    final visibleCount = count.clamp(1, maxVisible);
    final hasMore = count > maxVisible;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(
            visibleCount,
                (_) => const _CatBubble(),
          ),
        ),
        if (hasMore) ...[
          const SizedBox(width: 6),
          Text(
            'x$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )
        ]
      ],
    );
  }
}

/// Pişik "bubble" – assetsiz
class _CatBubble extends StatelessWidget {
  const _CatBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF59D), Color(0xFFFFCC80)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(
        Icons.pets_rounded,
        size: 18,
        color: Color(0xFFEF6C00),
      ),
    );
  }
}

/// ======================== KİÇİK CAVAB DÜYMƏSİ ========================

class _AnswerChip extends StatelessWidget {
  final int value;
  final VoidCallback onTap;

  const _AnswerChip({
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,   // kiçik, konkret ölçü
      height: 48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$value',
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
