import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/hadith_data.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/hadith_card_widget.dart';
import './widgets/daily_hadith_widget.dart';

/// Hadith Screen - Displays collection of hadiths
class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  String _selectedCategory = 'Tümü';
  final Set<int> _favoriteIds = {};
  final Set<int> _expandedIds = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_hadiths') ?? [];
    setState(() {
      _favoriteIds.clear();
      _favoriteIds.addAll(favorites.map((e) => int.parse(e)));
    });
  }

  Future<void> _toggleFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
    });
    await prefs.setStringList(
      'favorite_hadiths',
      _favoriteIds.map((e) => e.toString()).toList(),
    );
  }

  void _toggleExpanded(int id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  void _shareHadith(Hadith hadith) {
    final text = '''
📖 Hadis-i Şerif

${hadith.arabic}

${hadith.turkish}

📚 Kaynak: ${hadith.source}
👤 Ravi: ${hadith.narrator}

— Mirac Prayer Assistant
''';
    Share.share(text);
  }

  List<Hadith> get _filteredHadiths {
    List<Hadith> hadiths = getHadithsByCategory(_selectedCategory);
    
    if (_showFavoritesOnly) {
      hadiths = hadiths.where((h) => _favoriteIds.contains(h.id)).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      hadiths = hadiths.where((h) {
        return h.turkish.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               h.arabic.contains(_searchQuery) ||
               h.narrator.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               h.source.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    return hadiths;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dailyHadith = getDailyHadith();
    final filteredHadiths = _filteredHadiths;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hadis-i Şerif',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              '${hadithList.length} Hadis',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Favorites toggle
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() => _showFavoritesOnly = !_showFavoritesOnly);
                        },
                        icon: Icon(
                          _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                          color: _showFavoritesOnly ? Colors.red : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Hadis ara...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                    ),
                  ),
                ],
              ),
            ),
            
            // Category Chips
            SizedBox(
              height: 5.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: hadithCategories.length,
                itemBuilder: (context, index) {
                  final category = hadithCategories[index];
                  final isSelected = category == _selectedCategory;
                  
                  return Padding(
                    padding: EdgeInsets.only(right: 2.w),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedCategory = category);
                      },
                      selectedColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 1.h),
            
            // Hadith List
            Expanded(
              child: filteredHadiths.isEmpty
                  ? _buildEmptyState(theme)
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      itemCount: filteredHadiths.length + 1, // +1 for daily hadith
                      itemBuilder: (context, index) {
                        // Show daily hadith at top only if not filtering
                        if (index == 0 && !_showFavoritesOnly && _searchQuery.isEmpty && _selectedCategory == 'Tümü') {
                          return DailyHadithWidget(
                            hadith: dailyHadith,
                            onTap: () => _showHadithDetail(dailyHadith),
                          );
                        }
                        
                        final hadithIndex = (_showFavoritesOnly || _searchQuery.isNotEmpty || _selectedCategory != 'Tümü') 
                            ? index 
                            : index - 1;
                        
                        if (hadithIndex >= filteredHadiths.length || hadithIndex < 0) {
                          return const SizedBox.shrink();
                        }
                        
                        final hadith = filteredHadiths[hadithIndex];
                        
                        return HadithCardWidget(
                          hadith: hadith,
                          isExpanded: _expandedIds.contains(hadith.id),
                          isFavorite: _favoriteIds.contains(hadith.id),
                          onTap: () => _toggleExpanded(hadith.id),
                          onFavoriteTap: () => _toggleFavorite(hadith.id),
                          onShareTap: () => _shareHadith(hadith),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 4,
        onTap: (index) {},
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showFavoritesOnly ? Icons.favorite_border : Icons.search_off,
            size: 60,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: 2.h),
          Text(
            _showFavoritesOnly
                ? 'Favori hadis bulunamadı'
                : 'Aradığınız hadis bulunamadı',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 1.h),
          TextButton(
            onPressed: () {
              setState(() {
                _showFavoritesOnly = false;
                _searchQuery = '';
                _searchController.clear();
                _selectedCategory = 'Tümü';
              });
            },
            child: const Text('Filtreleri Temizle'),
          ),
        ],
      ),
    );
  }

  void _showHadithDetail(Hadith hadith) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 1.5.h),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        hadith.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    
                    // Arabic
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        hadith.arabic,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 22,
                          height: 2,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    
                    // Turkish
                    Text(
                      hadith.turkish,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.8,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    
                    // Source Info
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 20),
                              SizedBox(width: 2.w),
                              const Text('Ravi: '),
                              Expanded(
                                child: Text(
                                  hadith.narrator,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              const Icon(Icons.book_outlined, size: 20),
                              SizedBox(width: 2.w),
                              const Text('Kaynak: '),
                              Expanded(
                                child: Text(
                                  hadith.source,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _toggleFavorite(hadith.id),
                            icon: Icon(
                              _favoriteIds.contains(hadith.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _favoriteIds.contains(hadith.id) ? Colors.red : null,
                            ),
                            label: Text(
                              _favoriteIds.contains(hadith.id) ? 'Favorilerde' : 'Favorilere Ekle',
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _shareHadith(hadith),
                            icon: const Icon(Icons.share),
                            label: const Text('Paylaş'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
