import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class TetrisGameScreen extends StatefulWidget {
  const TetrisGameScreen({super.key});

  @override
  State<TetrisGameScreen> createState() => _TetrisGameScreenState();
}

class _TetrisGameScreenState extends State<TetrisGameScreen> {
  // Lövhə ölçüsü
  static const int rows = 20;
  static const int cols = 10;
  static const int tickMillis = 500; // 0.5 saniyəlik step

  late List<List<Color?>> board;

  Timer? _timer;
  final Random _random = Random();

  // aktiv fiqur
  late List<Point<int>> _shape;
  late Color _shapeColor;
  int _x = 3; // fiqurun mərkəz sütunu
  int _y = 0; // fiqurun mərkəz sətri

  int _score = 0;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _resetBoard();
    _spawnPiece();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetBoard() {
    board = List.generate(
      rows,
          (_) => List<Color?>.filled(cols, null),
    );
    _score = 0;
    _gameOver = false;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: tickMillis),
          (_) => _tick(),
    );
  }

  // ================== SHAPES ==================

  List<Point<int>> _randomShape() {
    // Sadə Tetris fiqurları
    return [
      // Kvadrat
      [const Point(0, 0), const Point(1, 0), const Point(0, 1), const Point(1, 1)],
      // Xətt
      [const Point(-1, 0), const Point(0, 0), const Point(1, 0), const Point(2, 0)],
      // L
      [const Point(0, 0), const Point(0, 1), const Point(0, -1), const Point(1, -1)],
      // T
      [const Point(0, 0), const Point(-1, 0), const Point(1, 0), const Point(0, -1)],
      // Z
      [const Point(0, 0), const Point(1, 0), const Point(0, 1), const Point(-1, 1)],
    ][_random.nextInt(5)];
  }

  Color _randomColor() {
    final colors = <Color>[
      Colors.red,
      Colors.orange,
      Colors.yellow.shade700,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.cyan,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void _spawnPiece() {
    _shape = _randomShape();
    _shapeColor = _randomColor();
    _x = cols ~/ 2;
    _y = 1;

    if (_collides(_x, _y, _shape)) {
      setState(() {
        _gameOver = true;
      });
      _timer?.cancel();
    }
  }

  bool _collides(int newX, int newY, List<Point<int>> shape) {
    for (final p in shape) {
      final int x = newX + p.x;
      final int y = newY + p.y;

      if (x < 0 || x >= cols || y < 0 || y >= rows) {
        return true;
      }
      if (board[y][x] != null) return true;
    }
    return false;
  }

  void _tick() {
    if (_gameOver) return;

    if (!_collides(_x, _y + 1, _shape)) {
      setState(() => _y++);
    } else {
      _lockPiece();
      _clearLines();
      _spawnPiece();
    }
  }

  void _lockPiece() {
    for (final p in _shape) {
      final int x = _x + p.x;
      final int y = _y + p.y;
      if (y >= 0 && y < rows && x >= 0 && x < cols) {
        board[y][x] = _shapeColor;
      }
    }
  }

  void _clearLines() {
    int cleared = 0;

    for (int r = rows - 1; r >= 0; r--) {
      if (board[r].every((c) => c != null)) {
        // bu sətri sil, yuxarıdakıları aşağı çək
        for (int y = r; y > 0; y--) {
          board[y] = List<Color?>.from(board[y - 1]);
        }
        board[0] = List<Color?>.filled(cols, null);
        cleared++;
        r++; // eyni sətri yenidən yoxla
      }
    }

    if (cleared > 0) {
      setState(() {
        _score += cleared * 100;
      });
    }
  }

  // ================== CONTROLS ==================

  void _moveLeft() {
    if (_gameOver) return;
    if (!_collides(_x - 1, _y, _shape)) {
      setState(() => _x--);
    }
  }

  void _moveRight() {
    if (_gameOver) return;
    if (!_collides(_x + 1, _y, _shape)) {
      setState(() => _x++);
    }
  }

  void _moveDown() {
    if (_gameOver) return;
    if (!_collides(_x, _y + 1, _shape)) {
      setState(() => _y++);
    } else {
      _tick(); // artıq aşağıya çatıbsa kilidlə
    }
  }

  void _rotate() {
    if (_gameOver) return;

    // 90° döndürmə: (x,y) -> (-y,x)
    final rotated =
    _shape.map<Point<int>>((p) => Point(-p.y, p.x)).toList(growable: false);

    if (!_collides(_x, _y, rotated)) {
      setState(() {
        _shape = rotated;
      });
    }
  }

  void _resetGame() {
    setState(() {
      _resetBoard();
      _spawnPiece();
      _startTimer();
    });
  }

  // ================== UI ==================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tetris'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yenidən başla',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF283593)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _pill('Xal: $_score', Icons.star_rounded, Colors.amber),
                  const SizedBox(width: 8),
                  _pill(
                    _gameOver ? 'Oyun bitdi' : 'Davam edir',
                    _gameOver
                        ? Icons.sentiment_dissatisfied
                        : Icons.videogame_asset,
                    _gameOver ? Colors.redAccent : Colors.lightGreenAccent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: cols / rows,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildBoard(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildControls(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    // Lövhənin üzərinə cari fiquru da əlavə edirik (vizual üçün)
    final tempBoard =
    List.generate(rows, (y) => List<Color?>.from(board[y]));

    for (final p in _shape) {
      final int x = _x + p.x;
      final int y = _y + p.y;
      if (y >= 0 && y < rows && x >= 0 && x < cols) {
        tempBoard[y][x] = _shapeColor;
      }
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
      ),
      itemCount: rows * cols,
      itemBuilder: (context, index) {
        final x = index % cols;
        final y = index ~/ cols;
        final color = tempBoard[y][x];

        return Container(
          margin: const EdgeInsets.all(0.5),
          decoration: BoxDecoration(
            color: color ?? Colors.grey.shade900,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _controlButton(Icons.rotate_90_degrees_ccw_rounded, _rotate),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _controlButton(Icons.arrow_left_rounded, _moveLeft),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _controlButton(Icons.arrow_downward_rounded, _moveDown),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _controlButton(Icons.arrow_right_rounded, _moveRight),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _controlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
