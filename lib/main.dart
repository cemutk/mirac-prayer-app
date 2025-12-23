import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import '../core/theme_manager.dart';
import '../widgets/custom_error_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'services/notification_service.dart';
import 'services/prayer_times_service.dart';
import 'services/ad_service.dart';
import 'services/billing_service.dart';
import 'data/religious_days_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Turkish locale data for date formatting
  try {
    await initializeDateFormatting('tr_TR', null);
  } catch (e) {
    debugPrint('Locale init error: $e');
  }

  // Initialize theme manager
  final themeManager = ThemeManager();
  try {
    await themeManager.initialize();
  } catch (e) {
    debugPrint('Theme init error: $e');
  }

  // Initialize AdMob and Billing services
  try {
    await AdService().initialize();
    await BillingService().initialize();
    debugPrint('✅ Monetization services initialized');
  } catch (e) {
    debugPrint('⚠️ Monetization init error: $e');
  }

  // CRITICAL: Defer all notification/background work to AFTER app is running
  // This prevents iOS crash on startup
  
  bool _hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!_hasShownError) {
      _hasShownError = true;

      // Reset flag after 3 seconds to allow error widget on new screens
      Future.delayed(Duration(seconds: 5), () {
        _hasShownError = false;
      });

      return CustomErrorWidget(
        errorDetails: details,
      );
    }
    return SizedBox.shrink();
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    runApp(MyApp(themeManager: themeManager));
  });
}

class MyApp extends StatelessWidget {
  final ThemeManager themeManager;

  const MyApp({super.key, required this.themeManager});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return AnimatedBuilder(
        animation: themeManager,
        builder: (context, child) {
          return MaterialApp(
            title: 'mirac_prayer_assistant',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeManager.themeMode,
            // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(1.0),
                ),
                child: child!,
              );
            },
            // 🚨 END CRITICAL SECTION
            debugShowCheckedModeBanner: false,
            routes: AppRoutes.routes,
            initialRoute: AppRoutes.initial,
          );
        },
      );
    });
  }
}
