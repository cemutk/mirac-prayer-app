import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/custom_app_bar.dart';

/// Surah Detail Widget
/// Displays full surah with Arabic text, Turkish transliteration, and Turkish translation
class SurahDetailWidget extends StatelessWidget {
  final Map<String, dynamic> surah;

  const SurahDetailWidget({
    super.key,
    required this.surah,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verses = surah['verses'] as List<dynamic>;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: surah['name'],
        subtitle: '${surah['nameArabic']} - ${surah['verseCount']} Ayet',
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Surah header
            Container(
              padding: EdgeInsets.all(4.w),
              margin: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    surah['nameArabic'],
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '${surah['revelationPlace']} - ${surah['verseCount']} Ayet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Bismillah (except for Surah Tawbah and Ayetel Kursi)
            if (surah['number'] != 9 && surah['number'] != 2)
              Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Text(
                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),

            // Verses list
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: verses.length,
                itemBuilder: (context, index) {
                  final verse = verses[index];
                  return _buildVerseCard(context, verse, theme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseCard(
    BuildContext context,
    Map<String, dynamic> verse,
    ThemeData theme,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Verse number badge
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${verse['verseNumber']}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Arabic text (Right-aligned, large font, Uthmani style)
          Text(
            verse['arabic'],
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 22.sp,
              color: theme.colorScheme.onSurface,
              height: 2.0,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),

          SizedBox(height: 2.h),

          // Divider
          Divider(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            thickness: 1,
          ),

          SizedBox(height: 1.5.h),

          // Turkish transliteration (Left-aligned, BOLD, colored, prominent)
          Text(
            verse['transliteration'] ?? '',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: theme.colorScheme.primary,
              height: 1.5,
            ),
            textAlign: TextAlign.left,
          ),

          SizedBox(height: 1.5.h),

          // Turkish translation (Left-aligned, italic, grey tone)
          Text(
            verse['meaning'] ?? verse['turkish'] ?? '',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.6,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
