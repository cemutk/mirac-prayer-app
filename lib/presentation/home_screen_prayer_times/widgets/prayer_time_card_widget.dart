import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget displaying individual prayer time card
/// Shows prayer name, time, and status indicators
class PrayerTimeCardWidget extends StatelessWidget {
  final Map<String, dynamic> prayer;
  final VoidCallback? onLongPress;

  const PrayerTimeCardWidget({
    super.key,
    required this.prayer,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPast = prayer["isPast"] as bool;
    final isCurrent = prayer["isCurrent"] as bool;

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onLongPress?.call();
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isCurrent
              ? theme.colorScheme.tertiary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrent
                ? theme.colorScheme.tertiary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isCurrent ? 2 : 1,
          ),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Prayer Icon
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: isCurrent
                    ? theme.colorScheme.tertiary.withValues(alpha: 0.2)
                    : isPast
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.05)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _getPrayerIcon(prayer["name"] as String),
                  color: isCurrent
                      ? theme.colorScheme.tertiary
                      : isPast
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                          : theme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 4.w),

            // Prayer Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayer["name"] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isPast
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                          : theme.colorScheme.onSurface,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  if (isCurrent) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      'Şu anki vakit',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Prayer Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  prayer["time"] as String,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: isCurrent
                        ? theme.colorScheme.tertiary
                        : isPast
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                            : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
                if (isPast) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    'Geçti',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ],
            ),

            // Status Indicator
            SizedBox(width: 3.w),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isCurrent
                    ? theme.colorScheme.tertiary
                    : isPast
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.2)
                        : theme.colorScheme.primary.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPrayerIcon(String prayerName) {
    switch (prayerName) {
      case 'İmsak':
        return 'nightlight';
      case 'Güneş':
        return 'wb_sunny';
      case 'Öğle':
        return 'wb_twilight';
      case 'İkindi':
        return 'wb_cloudy';
      case 'Akşam':
        return 'nights_stay';
      case 'Yatsı':
        return 'dark_mode';
      default:
        return 'access_time';
    }
  }
}
