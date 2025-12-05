import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/quran_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/surah_card_widget.dart';
import './widgets/surah_detail_widget.dart';

/// Quran-i Kerim Screen
/// Displays list of popular surahs with detailed reading view
class QuranIKerimScreen extends StatefulWidget {
  const QuranIKerimScreen({super.key});

  @override
  State<QuranIKerimScreen> createState() => _QuranIKerimScreenState();
}

class _QuranIKerimScreenState extends State<QuranIKerimScreen> {
  int _currentIndex = 5; // Quran tab index in bottom navigation
  late Future<List<Map<String, dynamic>>> _surahsFuture;

  @override
  void initState() {
    super.initState();
    _surahsFuture = QuranService().getSurahs();
  }

  void _openSurahDetail(Map<String, dynamic> surah) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurahDetailWidget(surah: surah),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Kur\'an-ı Kerim',
        automaticallyImplyLeading: false,
        showDivider: true,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _surahsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Veriler yüklenemedi: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Sure bulunamadı.'));
            }

            final _surahs = snapshot.data!;

            return Column(
              children: [
                // Header info
                Container(
                  padding: EdgeInsets.all(4.w),
                  margin: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withAlpha(25),
                        theme.colorScheme.primary.withAlpha(12),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withAlpha(51),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomIconWidget(
                          iconName: 'menu_book',
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kur\'an-ı Kerim',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              '${_surahs.length} sure mevcut',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withAlpha(153),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Surahs list
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    itemCount: _surahs.length,
                    itemBuilder: (context, index) {
                      final surah = _surahs[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: SurahCardWidget(
                          surah: surah,
                          onTap: () => _openSurahDetail(surah),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
