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
import 'data/religious_days_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Turkish locale data for date formatting
  await initializeDateFormatting('tr_TR', null);

  // Initialize theme manager
  final themeManager = ThemeManager();
  await themeManager.initialize();

  // Initialize notifications and schedule cached prayers if enabled
  try {
    await NotificationService().initialize();

    final prefs = await SharedPreferences.getInstance();
    final prayerEnabled = prefs.getBool('enable_prayer_notifications') ?? true;
    final holidayEnabled = prefs.getBool('enable_holiday_notifications') ?? true;

    // If notifications are enabled, try to schedule from cached prayer times
    if (prayerEnabled || holidayEnabled) {
      // Load saved city/district and cached prayer times
      final city = prefs.getString('selectedCity') ?? prefs.getString('selected_province') ?? 'İstanbul';
      final district = prefs.getString('selected_district') ?? prefs.getString('selectedDistrict') ?? 'Kadıköy';

      final PrayerTimesService pts = PrayerTimesService();
      final cached = await pts.getCachedPrayerTimes(city, district);
      if (cached != null) {
        // Use timezone from cache if available
        final tzName = cached['timezone'] ?? prefs.getString('prayer_timezone') ?? 'Europe/Istanbul';
        tzdata.initializeTimeZones();
        tz.Location location;
        try {
          location = tz.getLocation(tzName);
        } catch (e) {
          location = tz.local;
        }

        final nowTz = tz.TZDateTime.now(location);

        final offsetMinutes = prefs.getInt('notification_offset_minutes') ?? 10;

        if (prayerEnabled) {
          final times = List<Map<String, dynamic>>.from(cached['times']);
          for (var prayer in times) {
            final String name = prayer['name'] as String;
            final String timeStr = prayer['time'] as String;
            final timeParts = timeStr.split(':');
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);
            
            // Schedule exact prayer time notification
            var scheduledExact = tz.TZDateTime(location, nowTz.year, nowTz.month, nowTz.day, hour, minute);
            if (scheduledExact.isBefore(nowTz)) scheduledExact = scheduledExact.add(const Duration(days: 1));
            
            final id = (prayer['id'] as int?) ?? 0;
            
            // Get beautiful notification messages for each prayer (with date for Ramadan/Friday awareness)
            final scheduledDateTime = DateTime(scheduledExact.year, scheduledExact.month, scheduledExact.day);
            final notificationData = NotificationService.getPrayerNotificationMessage(name, timeStr, scheduledDate: scheduledDateTime);
            
            // Schedule notification at EXACT prayer time
            await NotificationService().schedulePrayerNotificationAtTz(
              id: id,
              title: notificationData['title']!,
              body: notificationData['body']!,
              scheduledTz: scheduledExact,
            );
            
            // Schedule pre-prayer warning 30 minutes before (only for main prayers, not İmsak/Güneş)
            if (offsetMinutes > 0 && !['İmsak', 'Güneş'].contains(name)) {
              var scheduledWarning = scheduledExact.subtract(Duration(minutes: offsetMinutes));
              
              if (scheduledWarning.isAfter(nowTz)) {
                final warningId = id + 100;
                final warningTitle = '⏰ $name Namazına $offsetMinutes Dakika Kaldı';
                final warningBody = 'Namaz vaktine hazırlanın. $timeStr\'de $name vakti girecek. 🤲';
                
                await NotificationService().schedulePrayerNotificationAtTz(
                  id: warningId,
                  title: warningTitle,
                  body: warningBody,
                  scheduledTz: scheduledWarning,
                  useDefaultSound: true,
                );
              }
            }
          }
          
          // Schedule Friday "Hayırlı Cumalar" notifications
          for (int i = 0; i < 30; i++) {
            final checkDate = DateTime(nowTz.year, nowTz.month, nowTz.day).add(Duration(days: i));
            if (checkDate.weekday == DateTime.friday) {
              final fridayTz = tz.TZDateTime(location, checkDate.year, checkDate.month, checkDate.day, 8, 0);
              if (fridayTz.isAfter(nowTz)) {
                final fridayId = 2000 + (i ~/ 7); // Unique ID for each Friday
                await NotificationService().schedulePrayerNotificationAtTz(
                  id: fridayId,
                  title: '🕌 Hayırlı Cumalar!',
                  body: 'Bugün mübarek Cuma günü. Cuma namazını unutmayın, bol bol salavat getirin! 🤲',
                  scheduledTz: fridayTz,
                );
                break; // Only schedule the next Friday from main.dart
              }
            }
          }
        }

        if (holidayEnabled) {
          final now = DateTime.now();
          final candidates = religiousDaysList.where((d) => d.date.isAfter(now)).take(20).toList();
          for (var i = 0; i < candidates.length; i++) {
            final event = candidates[i];
            final scheduled = tz.TZDateTime(location, event.date.year, event.date.month, event.date.day, 9, 0);
            if (scheduled.isBefore(nowTz)) continue;
            final id = 1000 + i;
            await NotificationService().schedulePrayerNotificationAtTz(
              id: id,
              title: '${event.name} hatırlatması',
              body: '${event.hijriDate} - ${event.name}',
              scheduledTz: scheduled,
            );
          }
        }
      }
    }
  } catch (e) {
    debugPrint('Startup scheduling error: $e');
  }

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
