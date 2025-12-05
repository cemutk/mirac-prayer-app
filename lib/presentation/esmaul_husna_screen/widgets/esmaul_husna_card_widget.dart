import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';

/// Individual card widget for displaying each of Allah's Beautiful Names
/// Features Arabic calligraphy, Turkish meaning, and dhikr integration button
class EsmaulHusnaCardWidget extends StatelessWidget {
  final String arabic;
  final String transliteration;
  final String turkish;
  final String meaning;
  final int dhikrCount;
  final String description;
  final VoidCallback onDhikrTap;

  const EsmaulHusnaCardWidget({
    super.key,
    required this.arabic,
    required this.transliteration,
    required this.turkish,
    required this.meaning,
    required this.dhikrCount,
    required this.description,
    required this.onDhikrTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme colors - Dark green and gold
    final primaryColor = isDark ? AppTheme.primaryDark : AppTheme.primaryLight;
    final accentColor = isDark ? AppTheme.accentDark : AppTheme.accentLight;
    final cardColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Main content row
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Arabic name with decorative border
                Container(
                  width: 30.w,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withValues(alpha: 0.05),
                        accentColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      arabic,
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                SizedBox(width: 3.w),

                // Right side - Turkish info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Transliteration
                      Text(
                        transliteration,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),

                      // Turkish pronunciation
                      Text(
                        turkish,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 1.h),

                      // Meaning
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.8.h,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          meaning,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),

                      // Description
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            color: theme.dividerColor.withValues(alpha: 0.3),
            thickness: 1,
            height: 1,
          ),

          // Bottom section - Dhikr button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dhikr count badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.5.w,
                    vertical: 0.8.h,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.radio_button_checked,
                        size: 16,
                        color: primaryColor,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Zikir Sayısı: $dhikrCount',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Dhikr button
                ElevatedButton.icon(
                  onPressed: onDhikrTap,
                  icon: Icon(
                    Icons.radio_button_checked_rounded,
                    size: 18,
                  ),
                  label: Text('Zikir Çek'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.2.h,
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
