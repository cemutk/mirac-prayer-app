import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../city_selection_screen/city_selection_screen.dart';

class LocationSettingsWidget extends StatelessWidget {
  final String selectedCity;
  final ValueChanged<String> onCityChange;
  final VoidCallback onChangeLocation;

  const LocationSettingsWidget({
    super.key,
    required this.selectedCity,
    required this.onCityChange,
    required this.onChangeLocation,
  });

  Future<void> _quickSelectCity(BuildContext context, String city) async {
    // Instead of instantly setting city without a district, open the full
    // CitySelectionScreen with the province preselected so the user can
    // choose an ilçe (district). This ensures correct district selection.
    try {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CitySelectionScreen(initialProvince: city),
      ));

      // After user finishes selection, reload saved city from prefs
      final prefs = await SharedPreferences.getInstance();
      final savedProvince = prefs.getString('selected_province') ??
          prefs.getString('selectedCity') ??
          city;

      onCityChange(savedProvince);
      // Pop the bottom sheet (location settings) if still open
      if (Navigator.canPop(context)) Navigator.pop(context);
    } catch (e) {
      debugPrint('Error quick-selecting city: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<String> recentCities = [
      'İstanbul',
      'Ankara',
      'İzmir',
      'Bursa',
    ];

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
                  iconName: 'location_on',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Konum Ayarları',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'location_city',
                    color: theme.colorScheme.onSurface,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mevcut Şehir',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          selectedCity,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onChangeLocation,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                    ),
                    child: const Text('Değiştir'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Hızlı Erişim',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: recentCities.map((city) {
                final isSelected = city == selectedCity;
                return InkWell(
                  onTap: () => _quickSelectCity(context, city),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      city,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
