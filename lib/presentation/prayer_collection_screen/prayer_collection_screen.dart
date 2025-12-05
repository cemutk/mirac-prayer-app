import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/category_tab_widget.dart';
import './widgets/empty_favorites_widget.dart';
import './widgets/prayer_card_widget.dart';

/// Prayer Collection Screen - Fourth tab in bottom navigation
/// Displays categorized Islamic prayers with Arabic text, transliteration, and Turkish translation
class PrayerCollectionScreen extends StatefulWidget {
  const PrayerCollectionScreen({super.key});

  @override
  State<PrayerCollectionScreen> createState() => _PrayerCollectionScreenState();
}

class _PrayerCollectionScreenState extends State<PrayerCollectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _showFavoritesOnly = false;
  bool _isReadingMode = false;
  double _textSize = 14.0;
  String _searchQuery = '';
  final Set<int> _favoritePrayerIds = {};

  // Prayer categories
  final List<String> _categories = [
    'Genel',
    'Şükür',
    'İstekler',
    'Sabır',
    'Huzur',
    'Bağışlanma',
  ];

  // Mock prayer data with Turkish content
  final List<Map<String, dynamic>> _allPrayers = [
    {
      "id": 1,
      "category": "Genel",
      "title": "Sabah Duası",
      "arabic":
          "اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ",
      "transliteration":
          "Allâhümme bike asbahnâ ve bike emseynâ ve bike nahyâ ve bike nemûtü ve ileyke'n-nüşûr",
      "translation":
          "Allah'ım! Seninle sabahladık, seninle akşamladık, seninle yaşıyor ve seninle ölüyoruz. Dönüş ancak sanadır.",
      "preview": "Allah'ım! Seninle sabahladık, seninle akşamladık..."
    },
    {
      "id": 2,
      "category": "Şükür",
      "title": "Şükür Duası",
      "arabic":
          "الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَكَفَانَا وَآوَانَا",
      "transliteration":
          "Elhamdülillâhillezî at'amenâ ve sekānâ ve kefânâ ve âvânâ",
      "translation":
          "Bizi yediren, içiren, ihtiyaçlarımızı gideren ve barındıran Allah'a hamdolsun.",
      "preview": "Bizi yediren, içiren, ihtiyaçlarımızı gideren..."
    },
    {
      "id": 3,
      "category": "İstekler",
      "title": "Rızık Duası",
      "arabic":
          "اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا وَرِزْقًا طَيِّبًا وَعَمَلًا مُتَقَبَّلًا",
      "transliteration":
          "Allâhümme innî es'elüke ilmen nâfi'an ve rızkan tayyiben ve amelen mütekabbelen",
      "translation":
          "Allah'ım! Senden faydalı ilim, helal rızık ve makbul amel istiyorum.",
      "preview": "Allah'ım! Senden faydalı ilim, helal rızık..."
    },
    {
      "id": 4,
      "category": "Sabır",
      "title": "Sabır Duası",
      "arabic":
          "رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَثَبِّتْ أَقْدَامَنَا وَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ",
      "transliteration":
          "Rabbenâ efriğ aleynâ sabran ve sebbit akdâmenâ vansurnâ ale'l-kavmi'l-kâfirîn",
      "translation":
          "Rabbimiz! Üzerimize sabır yağdır, ayaklarımızı sabit kıl ve kâfirler topluluğuna karşı bize yardım et.",
      "preview": "Rabbimiz! Üzerimize sabır yağdır, ayaklarımızı..."
    },
    {
      "id": 5,
      "category": "Huzur",
      "title": "Kalp Huzuru Duası",
      "arabic": "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ",
      "transliteration": "Allâhümme innî eûzü bike mine'l-hemmi ve'l-hazen",
      "translation": "Allah'ım! Üzüntü ve kederden sana sığınırım.",
      "preview": "Allah'ım! Üzüntü ve kederden sana sığınırım."
    },
    {
      "id": 6,
      "category": "Bağışlanma",
      "title": "İstiğfar Duası",
      "arabic":
          "أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ",
      "transliteration":
          "Estağfirullâhe'l-azîmellezî lâ ilâhe illâ hüve'l-hayyu'l-kayyûmü ve etûbü ileyh",
      "translation":
          "Kendisinden başka ilah olmayan, diri ve kayyum olan yüce Allah'tan bağışlanma dilerim ve O'na tevbe ederim.",
      "preview": "Kendisinden başka ilah olmayan, diri ve kayyum..."
    },
    {
      "id": 7,
      "category": "Genel",
      "title": "Akşam Duası",
      "arabic":
          "اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ",
      "transliteration":
          "Allâhümme bike emseynâ ve bike asbahnâ ve bike nahyâ ve bike nemûtü ve ileyke'l-masîr",
      "translation":
          "Allah'ım! Seninle akşamladık, seninle sabahladık, seninle yaşıyor ve seninle ölüyoruz. Dönüş ancak sanadır.",
      "preview": "Allah'ım! Seninle akşamladık, seninle sabahladık..."
    },
    {
      "id": 8,
      "category": "Şükür",
      "title": "Nimet Şükrü",
      "arabic": "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
      "transliteration": "Elhamdülillâhi rabbi'l-âlemîn",
      "translation": "Hamd, âlemlerin Rabbi Allah'a mahsustur.",
      "preview": "Hamd, âlemlerin Rabbi Allah'a mahsustur."
    },
    {
      "id": 9,
      "category": "İstekler",
      "title": "Hayır Duası",
      "arabic":
          "اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ خَيْرِ مَا سَأَلَكَ مِنْهُ نَبِيُّكَ مُحَمَّدٌ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ",
      "transliteration":
          "Allâhümme innî es'elüke min hayri mâ seeleke minhü nebiyyüke Muhammedun sallallâhü aleyhi ve sellem",
      "translation":
          "Allah'ım! Peygamberin Muhammed'in (s.a.v.) senden istediği hayırlardan sana sığınırım.",
      "preview": "Allah'ım! Peygamberin Muhammed'in (s.a.v.) senden..."
    },
    {
      "id": 10,
      "category": "Sabır",
      "title": "Zorluk Anında Dua",
      "arabic": "حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ",
      "transliteration": "Hasbünallâhü ve ni'me'l-vekîl",
      "translation": "Allah bize yeter, O ne güzel vekildir.",
      "preview": "Allah bize yeter, O ne güzel vekildir."
    },
    {
      "id": 11,
      "category": "Huzur",
      "title": "Gönül Rahatlığı Duası",
      "arabic":
          "اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ",
      "transliteration":
          "Allâhümme innî es'elüke'l-âfiyete fi'd-dünyâ ve'l-âhırah",
      "translation": "Allah'ım! Dünyada ve ahirette afiyet istiyorum.",
      "preview": "Allah'ım! Dünyada ve ahirette afiyet istiyorum."
    },
    {
      "id": 12,
      "category": "Bağışlanma",
      "title": "Tevbe Duası",
      "arabic":
          "رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ إِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ",
      "transliteration":
          "Rabbi'ğfir lî ve tüb aleyye inneke ente't-tevvâbü'r-rahîm",
      "translation":
          "Rabbim! Beni bağışla ve tevbemi kabul et. Şüphesiz sen tevbeleri çok kabul eden, çok merhametli olansın.",
      "preview": "Rabbim! Beni bağışla ve tevbemi kabul et..."
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredPrayers {
    List<Map<String, dynamic>> prayers = _allPrayers;

    // Filter by favorites
    if (_showFavoritesOnly) {
      prayers = prayers
          .where((prayer) => _favoritePrayerIds.contains(prayer['id']))
          .toList();
    }

    // Filter by category
    if (!_showFavoritesOnly && _searchQuery.isEmpty) {
      final selectedCategory = _categories[_tabController.index];
      prayers = prayers
          .where((prayer) => prayer['category'] == selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      prayers = prayers.where((prayer) {
        final title = (prayer['title'] as String).toLowerCase();
        final translation = (prayer['translation'] as String).toLowerCase();
        final transliteration =
            (prayer['transliteration'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) ||
            translation.contains(query) ||
            transliteration.contains(query);
      }).toList();
    }

    return prayers;
  }

  void _toggleFavorite(int prayerId) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_favoritePrayerIds.contains(prayerId)) {
        _favoritePrayerIds.remove(prayerId);
      } else {
        _favoritePrayerIds.add(prayerId);
      }
    });
  }

  void _showPrayerContextMenu(
      BuildContext context, Map<String, dynamic> prayer) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'share',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                title: Text('Paylaş', style: theme.textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  // Share functionality would go here
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'content_copy',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                title: Text('Metni Kopyala', style: theme.textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(
                    text:
                        '${prayer['title']}\n\n${prayer['arabic']}\n\n${prayer['transliteration']}\n\n${prayer['translation']}',
                  ));
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: _favoritePrayerIds.contains(prayer['id'])
                      ? 'favorite'
                      : 'favorite_border',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                title: Text(
                  _favoritePrayerIds.contains(prayer['id'])
                      ? 'Favorilerden Çıkar'
                      : 'Favorilere Ekle',
                  style: theme.textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _toggleFavorite(prayer['id'] as int);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'report',
                  color: theme.colorScheme.error,
                  size: 24,
                ),
                title: Text('Sorun Bildir',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: theme.colorScheme.error)),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  // Report functionality would go here
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _isSearching
          ? CustomSearchAppBar(
              hintText: 'Dua ara...',
              autofocus: true,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onSearchSubmitted: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              leading: IconButton(
                icon: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
              ),
            )
          : CustomAppBar(
              title: 'Dua Arşivi',
              centerTitle: true,
              actions: [
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'search',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: _showFavoritesOnly ? 'star' : 'star_border',
                    color: _showFavoritesOnly
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _showFavoritesOnly = !_showFavoritesOnly;
                    });
                  },
                ),
                PopupMenuButton<String>(
                  icon: CustomIconWidget(
                    iconName: 'more_vert',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  onSelected: (value) {
                    if (value == 'reading_mode') {
                      setState(() {
                        _isReadingMode = !_isReadingMode;
                      });
                    } else if (value == 'text_size') {
                      _showTextSizeDialog();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'reading_mode',
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName:
                                _isReadingMode ? 'view_agenda' : 'view_stream',
                            color: theme.colorScheme.onSurface,
                            size: 20,
                          ),
                          SizedBox(width: 3.w),
                          Text(_isReadingMode ? 'Kart Görünümü' : 'Okuma Modu'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'text_size',
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'text_fields',
                            color: theme.colorScheme.onSurface,
                            size: 20,
                          ),
                          SizedBox(width: 3.w),
                          const Text('Metin Boyutu'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
      body: Column(
        children: [
          if (!_showFavoritesOnly && _searchQuery.isEmpty) ...[
            CategoryTabWidget(
              categories: _categories,
              tabController: _tabController,
              onTabChanged: () {
                setState(() {});
              },
            ),
          ],
          Expanded(
            child: _filteredPrayers.isEmpty
                ? (_showFavoritesOnly
                    ? const EmptyFavoritesWidget()
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'search_off',
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                              size: 64,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Sonuç bulunamadı',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Farklı bir arama deneyin',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ))
                : RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(milliseconds: 500));
                      HapticFeedback.lightImpact();
                    },
                    child: ListView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      itemCount: _filteredPrayers.length,
                      itemBuilder: (context, index) {
                        final prayer = _filteredPrayers[index];
                        return PrayerCardWidget(
                          prayer: prayer,
                          isFavorite: _favoritePrayerIds.contains(prayer['id']),
                          isReadingMode: _isReadingMode,
                          textSize: _textSize,
                          onFavoriteToggle: () =>
                              _toggleFavorite(prayer['id'] as int),
                          onLongPress: () =>
                              _showPrayerContextMenu(context, prayer),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 3,
        onTap: (index) {
          // Navigation handled by CustomBottomBar
        },
      ),
    );
  }

  void _showTextSizeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('Metin Boyutu', style: theme.textTheme.titleLarge),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Küçük', style: theme.textTheme.bodySmall),
                      Text('Orta', style: theme.textTheme.bodyMedium),
                      Text('Büyük', style: theme.textTheme.bodyLarge),
                    ],
                  ),
                  Slider(
                    value: _textSize,
                    min: 12.0,
                    max: 20.0,
                    divisions: 8,
                    label: _textSize.round().toString(),
                    onChanged: (value) {
                      setDialogState(() {
                        _textSize = value;
                      });
                      setState(() {
                        _textSize = value;
                      });
                    },
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Örnek Metin',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontSize: _textSize),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }
}
