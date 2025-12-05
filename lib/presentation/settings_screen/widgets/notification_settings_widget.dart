import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class NotificationSettingsWidget extends StatelessWidget {
  final bool enablePrayerNotifications;
  final bool enableHolidayNotifications;
  final bool enableAzanSound;
  final int offsetMinutes;
  final ValueChanged<bool> onPrayerToggle;
  final ValueChanged<bool> onHolidayToggle;
  final ValueChanged<bool> onAzanSoundToggle;
  final ValueChanged<int> onOffsetChange;

  const NotificationSettingsWidget({
    super.key,
    required this.enablePrayerNotifications,
    required this.enableHolidayNotifications,
    required this.enableAzanSound,
    required this.offsetMinutes,
    required this.onPrayerToggle,
    required this.onHolidayToggle,
    required this.onAzanSoundToggle,
    required this.onOffsetChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'notifications',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Bildirim Ayarları',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Namaz vakti bildirimleri toggle + offset
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Namaz vakti bildirimleri'),
              subtitle: const Text('Namaz vakitleri için bildirimleri etkinleştir'),
              trailing: Switch(
                value: enablePrayerNotifications,
                onChanged: onPrayerToggle,
              ),
            ),
            
            // Ezan sesi toggle (only visible when prayer notifications enabled)
            if (enablePrayerNotifications) ...[
              ListTile(
                contentPadding: EdgeInsets.only(left: 4.w),
                leading: Icon(
                  Icons.music_note,
                  color: enableAzanSound 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.outline,
                  size: 20,
                ),
                title: const Text('Ezan Sesi'),
                subtitle: Text(
                  enableAzanSound 
                      ? 'Bildirimde ezan sesi çalacak' 
                      : 'Varsayılan bildirim sesi',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.outline,
                  ),
                ),
                trailing: Switch(
                  value: enableAzanSound,
                  onChanged: onAzanSoundToggle,
                ),
              ),
            ],
            
            Padding(
              padding: EdgeInsets.only(left: 2.w, right: 2.w),
              child: Row(
                children: [
                  const Expanded(child: Text('Bildirim öncesi (dakika)')),
                  DropdownButton<int>(
                    value: offsetMinutes,
                    items: const [0, 5, 10, 15, 30]
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text('$m'),
                            ))
                        .toList(),
                    onChanged: (v) => onOffsetChange(v ?? 0),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.h),

            Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            SizedBox(height: 1.h),

            // Dini bayram bildirimleri
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Dini bayram & önemli gün bildirimi'),
              subtitle: const Text('Ramazan Bayramı, Kurban Bayramı ve diğer günler'),
              trailing: Switch(
                value: enableHolidayNotifications,
                onChanged: onHolidayToggle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Old per-prayer helper removed. Notification UI is simplified.
}

