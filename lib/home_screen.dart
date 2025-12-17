import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ SƏNİN FAYL STRUKTURUNA GÖRƏ DÜZGÜN IMPORTLAR (home_screen.dart lib-dədir)
import 'games/math_game.dart';
import 'games/memory_game.dart';
import 'games/bigger_number_game.dart';
import 'games/country_guess_game.dart';
import 'games/tetris_game.dart';
import 'games/puzzle_connect_game.dart';

enum GameCategory { all, math, memory, logic, country, puzzle, tetris }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ----------------------------
  // STATE
  // ----------------------------
  GameCategory _selectedCategory = GameCategory.all;

  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  int _totalPlays = 0;

  late final AnimationController _bgController;
  late final AnimationController _introController;

  static const _kTotalPlays = 'totalPlays';

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();

    _searchCtrl.addListener(() {
      final v = _searchCtrl.text.trim();
      if (v == _searchQuery) return;
      setState(() => _searchQuery = v);
    });

    _loadStats();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _bgController.dispose();
    _introController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _totalPlays = prefs.getInt(_kTotalPlays) ?? 0);
  }

  Future<void> _incrementPlays() async {
    final prefs = await SharedPreferences.getInstance();
    final updated = _totalPlays + 1;
    await prefs.setInt(_kTotalPlays, updated);
    if (!mounted) return;
    setState(() => _totalPlays = updated);
  }

  Future<void> _openGame(Widget screen) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
    await _incrementPlays();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredGames();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1020),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tədris Təcrübəsi',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Stack(
        children: [
          _AnimatedBackground(controller: _bgController),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildHeroHeader(),
                const SizedBox(height: 12),
                _buildSearch(),
                const SizedBox(height: 10),
                _buildStatsRow(),
                const SizedBox(height: 10),
                _buildCategoryFilter(),
                const SizedBox(height: 8),
                Expanded(child: _buildGrid(items)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // HERO HEADER
  // ----------------------------
  Widget _buildHeroHeader() {
    final curve = CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic);

    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -0.06), end: Offset.zero).animate(curve),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.school_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Uşaqlar üçün inkişaf oyunları',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Riyaziyyat, yaddaş, məntiq və diqqət üçün mini oyunlar.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _Pill(
                    icon: Icons.bar_chart_rounded,
                    text: '$_totalPlays',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------
  // SEARCH
  // ----------------------------
  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: TextField(
          controller: _searchCtrl,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white70,
          decoration: InputDecoration(
            hintText: 'Oyun axtar... (məs: yaddaş, tetris, puzzle)',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.55)),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.75)),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
              onPressed: () => _searchCtrl.clear(),
              icon: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.8)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ),
    );
  }

  // ----------------------------
  // STATS
  // ----------------------------
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.bar_chart_rounded,
              title: 'Ümumi oynanma',
              value: '$_totalPlays',
              subtitle: 'Bütün oyunlar üzrə',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.filter_alt_rounded,
              title: 'Filtr',
              value: _categoryLabel(_selectedCategory),
              subtitle: 'Kateqoriya seçimi',
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // CATEGORY FILTER
  // ----------------------------
  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          _chip(GameCategory.all, 'Hamısı'),
          _chip(GameCategory.math, 'Riyaziyyat'),
          _chip(GameCategory.memory, 'Yaddaş'),
          _chip(GameCategory.logic, 'Məntiq'),
          _chip(GameCategory.country, 'Ölkələr'),
          _chip(GameCategory.puzzle, 'Puzzle'),
          _chip(GameCategory.tetris, 'Tetris'),
        ],
      ),
    );
  }

  Widget _chip(GameCategory category, String label) {
    final selected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white.withOpacity(0.85),
            fontWeight: FontWeight.w800,
          ),
        ),
        selected: selected,
        onSelected: (_) => setState(() => _selectedCategory = category),
        selectedColor: const Color(0xFF2563EB),
        backgroundColor: const Color(0xFF111827),
        pressElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: Colors.white.withOpacity(selected ? 0.12 : 0.07)),
        ),
      ),
    );
  }

  // ----------------------------
  // GRID
  // ----------------------------
  Widget _buildGrid(List<_GameItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 46, color: Colors.white.withOpacity(0.75)),
              const SizedBox(height: 10),
              const Text(
                'Heç nə tapılmadı',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                'Axtarış sözünü dəyiş və ya filtrini “Hamısı” et.',
                style: TextStyle(color: Colors.white.withOpacity(0.70), fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.86,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final g = items[i];
        return _GameCoverCard(
          title: g.title,
          subtitle: g.subtitle,
          badge: _categoryLabel(g.category),
          coverAsset: g.coverAsset,
          icon: g.icon,
          onTap: () => _openGame(_safeBuildScreen(g)),
        );
      },
    );
  }

  Widget _safeBuildScreen(_GameItem g) {
    try {
      return g.screenBuilder();
    } catch (_) {
      return _MissingScreen(
        title: g.title,
        hint:
        'Bu oyunun screen class adı/constructor-u düzgün deyil.\n'
            'Import və class adlarını yoxla.',
      );
    }
  }

  // ----------------------------
  // DATA + FILTER
  // ----------------------------
  List<_GameItem> _filteredGames() {
    // ✅ Burada "const" YOXDUR. Çünki səndəki ekranların çoxu const constructor deyil.
    final all = <_GameItem>[
      _GameItem(
        title: 'Toplama oyunu',
        subtitle: 'Sadə riyazi misallar',
        icon: Icons.calculate_rounded,
        coverAsset: 'assets/covers/math.jpg',
        category: GameCategory.math,
        screenBuilder: () => MathGameScreen(),
      ),
      _GameItem(
        title: 'Yaddaş kartları',
        subtitle: 'Kartları cütləşdir',
        icon: Icons.memory_rounded,
        coverAsset: 'assets/covers/memory.jpg',
        category: GameCategory.memory,
        screenBuilder: () => MemoryGameScreen(),
      ),
      _GameItem(
        title: 'Böyük rəqəmi tap',
        subtitle: 'İki rəqəmi müqayisə et',
        icon: Icons.trending_up_rounded,
        coverAsset: 'assets/covers/bigger.jpg',
        category: GameCategory.logic,
        screenBuilder: () => BiggerNumberGameScreen(),
      ),
      _GameItem(
        title: 'Ölkəni tanı',
        subtitle: 'Bayraqdan ölkəni tap',
        icon: Icons.flag_rounded,
        coverAsset: 'assets/covers/country.jpg',
        category: GameCategory.country,
        screenBuilder: () => CountryGuessGameScreen(),
      ),
      _GameItem(
        title: 'Puzzle Connect',
        subtitle: 'Hissələri birləşdir',
        icon: Icons.extension_rounded,
        coverAsset: 'assets/covers/puzzle.jpg',
        category: GameCategory.puzzle,
        screenBuilder: () => PuzzleConnectGameScreen(),
      ),
      _GameItem(
        title: 'Sadə Tetris',
        subtitle: 'Blokları yerləşdir',
        icon: Icons.grid_4x4_rounded,
        coverAsset: 'assets/covers/tetris.jpg',
        category: GameCategory.tetris,
        screenBuilder: () => TetrisGameScreen(),
      ),
    ];

    // Category filter
    var list = _selectedCategory == GameCategory.all
        ? all
        : all.where((x) => x.category == _selectedCategory).toList(growable: false);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((x) {
        final hay = '${x.title} ${x.subtitle} ${_categoryLabel(x.category)}'.toLowerCase();
        return hay.contains(q);
      }).toList(growable: false);
    }

    return list;
  }

  String _categoryLabel(GameCategory c) {
    switch (c) {
      case GameCategory.all:
        return 'Hamısı';
      case GameCategory.math:
        return 'Riyaziyyat';
      case GameCategory.memory:
        return 'Yaddaş';
      case GameCategory.logic:
        return 'Məntiq';
      case GameCategory.country:
        return 'Ölkələr';
      case GameCategory.puzzle:
        return 'Puzzle';
      case GameCategory.tetris:
        return 'Tetris';
    }
  }
}

// ----------------------------
// MODEL
// ----------------------------
class _GameItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String coverAsset;
  final GameCategory category;
  final Widget Function() screenBuilder;

  _GameItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.coverAsset,
    required this.category,
    required this.screenBuilder,
  });
}

// ----------------------------
// UI WIDGETS (self-contained)
// ----------------------------
class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _Pill({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withOpacity(0.08),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.white.withOpacity(0.78), fontWeight: FontWeight.w800, fontSize: 11.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white.withOpacity(0.60), fontWeight: FontWeight.w700, fontSize: 10.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCoverCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String badge;
  final String coverAsset;
  final IconData icon;
  final VoidCallback onTap;

  const _GameCoverCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.coverAsset,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_GameCoverCard> createState() => _GameCoverCardState();
}

class _GameCoverCardState extends State<_GameCoverCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed ? 0.985 : 1.0,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  widget.coverAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: Colors.white.withOpacity(0.06),
                      child: Center(
                        child: Icon(widget.icon, color: Colors.white.withOpacity(0.7), size: 44),
                      ),
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.20),
                        Colors.black.withOpacity(0.55),
                        Colors.black.withOpacity(0.75),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: _Badge(text: widget.badge),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: _IconChip(icon: widget.icon),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        border: Border.all(color: Colors.white.withOpacity(0.10)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.78),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 36,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Oyna',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(Icons.play_circle_fill_rounded, color: Colors.white.withOpacity(0.9)),
                            ],
                          ),
                        ],
                      ),
                    ),
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

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  final IconData icon;
  const _IconChip({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}

// ----------------------------
// BACKGROUND ANIMATION
// ----------------------------
class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        Alignment blob(double phase, double amp) {
          final x = sin((t + phase) * pi * 2);
          final y = cos((t + phase) * pi * 2);
          return Alignment(x * amp, y * amp);
        }

        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0B1020), Color(0xFF070A12)],
                  ),
                ),
              ),
            ),
            _Blob(position: blob(0.10, 0.18), size: 240, color: const Color(0xFF2563EB).withOpacity(0.18)),
            _Blob(position: blob(0.35, 0.22), size: 280, color: const Color(0xFF7C3AED).withOpacity(0.16)),
            _Blob(position: blob(0.60, 0.16), size: 220, color: const Color(0xFF10B981).withOpacity(0.10)),
          ],
        );
      },
    );
  }
}

class _Blob extends StatelessWidget {
  final Alignment position;
  final double size;
  final Color color;

  const _Blob({required this.position, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: position,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

// ----------------------------
// FALLBACK SCREEN
// ----------------------------
class _MissingScreen extends StatelessWidget {
  final String title;
  final String hint;

  const _MissingScreen({required this.title, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1020),
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 44, color: Colors.white.withOpacity(0.85)),
                const SizedBox(height: 10),
                const Text(
                  'Oyun ekranı tapılmadı',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  hint,
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
