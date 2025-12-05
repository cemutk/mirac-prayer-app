import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PrayerCalculationWidget extends StatelessWidget {
  final String calculationMethod;
  final ValueChanged<String> onMethodChange;

  const PrayerCalculationWidget({
    super.key,
    required this.calculationMethod,
    required this.onMethodChange,
  });

  // Map method names to API method IDs
  int _getMethodId(String methodName) {
    switch (methodName) {
      case 'Diyanet':
        return 13;
      case 'ISNA':
        return 2;
      case 'MWL':
        return 3;
      default:
        return 13; // Default to Diyanet
    }
  }

  Future<void> _selectMethod(BuildContext context, String methodName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final methodId = _getMethodId(methodName);

      // Save both method name and ID
      await prefs.setString('calculationMethod', methodName);
      await prefs.setInt('calculationMethodId', methodId);

      // Trigger callback to update UI and refetch prayer times
      onMethodChange(methodName);

      HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error selecting calculation method: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, String>> methods = [
      {
        'name': 'Diyanet',
        'description': 'Türkiye Diyanet İşleri Başkanlığı',
      },
      {
        'name': 'ISNA',
        'description': 'Islamic Society of North America',
      },
      {
        'name': 'MWL',
        'description': 'Muslim World League',
      },
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
                  iconName: 'calculate',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Namaz Vakti Hesaplama',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            ...methods.map((method) {
              final isSelected = method['name'] == calculationMethod;
              return Column(
                children: [
                  InkWell(
                    onTap: () => _selectMethod(context, method['name']!),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: method['name']!,
                            groupValue: calculationMethod,
                            onChanged: (value) {
                              if (value != null) {
                                _selectMethod(context, value);
                              }
                            },
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method['name']!,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  method['description']!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (method != methods.last) SizedBox(height: 1.h),
                ],
              );
            }).toList(),
            SizedBox(height: 1.5.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: theme.colorScheme.tertiary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Hesaplama yöntemi namaz vakitlerinin doğruluğunu etkiler',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
