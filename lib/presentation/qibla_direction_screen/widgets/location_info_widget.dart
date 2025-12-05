import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget displaying current location information and distance to Mecca
class LocationInfoWidget extends StatelessWidget {
  final String locationName;
  final double distanceToMecca;
  final bool isSensorMode;
  final DateTime? lastUpdateTime;

  const LocationInfoWidget({
    super.key,
    required this.locationName,
    required this.distanceToMecca,
    required this.isSensorMode,
    this.lastUpdateTime,
  });

  String _getTimeAgo() {
    if (lastUpdateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(lastUpdateTime!);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Location name (allow wrapping) and optional last-update time below
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomIconWidget(
                iconName: isSensorMode ? 'my_location' : 'location_city',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locationName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      softWrap: true,
                    ),
                    if (lastUpdateTime != null) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        _getTimeAgo(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Distance to Mecca
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'mosque',
                  color: theme.colorScheme.tertiary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Distance to Mecca: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  '${distanceToMecca.toStringAsFixed(0)} km',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.tertiary,
                    fontWeight: FontWeight.bold,
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
