import 'dart:math';
import 'package:flutter/material.dart';

/// ============================================================
///  ŞƏKLİ TAMAMLA – PUZZLE CONNECT
///  Sadə 2x2 drag & drop puzzle (uşaqlar üçün)
/// ============================================================

class PuzzleConnectScreen extends StatefulWidget {
  const PuzzleConnectScreen({super.key});

  @override
  State<PuzzleConnectScreen> createState() => _PuzzleConnectScreenState();
}

class _PuzzleConnectScreenState extends State<PuzzleConnectScreen>
    with SingleTickerProviderStateMixin {
  static const int pieceCount = 4; // 2x2 puzzle

  // Hissələrin slot indeksinə görə doğru yerləri: 0,1,2,3
  late final List<int> _pieceIds;
  final List<int?> _placed = List<int?>.filled(pieceCount, null);

  int _placedCount = 0;
  bool _completed = false;

  late AnimationController _winController;

  @override
  void initState() {
    super.initState();
    _resetPuzzle();

    _winController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      lowerBound: 0.9,
      upperBound: 1.05,
    );
  }

  @override
  void dispose() {
    _winController.dispose();
    super.dispose();
  }

  void _resetPuzzle() {
    // Hissə id-ləri: 0..3, ekranda random sırada göstəririk.
    _pieceIds = List<int>.generate(pieceCount, (i) => i)..shuffle(Random());
    for (var i = 0; i < pieceCount; i++) {
      _placed[i] = null;
    }
    _placedCount = 0;
    _completed = false;
    setState(() {});
  }

  bool _isPiecePlaced(int id) => _placed.contains(id);

  void _onPieceAccepted(int slotIndex, int pieceId) async {
    // Yalnız doğru slota icazə veririk
    if (pieceId != slotIndex) {
      // səhv yerə qoyanda heç nə etmə,
      // hissə aşağıda qalır
      return;
    }

    setState(() {
      _placed[slotIndex] = pieceId;
      _placedCount++;
    });

    if (_placedCount == pieceCount) {
      setState(() => _completed = true);
      _winController.repeat(reverse: true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        _winController.stop();
        _winController.value = 1.0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBg = const Color(0xFFFDF7FF);

    return Scaffold(
      backgroundColor: themeBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: themeBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Şəkli Tamamla',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Yenidən başla',
            icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
            onPressed: _resetPuzzle,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          children: [
            // info row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _infoPill(
                  icon: Icons.extension_rounded,
                  label: 'Hissə: $_placedCount / $pieceCount',
                  color: Colors.deepPurple,
                ),
                const SizedBox(width: 8),
                _infoPill(
                  icon: Icons.lightbulb_outline_rounded,
                  label: 'Məntiq & məkan təfəkkürü',
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Puzzle sahəsi
            Expanded(
              flex: 3,
              child: _buildPuzzleBoard(),
            ),

            const SizedBox(height: 12),

            // Əgər tamamlanıbsa, balaca “win” banneri
            if (_completed)
              ScaleTransition(
                scale: _winController,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade400, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.celebration_rounded,
                          color: Colors.green, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Təbriklər! Şəkli tamamladın 🎉',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 18),

            // Aşağıda hissələr
            Expanded(
              flex: 2,
              child: _buildPiecesBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Puzzle board – yuxarı hissə (kontur + 2x2 slotlar)
  Widget _buildPuzzleBoard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = min(constraints.maxWidth, constraints.maxHeight);

        final slotSize = boardSize / 2 - 20;

        return Center(
          child: Container(
            width: boardSize,
            height: boardSize,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE3D7FF), Color(0xFFC6B5FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.20),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Arxa fonda “kontur” – heyvan ikonu (fade)
                Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.pets_rounded,
                    size: boardSize * 0.45,
                    color: Colors.deepPurple.withOpacity(0.15),
                  ),
                ),

                // 2x2 slot grid
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSlot(0, slotSize),
                        const SizedBox(width: 16),
                        _buildSlot(1, slotSize),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSlot(2, slotSize),
                        const SizedBox(width: 16),
                        _buildSlot(3, slotSize),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Hər bir slot üçün DragTarget
  Widget _buildSlot(int index, double size) {
    final placedId = _placed[index];

    return DragTarget<int>(
      onWillAccept: (data) => !_completed && placedId == null,
      onAccept: (data) => _onPieceAccepted(index, data),
      builder: (context, candidate, rejected) {
        final isHighlighted = candidate.isNotEmpty;

        Widget child;
        if (placedId != null) {
          child = _buildPieceVisual(placedId,
              placed: true, size: size, showBorder: false);
        } else {
          child = Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isHighlighted
                    ? Colors.white
                    : Colors.white.withOpacity(0.6),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.help_outline_rounded,
              color: Colors.white.withOpacity(0.7),
              size: size * 0.35,
            ),
          );
        }

        return AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: isHighlighted ? 1.04 : 1.0,
          child: child,
        );
      },
    );
  }

  /// Aşağıdakı hissə paneli – sürüşdürüləcək hissələr
  Widget _buildPiecesBar() {
    final availablePieces = _pieceIds.where((id) => !_isPiecePlaced(id)).toList();

    return Center(
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        alignment: WrapAlignment.center,
        children: availablePieces.map((id) {
          return Draggable<int>(
            data: id,
            feedback: _buildPieceVisual(
              id,
              size: 90,
              placed: false,
              showBorder: false,
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: _buildPieceVisual(
                id,
                size: 90,
                placed: false,
                showBorder: true,
              ),
            ),
            child: _buildPieceVisual(
              id,
              size: 90,
              placed: false,
              showBorder: true,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Hissənin vizualı – hər id üçün fərqli rəng və forma
  Widget _buildPieceVisual(
      int id, {
        required double size,
        required bool placed,
        required bool showBorder,
      }) {
    final colors = [
      [const Color(0xFFFFD54F), const Color(0xFFFFA726)],
      [const Color(0xFF4DD0E1), const Color(0xFF26C6DA)],
      [const Color(0xFF81C784), const Color(0xFF4CAF50)],
      [const Color(0xFFBA68C8), const Color(0xFFAB47BC)],
    ];

    final pair = colors[id % colors.length];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: pair,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: showBorder
            ? Border.all(color: Colors.black.withOpacity(0.05), width: 1)
            : null,
        boxShadow: placed
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Center(
        child: Icon(
          Icons.pets_rounded,
          color: Colors.white,
          size: size * 0.45,
        ),
      ),
    );
  }
}
