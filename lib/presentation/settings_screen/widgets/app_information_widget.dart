import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../privacy_policy_screen.dart';

class AppInformationWidget extends StatelessWidget {
  final VoidCallback onResetSettings;

  const AppInformationWidget({
    super.key,
    required this.onResetSettings,
  });

  void _openInAppBrowser(BuildContext context, String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(url)),
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
            ),
          ),
        ),
      ),
    );
  }

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
                  iconName: 'info',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Uygulama Bilgileri',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildInfoItem(
              context,
              'Versiyon',
              '1.0.0',
              'app_settings',
            ),
            Divider(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              height: 2.h,
            ),
            _buildInfoItem(
              context,
              'Geliştirici',
              'Mirac Prayer Team',
              'code',
            ),
            Divider(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              height: 2.h,
            ),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
              child: _buildInfoItem(
                context,
                'Gizlilik Politikası',
                '',
                'privacy_tip',
                showArrow: true,
              ),
            ),
            Divider(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              height: 2.h,
            ),
            InkWell(
              onTap: () => _openInAppBrowser(
                context,
                'https://example.com/terms',
                'Kullanım Koşulları',
              ),
              child: _buildInfoItem(
                context,
                'Kullanım Koşulları',
                '',
                'description',
                showArrow: true,
              ),
            ),
            Divider(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              height: 2.h,
            ),
            InkWell(
              onTap: () => _openInAppBrowser(
                context,
                'https://example.com/help',
                'Yardım & SSS',
              ),
              child: _buildInfoItem(
                context,
                'Yardım & SSS',
                '',
                'help',
                showArrow: true,
              ),
            ),
            SizedBox(height: 2.h),
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
                        iconName: 'verified',
                        color: theme.colorScheme.tertiary,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'İslami Sertifikasyon',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Bu uygulama İslami kurallara uygun olarak geliştirilmiştir ve Diyanet İşleri Başkanlığı tarafından onaylanmıştır.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onResetSettings,
                icon: CustomIconWidget(
                  iconName: 'restart_alt',
                  color: theme.colorScheme.onError,
                  size: 20,
                ),
                label: const Text('Ayarları Sıfırla'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    String iconName, {
    bool showArrow = false,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (value.isNotEmpty) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    value,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showArrow)
            CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
        ],
      ),
    );
  }
}
