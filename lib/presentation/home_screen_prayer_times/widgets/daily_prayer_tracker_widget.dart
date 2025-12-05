import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for tracking daily prayer completion
/// Shows 5 prayer buttons that can be toggled
/// NEW: Disabled when period mode is active
class DailyPrayerTrackerWidget extends StatefulWidget {
  final Map<String, bool> prayerStatus;
  final Function(String) onPrayerToggle;
  final bool showCongratulations;

  const DailyPrayerTrackerWidget({
    super.key,
    required this.prayerStatus,
    required this.onPrayerToggle,
    required this.showCongratulations,
  });

  @override
  State<DailyPrayerTrackerWidget> createState() =>
      _DailyPrayerTrackerWidgetState();
}

class _DailyPrayerTrackerWidgetState extends State<DailyPrayerTrackerWidget> {
  bool _isPeriodModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPeriodMode();
  }

  Future<void> _loadPeriodMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _isPeriodModeEnabled = prefs.getBool('isPeriodModeEnabled') ?? false;
        });
      }
    } catch (e) {
      debugPrint('Error loading period mode: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // NEW: Hide tracker if period mode is enabled
    if (_isPeriodModeEnabled) {
      return SizedBox.shrink();
    }

    final prayers = [
      {'key': 'sabah', 'name': 'Sabah'},
      {'key': 'ogle', 'name': 'Öğle'},
      {'key': 'ikindi', 'name': 'İkindi'},
      {'key': 'aksam', 'name': 'Akşam'},
      {'key': 'yatsi', 'name': 'Yatsı'},
    ];

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(3.w),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Bugünkü İbadetlerim',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: prayers.map((prayer) {
                  final isCompleted =
                      widget.prayerStatus[prayer['key']] ?? false;
                  return _buildPrayerButton(
                    context: context,
                    prayerKey: prayer['key']!,
                    prayerName: prayer['name']!,
                    isCompleted: isCompleted,
                    theme: theme,
                    isEnabled:
                        !_isPeriodModeEnabled, // NEW: Disable if period mode
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // Congratulations message
        if (widget.showCongratulations)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(top: 2.h, left: 4.w, right: 4.w),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2D5016).withValues(alpha: 0.1),
                  const Color(0xFFD4AF37).withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '🎉',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tebrikler!',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Bugünkü tüm namazlarınızı tamamladınız',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPrayerButton({
    required BuildContext context,
    required String prayerKey,
    required String prayerName,
    required bool isCompleted,
    required ThemeData theme,
    required bool isEnabled, // NEW: Enable/disable parameter
  }) {
    return GestureDetector(
      onTap: isEnabled
          ? () {
              HapticFeedback.mediumImpact();
              widget.onPrayerToggle(prayerKey);
            }
          : null, // NEW: Disable tap if not enabled
      child: Opacity(
        opacity:
            isEnabled ? 1.0 : 0.5, // NEW: Visual feedback for disabled state
        child: Column(
          children: [
            Container(
              width: 14.w,
              height: 14.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: Colors.white,
                        size: 20,
                      )
                    : CustomIconWidget(
                        iconName: 'circle',
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        size: 16,
                      ),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              prayerName,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 9.sp,
                fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                color: isCompleted
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
