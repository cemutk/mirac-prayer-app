import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/kids_mode_service.dart';
import 'widgets/kids_profile_selector.dart';
import 'widgets/kids_dashboard_widget.dart';
import 'widgets/kids_lesson_list_widget.dart';
import 'widgets/kids_surah_memorization_widget.dart';
import 'widgets/kids_badges_widget.dart';

class KidsModeScreen extends StatefulWidget {
  const KidsModeScreen({super.key});

  @override
  State<KidsModeScreen> createState() => _KidsModeScreenState();
}

class _KidsModeScreenState extends State<KidsModeScreen>
    with SingleTickerProviderStateMixin {
  final KidsModeService _kidsService = KidsModeService();
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initService();
  }

  Future<void> _initService() async {
    await _kidsService.init();
    _kidsService.addListener(_onServiceUpdate);
    setState(() => _isLoading = false);
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _kidsService.removeListener(_onServiceUpdate);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _getKidsBackground(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Profil yoksa profil oluşturma ekranı göster
    if (!_kidsService.hasProfiles) {
      return _buildCreateProfileScreen();
    }

    return Scaffold(
      backgroundColor: _getKidsBackground(),
      appBar: _buildKidsAppBar(),
      body: Column(
        children: [
          // Profil seçici ve dashboard
          KidsProfileSelector(
            profiles: _kidsService.profiles,
            activeProfile: _kidsService.activeProfile,
            onProfileSelect: (id) => _kidsService.setActiveProfile(id),
            onAddProfile: _showCreateProfileDialog,
          ),
          const SizedBox(height: 8),
          KidsDashboardWidget(
            profile: _kidsService.activeProfile!,
            stats: _kidsService.getProfileStats(),
          ),
          const SizedBox(height: 8),
          // Tab bar
          _buildKidsTabBar(),
          // Tab içeriği
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Abdest Dersleri
                KidsLessonListWidget(
                  lessons: KidsModeService.abdestLessons,
                  category: 'abdest',
                  categoryTitle: '💧 Abdest Dersleri',
                  categoryColor: Colors.blue,
                  onLessonComplete: (lessonId, points) {
                    _kidsService.completeLesson(lessonId, points);
                    _showCompletionCelebration(points);
                  },
                  isLessonCompleted: _kidsService.isLessonCompleted,
                ),
                // Namaz Dersleri
                KidsLessonListWidget(
                  lessons: KidsModeService.namazLessons,
                  category: 'namaz',
                  categoryTitle: '🕌 Namaz Dersleri',
                  categoryColor: Colors.green,
                  onLessonComplete: (lessonId, points) {
                    _kidsService.completeLesson(lessonId, points);
                    _showCompletionCelebration(points);
                  },
                  isLessonCompleted: _kidsService.isLessonCompleted,
                ),
                // Sure Ezberleme
                KidsSurahMemorizationWidget(
                  surahs: KidsModeService.easyToMemorizeSurahs,
                  getSurahProgress: _kidsService.getSurahProgress,
                  onProgressUpdate: (surahId, progress) {
                    _kidsService.updateSurahProgress(surahId, progress);
                    if (progress >= 100) {
                      _showMemorizationCelebration();
                    }
                  },
                ),
                // Rozetler
                KidsBadgesWidget(
                  allBadges: KidsModeService.allBadges,
                  earnedBadges: _kidsService.activeProfile?.earnedBadges ?? [],
                ),
              ],
            ),
          ),
        ],
      ),
      // Namaz kaydetme FAB'ı
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _kidsService.recordPrayer();
          _showPrayerRecordedSnackbar();
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        label: const Text(
          'Namaz Kıldım!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Color _getKidsBackground() {
    return const Color(0xFFFFF8E1); // Warm cream color for kids
  }

  PreferredSizeWidget _buildKidsAppBar() {
    return AppBar(
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          const Text(
            '🧒 Çocuk Modu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Ebeveyn modu butonu
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: _showParentModeDialog,
            tooltip: 'Ebeveyn Paneli',
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: _showHelpDialog,
        ),
      ],
    );
  }

  Widget _buildKidsTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        indicator: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(25),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('💧'),
                  SizedBox(width: 4),
                  Text('Abdest'),
                ],
              ),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🕌'),
                  SizedBox(width: 4),
                  Text('Namaz'),
                ],
              ),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('📖'),
                  SizedBox(width: 4),
                  Text('Sureler'),
                ],
              ),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🏆'),
                  SizedBox(width: 4),
                  Text('Rozetler'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateProfileScreen() {
    return Scaffold(
      backgroundColor: _getKidsBackground(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🌟',
                  style: TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Hoş Geldin!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Çocuk moduna başlamak için\nbir profil oluşturalım!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _showCreateProfileDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Profil Oluştur'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Geri Dön'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateProfileDialog() {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    String selectedEmoji = '👦';

    final emojis = ['👦', '👧', '🧒', '👶', '🧒🏻', '👦🏻', '👧🏻', '🧒🏽', '👦🏽', '👧🏽'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Text('🌟 '),
              Text('Yeni Profil'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar seçimi
                const Text('Avatar Seç:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: emojis.map((emoji) {
                    final isSelected = selectedEmoji == emoji;
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() => selectedEmoji = emoji);
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.orange : Colors.grey[200],
                          borderRadius: BorderRadius.circular(25),
                          border: isSelected
                              ? Border.all(color: Colors.orange, width: 3)
                              : null,
                        ),
                        child: Center(
                          child: Text(emoji, style: const TextStyle(fontSize: 28)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'İsim',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Yaş',
                    prefixIcon: const Icon(Icons.cake),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final ageText = ageController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('İsim giriniz')),
                  );
                  return;
                }

                final age = int.tryParse(ageText) ?? 7;

                await _kidsService.createProfile(
                  name: name,
                  age: age,
                  avatarEmoji: selectedEmoji,
                );

                if (mounted) {
                  Navigator.pop(context);
                  _showWelcomeDialog(name);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWelcomeDialog(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              'Hoş Geldin $name!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Şimdi abdest ve namaz öğrenmeye başlayabilirsin!\n\nHer dersi tamamladığında puan kazanacak ve rozetler açacaksın!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hadi Başlayalım! 🚀'),
          ),
        ],
      ),
    );
  }

  void _showCompletionCelebration(int points) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎊', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text(
              'Harika!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+$points Puan Kazandın!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Devam Et! 💪'),
          ),
        ],
      ),
    );
  }

  void _showMemorizationCelebration() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text(
              'MÜTHİŞ!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bir Sure Ezberledin!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Allahu Ekber! Hafızlık yolunda ilerliyorsun!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Devam Et! 🌟'),
          ),
        ],
      ),
    );
  }

  void _showPrayerRecordedSnackbar() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🕌 '),
            const Text('Namaz kaydedildi! +5 Puan'),
            const Spacer(),
            Text(
              '🔥 ${_kidsService.activeProfile?.prayerStreak ?? 0} gün',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showParentModeDialog() {
    // Basit bir PIN kontrolü (gerçek uygulamada daha güvenli olmalı)
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.orange),
            SizedBox(width: 8),
            Text('Ebeveyn Paneli'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ebeveyn paneline erişmek için PIN giriniz:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: '• • • •',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Varsayılan PIN: 1234
              if (pinController.text == '1234') {
                Navigator.pop(context);
                _showParentDashboard();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Yanlış PIN'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Giriş'),
          ),
        ],
      ),
    );
  }

  void _showParentDashboard() {
    final stats = _kidsService.getProfileStats();
    final profile = _kidsService.activeProfile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Ebeveyn Paneli',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Çocuk bilgisi
                    Card(
                      child: ListTile(
                        leading: Text(
                          profile?.avatarEmoji ?? '👦',
                          style: const TextStyle(fontSize: 40),
                        ),
                        title: Text(
                          profile?.name ?? 'Profil Yok',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${profile?.age ?? 0} yaşında • Seviye ${stats['level']}'),
                        trailing: Text(
                          '${stats['totalPoints']} Puan',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // İstatistikler
                    const Text(
                      '📊 İstatistikler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow('📚 Tamamlanan Dersler', '${stats['lessonsCompleted']}'),
                    _buildStatRow('📖 Ezberlenen Sureler', '${stats['surahsMemorized']}'),
                    _buildStatRow('🏆 Kazanılan Rozetler', '${stats['badgesCount']}'),
                    _buildStatRow('🔥 Namaz Serisi', '${stats['prayerStreak']} gün'),
                    const SizedBox(height: 16),
                    // Ezberlenen sureler detayı
                    const Text(
                      '📖 Sure İlerlemesi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...KidsModeService.easyToMemorizeSurahs.map((surah) {
                      final progress = _kidsService.getSurahProgress(surah['id'] as String);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Text(surah['emoji'] as String),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    surah['name'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: progress / 100,
                                    backgroundColor: Colors.grey[200],
                                    color: progress >= 100 ? Colors.green : Colors.orange,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$progress%',
                              style: TextStyle(
                                color: progress >= 100 ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    // Profil yönetimi
                    const Text(
                      '👥 Profil Yönetimi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showCreateProfileDialog();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Yeni Profil'),
                        ),
                        if (profile != null)
                          OutlinedButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Profili Sil'),
                                  content: Text('${profile.name} profilini silmek istediğinize emin misiniz?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('İptal'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Sil', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && mounted) {
                                await _kidsService.deleteProfile(profile.id);
                                Navigator.pop(context);
                              }
                            },
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            label: const Text('Profili Sil', style: TextStyle(color: Colors.red)),
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

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('❓ '),
            Text('Nasıl Kullanılır?'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('💧 Abdest Dersleri', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Adım adım abdest almayı öğren'),
              SizedBox(height: 8),
              Text('🕌 Namaz Dersleri', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Namaz kılmayı renkli anlatımlarla öğren'),
              SizedBox(height: 8),
              Text('📖 Sure Ezberleme', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Kısa sureleri Türkçe mealiyle ezberle'),
              SizedBox(height: 8),
              Text('🏆 Rozetler', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Başarılarınla rozet kazan!'),
              SizedBox(height: 8),
              Text('✅ Namaz Kıldım Butonu', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Her gün namaz kılınca bas, seri oluştur!'),
              SizedBox(height: 12),
              Divider(),
              SizedBox(height: 8),
              Text('👨‍👩‍👧 Ebeveyn Paneli', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('PIN: 1234 ile gelişimi takip edin'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Anladım!'),
          ),
        ],
      ),
    );
  }
}
