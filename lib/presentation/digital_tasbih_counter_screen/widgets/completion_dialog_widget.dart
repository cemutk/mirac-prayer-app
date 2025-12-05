import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Celebration dialog shown when target count is reached
class CompletionDialogWidget extends StatelessWidget {
  final String dhikr;
  final int count;
  final VoidCallback onContinue;
  final VoidCallback onNewSession;

  const CompletionDialogWidget({
    super.key,
    required this.dhikr,
    required this.count,
    required this.onContinue,
    required this.onNewSession,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'celebration',
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Masha Allah!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'You have completed $count $dhikr',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onContinue,
                    child: const Text('Continue'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onNewSession,
                    child: const Text('New Session'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
