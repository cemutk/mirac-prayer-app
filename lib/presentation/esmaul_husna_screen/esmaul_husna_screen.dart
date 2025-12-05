import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../routes/app_routes.dart';
import '../../data/esmaul_husna_data.dart';
import './widgets/esmaul_husna_card_widget.dart';

/// Esmaul Husna Screen - Displays Allah's 99 Beautiful Names
/// Fourth tab in bottom navigation between Tesbih and Prayers
/// Features elegant cards with Arabic calligraphy, meanings, and dhikr integration
class EsmaulHusnaScreen extends StatefulWidget {
  const EsmaulHusnaScreen({super.key});

  @override
  State<EsmaulHusnaScreen> createState() => _EsmaulHusnaScreenState();
}

class _EsmaulHusnaScreenState extends State<EsmaulHusnaScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Esmaül Hüsna',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Allah\'ın 99 Güzel İsmi',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Divider(
              color: theme.dividerColor,
              thickness: 1,
              height: 1,
            ),

            // List of Names
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                itemCount: esmaulHusnaList.length,
                itemBuilder: (context, index) {
                  final name = esmaulHusnaList[index];
                  return EsmaulHusnaCardWidget(
                    arabic: name['arabic'],
                    transliteration: name['transliteration'],
                    turkish: name['turkish'],
                    meaning: name['meaning'],
                    dhikrCount: name['dhikrCount'],
                    description: name['description'],
                    onDhikrTap: () => _navigateToTasbih(context, name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 3,
        onTap: (index) {},
      ),
    );
  }

  void _navigateToTasbih(BuildContext context, Map<String, dynamic> name) {
    // Navigate to Digital Tasbih with pre-filled values
    Navigator.pushNamed(
      context,
      AppRoutes.digitalTasbihCounterScreen,
      arguments: {
        'dhikrName': '${name['transliteration']} - ${name['turkish']}',
        'targetCount': name['dhikrCount'],
        'customDhikr': true,
        'arabicText': name['arabic'],
      },
    );
  }
}