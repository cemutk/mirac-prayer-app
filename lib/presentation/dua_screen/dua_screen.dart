import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/dua_data.dart';
import '../../theme/app_theme.dart';
import 'widgets/dua_card_widget.dart';
import 'widgets/ayetel_kursi_widget.dart';

/// Ayet-el Kürsi ve Önemli Dualar ekranı
class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Tümü';
  String _searchQuery = '';
  Set<int> _favoriteDuaIds = {};
  bool _showFavoritesOnly = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorite_duas') ?? [];
    setState(() {
      _favoriteDuaIds = favoriteIds.map((id) => int.parse(id)).toSet();
    });
  }

  Future<void> _toggleFavorite(int duaId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteDuaIds.contains(duaId)) {
        _favoriteDuaIds.remove(duaId);
      } else {
        _favoriteDuaIds.add(duaId);
      }
    });
    await prefs.setStringList(
      'favorite_duas',
      _favoriteDuaIds.map((id) => id.toString()).toList(),
    );
    HapticFeedback.lightImpact();
  }

  void _shareDua(Dua dua) {
    final text = '''
📿 ${dua.title}

${dua.arabicText}

📖 Okunuşu:
${dua.latinTranscription}

📝 Anlamı:
${dua.turkishMeaning}

📚 Kaynak: ${dua.source}
${dua.benefit != null ? '\n✨ Fazileti: ${dua.benefit}' : ''}

— Mirac Namaz Vakitleri Uygulaması
''';
    Share.share(text);
  }

  List<Dua> get _filteredDuas {
    List<Dua> duas;
    
    if (_searchQuery.isNotEmpty) {
      duas = searchDuas(_searchQuery);
    } else {
      duas = getDuasByCategory(_selectedCategory);
    }
    
    if (_showFavoritesOnly) {
      duas = duas.where((d) => _favoriteDuaIds.contains(d.id)).toList();
    }
    
    return duas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Dualar',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: _showFavoritesOnly ? Colors.red : Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentGold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Ayet-el Kürsi'),
            Tab(text: 'Tüm Dualar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Ayet-el Kürsi özel gösterim
          const AyetelKursiWidget(),
          
          // TAB 2: Tüm Dualar
          _buildAllDuasTab(),
        ],
      ),
    );
  }

  Widget _buildAllDuasTab() {
    return Column(
      children: [
        // Arama çubuğu
        Container(
          padding: EdgeInsets.all(4.w),
          color: AppTheme.primaryDark.withValues(alpha: 0.1),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Dua ara...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.primaryDark),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            ),
          ),
        ),

        // Kategori chips
        Container(
          height: 6.h,
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            itemCount: duaCategories.length,
            itemBuilder: (context, index) {
              final category = duaCategories[index];
              final isSelected = category == _selectedCategory;
              return Padding(
                padding: EdgeInsets.only(right: 2.w),
                child: FilterChip(
                  label: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.primaryDark,
                      fontSize: 10.sp,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: AppTheme.primaryDark,
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryDark : Colors.grey.shade300,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Dua listesi
        Expanded(
          child: _filteredDuas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _showFavoritesOnly ? Icons.favorite_border : Icons.search_off,
                        size: 15.w,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _showFavoritesOnly
                            ? 'Favori dua bulunamadı'
                            : 'Dua bulunamadı',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(4.w),
                  itemCount: _filteredDuas.length,
                  itemBuilder: (context, index) {
                    final dua = _filteredDuas[index];
                    return DuaCardWidget(
                      dua: dua,
                      isFavorite: _favoriteDuaIds.contains(dua.id),
                      onFavoriteToggle: () => _toggleFavorite(dua.id),
                      onShare: () => _shareDua(dua),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
