import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/custom_icon_widget.dart';

/// Period Mode Settings Widget
/// Allows users to toggle special day mode for female users
class PeriodModeSettingsWidget extends StatelessWidget {
  final bool isPeriodModeEnabled;
  final Function(bool) onToggle;

  const PeriodModeSettingsWidget({
    super.key,
    required this.isPeriodModeEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'event_available',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Özel Gün Modu',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Description
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              'Bu mod aktif olduğunda namaz takibi yapılamaz ve ana sayfada hatırlatıcı mesaj gösterilir. Kadın kullanıcılar için özel günlerde ibadet muafiyeti sağlar.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Toggle switch
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPeriodModeEnabled
                    ? theme.colorScheme.primary.withValues(alpha: 0.3)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Özel Gün Modu',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        isPeriodModeEnabled ? 'Aktif' : 'Pasif',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isPeriodModeEnabled
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isPeriodModeEnabled,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    onToggle(value);
                  },
                  activeColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Info note
          if (isPeriodModeEnabled)
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.pink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.pink.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.pink.shade400,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Özel gün modunuz aktif. Zikir ve dua ile vakit geçirebilirsiniz.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.pink.shade700,
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
