import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Bottom sheet widget for quick city selection
/// Displays popular cities for fast access
class CitySelectionBottomSheetWidget extends StatefulWidget {
  final Function(String city, String district) onCitySelected;

  const CitySelectionBottomSheetWidget({
    super.key,
    required this.onCitySelected,
  });

  @override
  State<CitySelectionBottomSheetWidget> createState() =>
      _CitySelectionBottomSheetWidgetState();
}

class _CitySelectionBottomSheetWidgetState
    extends State<CitySelectionBottomSheetWidget> {
  final List<Map<String, String>> _popularCities = [
    {"city": "İstanbul", "district": "Kadıköy"},
    {"city": "İstanbul", "district": "Üsküdar"},
    {"city": "Ankara", "district": "Çankaya"},
    {"city": "İzmir", "district": "Konak"},
    {"city": "Bursa", "district": "Osmangazi"},
    {"city": "Antalya", "district": "Muratpaşa"},
    {"city": "Adana", "district": "Seyhan"},
    {"city": "Konya", "district": "Meram"},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40.w,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hızlı Şehir Seçimi',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: theme.colorScheme.onSurface,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Popular Cities List
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                itemCount: _popularCities.length,
                itemBuilder: (context, index) {
                  final cityData = _popularCities[index];
                  return _buildCityTile(context, cityData);
                },
              ),
            ),

            // View All Button
            Padding(
              padding: EdgeInsets.all(4.w),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/city-selection-screen');
                },
                icon: CustomIconWidget(
                  iconName: 'search',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                label: Text('Tüm Şehirleri Görüntüle'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 6.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityTile(BuildContext context, Map<String, String> cityData) {
    final theme = Theme.of(context);
    final city = cityData["city"]!;
    final district = cityData["district"]!;

    return ListTile(
      leading: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: 'location_city',
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
      ),
      title: Text(
        city,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        district,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        size: 24,
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onCitySelected(city, district);
      },
    );
  }
}
