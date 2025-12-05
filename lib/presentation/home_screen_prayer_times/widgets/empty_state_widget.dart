import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget displaying empty state when no city is selected
/// Prompts user to select their city for prayer times
class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onSelectCity;

  const EmptyStateWidget({
    super.key,
    required this.onSelectCity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'location_city',
                  color: theme.colorScheme.primary,
                  size: 80,
                ),
              ),
            ),
            SizedBox(height: 4.h),

            // Title
            Text(
              'Şehir Seçilmedi',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),

            // Description
            Text(
              'Namaz vakitlerini görmek için lütfen şehrinizi seçin',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),

            // Select City Button
            ElevatedButton.icon(
              onPressed: onSelectCity,
              icon: CustomIconWidget(
                iconName: 'location_on',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text('Şehir Seç'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 2.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
