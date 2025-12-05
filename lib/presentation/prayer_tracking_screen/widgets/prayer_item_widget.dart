import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

/// Widget for displaying a single prayer item with toggle
class PrayerItemWidget extends StatelessWidget {
  final String prayerName;
  final bool isCompleted;
  final String? prayerTime;
  final VoidCallback onToggle;

  const PrayerItemWidget({
    super.key,
    required this.prayerName,
    required this.isCompleted,
    this.prayerTime,
    required this.onToggle,
  });

  IconData _getPrayerIcon() {
    switch (prayerName) {
      case 'Sabah':
        return Icons.wb_twilight;
      case 'Öğle':
        return Icons.wb_sunny;
      case 'İkindi':
        return Icons.sunny_snowing;
      case 'Akşam':
        return Icons.nights_stay_outlined;
      case 'Yatsı':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }

  Color _getPrayerColor(ThemeData theme) {
    switch (prayerName) {
      case 'Sabah':
        return Colors.orange;
      case 'Öğle':
        return Colors.amber;
      case 'İkindi':
        return Colors.deepOrange;
      case 'Akşam':
        return Colors.purple;
      case 'Yatsı':
        return Colors.indigo;
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prayerColor = _getPrayerColor(theme);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onToggle();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: isCompleted
              ? prayerColor.withValues(alpha: 0.15)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? prayerColor
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color: prayerColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Prayer Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                color: isCompleted
                    ? prayerColor
                    : prayerColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getPrayerIcon(),
                color: isCompleted ? Colors.white : prayerColor,
                size: 24,
              ),
            ),
            SizedBox(width: 4.w),
            
            // Prayer Name and Time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayerName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? prayerColor
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (prayerTime != null) ...[
                    SizedBox(height: 0.3.h),
                    Text(
                      prayerTime!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted ? prayerColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCompleted
                      ? prayerColor
                      : theme.colorScheme.outline.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
