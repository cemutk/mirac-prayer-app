import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/custom_icon_widget.dart';

/// Surah Card Widget
/// Displays surah information in a card format
class SurahCardWidget extends StatelessWidget {
  final Map<String, dynamic> surah;
  final VoidCallback onTap;

  const SurahCardWidget({
    super.key,
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Surah number badge
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${surah['number']}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 4.w),

              // Surah info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Arabic name
                    Text(
                      surah['nameArabic'],
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 20.sp,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(height: 0.5.h),
                    // Turkish name
                    Text(
                      surah['name'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    // Meta info
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'location_on',
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          surah['revelationPlace'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        CustomIconWidget(
                          iconName: 'article',
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${surah['verseCount']} Ayet',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Chevron icon
              CustomIconWidget(
                iconName: 'chevron_right',
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
