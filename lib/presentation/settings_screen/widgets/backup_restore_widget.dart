import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BackupRestoreWidget extends StatelessWidget {
  final VoidCallback onBackup;
  final VoidCallback onRestore;

  const BackupRestoreWidget({
    super.key,
    required this.onBackup,
    required this.onRestore,
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
                  iconName: 'backup',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Yedekleme & Geri Yükleme',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onBackup,
                    icon: CustomIconWidget(
                      iconName: 'cloud_upload',
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    label: const Text('Yedekle'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRestore,
                    icon: CustomIconWidget(
                      iconName: 'cloud_download',
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    label: const Text('Geri Yükle'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'info',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Yedeklenen Veriler',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  _buildBackupItem(context, 'Kullanıcı tercihleri'),
                  _buildBackupItem(context, 'Favori dualar'),
                  _buildBackupItem(context, 'Tasbih geçmişi'),
                  _buildBackupItem(context, 'Bildirim ayarları'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(left: 6.w, top: 0.5.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'check_circle',
            color: theme.colorScheme.primary,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
