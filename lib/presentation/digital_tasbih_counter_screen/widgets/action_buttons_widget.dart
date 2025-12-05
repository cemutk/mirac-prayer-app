import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Action buttons for reset and history
class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onHistory;

  const ActionButtonsWidget({
    super.key,
    required this.onReset,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onReset,
              icon: CustomIconWidget(
                iconName: 'refresh',
                size: 20,
                color: theme.colorScheme.error,
              ),
              label: const Text('Sıfırla'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onHistory,
              icon: CustomIconWidget(
                iconName: 'history',
                size: 20,
                color: theme.colorScheme.onPrimary,
              ),
              label: const Text('Geçmiş'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
