import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/mosque_data.dart';
import '../../services/mosque_service.dart';
import '../../services/mosque_api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/banner_ad_widget.dart';
import 'widgets/mosque_card_widget.dart';
import 'widgets/mosque_filter_widget.dart';
import 'widgets/quick_filter_widget.dart';
import 'mosque_detail_screen.dart';

class MosqueFinderScreen extends StatefulWidget {
  const MosqueFinderScreen({super.key});

  @override
  State<MosqueFinderScreen> createState() => _MosqueFinderScreenState();
}

class _MosqueFinderScreenState extends State<MosqueFinderScreen>
    with SingleTickerProviderStateMixin {
  final MosqueService _mosqueService = MosqueService();
  final MosqueApiService _apiService = MosqueApiService();
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;
  List<Mosque> _allMosques = [];
  List<Mosque> _filteredMosques = [];
  List<Mosque> _favoriteMosques = [];
  MosqueFilter _currentFilter = const MosqueFilter();
  bool _isLoading = true;
  bool _isLoadingFromApi = false;
  String? _errorMessage;
  bool _showFilterSheet = false;
  String? _selectedProvince;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initService();
  }

  Future<void> _initService() async {
    try {
      await _mosqueService.init();
      await _loadMosques();
    } catch (e) {
      setState(() {
        _errorMessage = 'Camiler yüklenirken hata oluştu';
        _isLoading = false;
      });
    }
  }

  void _showProvinceSelector() {
    final provinces = _apiService.getAvailableProvinces();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.location_city, color: AppTheme.primaryDark),
                    const SizedBox(width: 12),
                    const Text(
                      'İl Seçin',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedProvince != null)
                      TextButton(
                        onPressed: () {
                          setState(() => _selectedProvince = null);
                          Navigator.pop(context);
                          _loadMosques();
                        },
                        child: const Text('Tümünü Göster'),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Province list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: provinces.length,
                  itemBuilder: (context, index) {
                    final province = provinces[index];
                    final isSelected = province == _selectedProvince;
                    
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppTheme.primaryDark 
                              : AppTheme.primaryLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.primaryDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        province,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppTheme.primaryDark : null,
                        ),
                      ),
                      trailing: isSelected 
                          ? Icon(Icons.check_circle, color: AppTheme.primaryDark)
                          : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
                      onTap: () {
                        Navigator.pop(context);
                        _loadMosquesFromProvince(province);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadMosquesFromProvince(String province) async {
    setState(() {
      _isLoadingFromApi = true;
      _selectedProvince = province;
    });

    try {
      await _mosqueService.loadMosquesFromAPI(city: province);
      await _loadMosques();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$province camileri yüklendi'),
            backgroundColor: AppTheme.primaryDark,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$province camileri yüklenirken hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoadingFromApi = false);
    }
  }

  Future<void> _refreshFromApi() async {
    setState(() => _isLoadingFromApi = true);

    try {
      if (_selectedProvince != null) {
        await _mosqueService.loadMosquesFromAPI(city: _selectedProvince);
      } else {
        await _mosqueService.loadMosquesFromAPI();
      }
      await _loadMosques();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camiler güncellendi'),
            backgroundColor: AppTheme.primaryDark,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camiler güncellenirken hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoadingFromApi = false);
    }
  }

  Future<void> _loadMosques() async {
    setState(() => _isLoading = true);

    try {
      final mosques = await _mosqueService.getAllMosques();
      final favorites = await _mosqueService.getFavoriteMosques();

      setState(() {
        _allMosques = mosques;
        _filteredMosques = mosques.where((m) => _currentFilter.matches(m)).toList();
        _favoriteMosques = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Camiler yüklenirken hata oluştu';
        _isLoading = false;
      });
    }
  }

  void _applyFilter(MosqueFilter filter) {
    setState(() {
      _currentFilter = filter;
      _filteredMosques = _allMosques.where((m) => filter.matches(m)).toList();
    });
  }

  void _searchMosques(String query) {
    if (query.isEmpty) {
      _applyFilter(_currentFilter.copyWith(searchQuery: null));
    } else {
      _applyFilter(_currentFilter.copyWith(searchQuery: query));
    }
  }

  Future<void> _toggleFavorite(Mosque mosque) async {
    await _mosqueService.toggleFavorite(mosque.id);
    final favorites = await _mosqueService.getFavoriteMosques();
    setState(() {
      _favoriteMosques = favorites;
    });
  }

  Future<void> _openNavigation(Mosque mosque, {bool walking = false}) async {
    final url = walking
        ? _mosqueService.getWalkingNavigationUrl(mosque)
        : _mosqueService.getNavigationUrl(mosque);

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigasyon açılamadı')),
        );
      }
    }
  }

  void _openMosqueDetail(Mosque mosque) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MosqueDetailScreen(
          mosque: mosque,
          onFavoriteToggle: () => _toggleFavorite(mosque),
        ),
      ),
    ).then((_) => _loadMosques());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildQuickFilters(),
          _buildTabBar(),
          Expanded(child: _buildBody()),
          const BannerAdWidget(),
        ],
      ),
      floatingActionButton: _buildFilterFab(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final subtitle = _selectedProvince ?? '81 il, tüm ilçeler';
    
    return AppBar(
      backgroundColor: AppTheme.primaryDark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cami Bulucu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              if (_isLoadingFromApi) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white70,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.location_city, color: Colors.white),
          onPressed: _showProvinceSelector,
          tooltip: 'İl Seç',
        ),
        IconButton(
          icon: _isLoadingFromApi 
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.refresh, color: Colors.white),
          onPressed: _isLoadingFromApi ? null : _refreshFromApi,
          tooltip: 'Yenile',
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppTheme.primaryDark,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _searchMosques,
          decoration: InputDecoration(
            hintText: 'Cami adı veya adres ara...',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixIcon: Icon(Icons.search, color: AppTheme.primaryDark),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _searchMosques('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFilters() {
    final quickFilters = _mosqueService.getQuickFilters();

    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: quickFilters.length,
        itemBuilder: (context, index) {
          final filter = quickFilters[index];
          return QuickFilterWidget(
            title: filter['title'] as String,
            icon: filter['icon'] as String,
            onTap: () {
              _applyFilter(filter['filter'] as MosqueFilter);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${filter['title']} filtresi uygulandı'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.primaryDark,
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        indicator: BoxDecoration(
          color: AppTheme.primaryDark,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        isScrollable: false,
        tabs: [
          _buildTab(Icons.near_me, 'Yakın', _filteredMosques.length),
          _buildTab(Icons.favorite, 'Favori', _favoriteMosques.length),
          _buildTab(Icons.star, 'Popüler', null),
        ],
      ),
    );
  }

  Widget _buildTab(IconData icon, String title, int? count) {
    final text = count != null ? '$title ($count)' : title;
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryDark),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMosques,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildMosqueList(_filteredMosques),
        _buildMosqueList(_favoriteMosques),
        _buildMosqueList(
          _allMosques.where((m) => m.averageRating >= 4.5).toList()
            ..sort((a, b) => b.averageRating.compareTo(a.averageRating)),
        ),
      ],
    );
  }

  Widget _buildMosqueList(List<Mosque> mosques) {
    if (mosques.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mosque_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Cami bulunamadı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Filtrelerinizi değiştirmeyi deneyin',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMosques,
      color: AppTheme.primaryDark,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: mosques.length,
        itemBuilder: (context, index) {
          final mosque = mosques[index];
          return FutureBuilder<bool>(
            future: _mosqueService.isFavorite(mosque.id),
            builder: (context, snapshot) {
              final isFavorite = snapshot.data ?? false;
              return MosqueCardWidget(
                mosque: mosque,
                isFavorite: isFavorite,
                onTap: () => _openMosqueDetail(mosque),
                onFavorite: () => _toggleFavorite(mosque),
                onNavigate: () => _openNavigation(mosque),
                onWalk: () => _openNavigation(mosque, walking: true),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterFab() {
    final hasActiveFilters = _currentFilter.requiredAmenities.isNotEmpty ||
        _currentFilter.maxDistance != null ||
        _currentFilter.minRating != null;

    return FloatingActionButton.extended(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => MosqueFilterWidget(
            currentFilter: _currentFilter,
            onApply: (filter) {
              _applyFilter(filter);
              Navigator.pop(context);
            },
            onClear: () {
              _applyFilter(const MosqueFilter());
              Navigator.pop(context);
            },
          ),
        );
      },
      backgroundColor: AppTheme.primaryDark,
      icon: Stack(
        children: [
          const Icon(Icons.tune, color: Colors.white),
          if (hasActiveFilters)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.accentGold,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      label: Text(
        hasActiveFilters ? 'Filtreler Aktif' : 'Filtrele',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
