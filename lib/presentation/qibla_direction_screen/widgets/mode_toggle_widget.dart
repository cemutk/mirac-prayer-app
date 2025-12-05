import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for toggling between sensor-based and city-based Qibla modes
class ModeToggleWidget extends StatelessWidget {
  final bool isSensorMode;
  final bool hasLocationPermission;
  final VoidCallback onToggle;

  const ModeToggleWidget({
    super.key,
    required this.isSensorMode,
    required this.hasLocationPermission,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(0.5.w),
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
      child: Row(
        children: [
          Expanded(
            child: _buildModeButton(
              context: context,
              label: 'Sensor Mode',
              icon: 'explore',
              isSelected: isSensorMode,
              isEnabled: hasLocationPermission,
              onTap: () {
                if (!isSensorMode) onToggle();
              },
            ),
          ),
          Expanded(
            child: _buildModeButton(
              context: context,
              label: 'City Mode',
              icon: 'location_city',
              isSelected: !isSensorMode,
              isEnabled: true,
              onTap: () {
                if (isSensorMode) onToggle();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required BuildContext context,
    required String label,
    required String icon,
    required bool isSelected,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : isEnabled
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.3),
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : isEnabled
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
