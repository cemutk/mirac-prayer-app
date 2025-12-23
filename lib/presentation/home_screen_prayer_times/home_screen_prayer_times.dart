import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../../core/app_export.dart';
import '../../services/prayer_times_service.dart';
import '../../data/religious_days_data.dart';
import '../../services/notification_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/banner_ad_widget.dart';
import './widgets/city_selection_bottom_sheet_widget.dart';
import './widgets/daily_prayer_tracker_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/prayer_countdown_card_widget.dart';
import './widgets/prayer_time_card_widget.dart';

/// Home Screen displaying daily prayer times with countdown
/// Implements Contemporary Islamic Minimalism design
class HomeScreenPrayerTimes extends StatefulWidget {
  const HomeScreenPrayerTimes({super.key});

  @override
  State<HomeScreenPrayerTimes> createState() => _HomeScreenPrayerTimesState();
}

class _HomeScreenPrayerTimesState extends State<HomeScreenPrayerTimes> {
  int _currentBottomNavIndex = 0;
  String? _selectedCity;
  String? _selectedDistrict;
  DateTime _lastUpdated = DateTime.now();
  bool _isRefreshing = false;
  Timer? _updateTimer;
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  bool _isPeriodModeEnabled = false; // NEW: Period mode state
  String? _prayerTimezone;
  String? _hijriDate; // Hijri date from API

  // Dynamically fetched prayer times from API
  List<Map<String, dynamic>> _prayerTimes = [];

  // Daily prayer tracking state
  Map<String, bool> _prayerStatus = {
    'sabah': false,
    'ogle': false,
    'ikindi': false,
    'aksam': false,
    'yatsi': false,
  };
  bool _showCongratulations = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCity();
    _loadPrayerStatus();
    _loadPeriodMode();
    _startStatusUpdateTimer();

    // CRITICAL: Listen for settings changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForSettingsUpdates();
      _checkBatteryOptimization();
    });
  }
  
  /// Check and show battery optimization dialog if needed
  Future<void> _checkBatteryOptimization() async {
    final notificationService = NotificationService();
    
    // Check if we should show the dialog
    final shouldShow = await notificationService.shouldShowBatteryDialog();
    if (!shouldShow || !mounted) return;
    
    // Small delay to let the screen load first
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    
    // Check if already ignored
    final isIgnored = await notificationService.isBatteryOptimizationIgnored();
    if (isIgnored) return;
    
    // Show friendly dialog
    _showBatteryOptimizationDialog();
  }
  
  void _showBatteryOptimizationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.notifications_active,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Namaz Vakti Bildirimleri',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Namaz vakitlerinde bildirim alabilmeniz için uygulamanın arka planda çalışmasına izin vermeniz gerekmektedir.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Bu izin olmadan bildirimler gecikmeli gelebilir veya hiç gelmeyebilir.',
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final notificationService = NotificationService();
              await notificationService.markBatteryDialogShown();
            },
            child: Text(
              'Daha Sonra',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final notificationService = NotificationService();
              await notificationService.requestBatteryOptimizationExemption();
              await notificationService.markBatteryDialogShown();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('İzin Ver'),
          ),
        ],
      ),
    );
  }

  // NEW: Load period mode from SharedPreferences
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

  // NEW: Check for settings updates periodically
  void _checkForSettingsUpdates() {
    // Listen for navigation returns that signal settings changed
    // This runs when returning from settings screen
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startStatusUpdateTimer() {
    // Update prayer status every minute
    _updateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _updatePrayerTimesStatus();
        });
      }
    });
  }

  void _updatePrayerTimesStatus() {
    if (_prayerTimes.isEmpty) return;

    final now = DateTime.now();
    for (var i = 0; i < _prayerTimes.length; i++) {
      final timeParts = (_prayerTimes[i]["time"] as String).split(':');
      final prayerTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      _prayerTimes[i]["isPast"] = prayerTime.isBefore(now);
      _prayerTimes[i]["isCurrent"] = false;
    }
  }

  Future<void> _loadSavedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // One-time cache clear for hijri date fix (version 3 with diacritic removal)
      final cacheCleared = prefs.getBool('hijri_cache_cleared_v3') ?? false;
      if (!cacheCleared) {
        await _prayerTimesService.clearCache();
        await prefs.setBool('hijri_cache_cleared_v3', true);
      }
      
      final savedCity = prefs.getString('selectedCity');
      final savedProvince = prefs.getString('selected_province');
      final savedDistrict = prefs.getString('selected_district');

      if (mounted) {
        setState(() {
          // Prioritize selectedCity from settings over selected_province
          _selectedCity = savedCity ?? savedProvince ?? "İstanbul";
          _selectedDistrict = savedDistrict ?? "Kadıköy";
        });

        // CRITICAL: Always fetch prayer times after loading city
        await _fetchPrayerTimes();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _selectedCity = "İstanbul";
          _selectedDistrict = "Kadıköy";
        });
        await _fetchPrayerTimes();
      }
    }
  }

  /// Load prayer completion status from SharedPreferences
  Future<void> _loadPrayerStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final savedDate = prefs.getString('prayer_status_date');

      // Reset if it's a new day
      if (savedDate != today) {
        await _resetPrayerStatus();
        return;
      }

      // Load saved status for today
      if (mounted) {
        setState(() {
          _prayerStatus = {
            'sabah': prefs.getBool('prayer_sabah') ?? false,
            'ogle': prefs.getBool('prayer_ogle') ?? false,
            'ikindi': prefs.getBool('prayer_ikindi') ?? false,
            'aksam': prefs.getBool('prayer_aksam') ?? false,
            'yatsi': prefs.getBool('prayer_yatsi') ?? false,
          };
          _checkAllPrayersCompleted();
        });
      }
    } catch (e) {
      print('Error loading prayer status: $e');
    }
  }

  /// Save prayer completion status to SharedPreferences
  Future<void> _savePrayerStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      await prefs.setString('prayer_status_date', today);
      await prefs.setBool('prayer_sabah', _prayerStatus['sabah']!);
      await prefs.setBool('prayer_ogle', _prayerStatus['ogle']!);
      await prefs.setBool('prayer_ikindi', _prayerStatus['ikindi']!);
      await prefs.setBool('prayer_aksam', _prayerStatus['aksam']!);
      await prefs.setBool('prayer_yatsi', _prayerStatus['yatsi']!);
    } catch (e) {
      print('Error saving prayer status: $e');
    }
  }

  /// Reset all prayer statuses (called on new day)
  Future<void> _resetPrayerStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      await prefs.setString('prayer_status_date', today);
      await prefs.setBool('prayer_sabah', false);
      await prefs.setBool('prayer_ogle', false);
      await prefs.setBool('prayer_ikindi', false);
      await prefs.setBool('prayer_aksam', false);
      await prefs.setBool('prayer_yatsi', false);

      if (mounted) {
        setState(() {
          _prayerStatus = {
            'sabah': false,
            'ogle': false,
            'ikindi': false,
            'aksam': false,
            'yatsi': false,
          };
          _showCongratulations = false;
        });
      }
    } catch (e) {
      print('Error resetting prayer status: $e');
    }
  }

  /// Toggle prayer completion status
  void _togglePrayerStatus(String prayerKey) {
    setState(() {
      _prayerStatus[prayerKey] = !_prayerStatus[prayerKey]!;
      _checkAllPrayersCompleted();
    });
    _savePrayerStatus();
  }

  /// Check if all prayers are completed
  void _checkAllPrayersCompleted() {
    final allCompleted = _prayerStatus.values.every((status) => status == true);

    if (allCompleted && !_showCongratulations) {
      setState(() {
        _showCongratulations = true;
      });
      HapticFeedback.heavyImpact();
    } else if (!allCompleted && _showCongratulations) {
      setState(() {
        _showCongratulations = false;
      });
    }
  }

  /// Fetches real prayer times from Aladhan API using Turkey Diyanet method
  Future<void> _fetchPrayerTimes() async {
    if (_selectedCity == null || _selectedDistrict == null) return;

    try {
      final prayerData = await _prayerTimesService.fetchPrayerTimes(
        city: _selectedCity!,
        district: _selectedDistrict!,
      );

      if (prayerData != null && mounted) {
        setState(() {
          _prayerTimes = List<Map<String, dynamic>>.from(prayerData['times']);
          _prayerTimezone = prayerData['timezone'] ?? 'Europe/Istanbul';
          _hijriDate = prayerData['hijri_date']; // Save Hijri date from API
          _lastUpdated = DateTime.now();
          _updatePrayerTimesStatus();
        });

        // Persist timezone for background scheduling on next app start
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('prayer_timezone', prayerData['timezone'] ?? 'Europe/Istanbul');
        } catch (e) {
          debugPrint('Failed to save prayer timezone: $e');
        }

        // After fetching prayer times, apply notification scheduling if user enabled it
        await _applySchedulingIfEnabled();
      } else {
        // If API fails, show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Namaz vakitleri alınırken bir sorun oluştu, lütfen internet bağlantınızı kontrol edin.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );

          // Try to load cached data
          final cachedData = await _prayerTimesService.getCachedPrayerTimes(
            _selectedCity!,
            _selectedDistrict!,
          );

          if (cachedData != null) {
            setState(() {
              _prayerTimes =
                  List<Map<String, dynamic>>.from(cachedData['times']);
              _hijriDate = cachedData['hijri_date']; // Also load hijri date from cache
              _updatePrayerTimesStatus();
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Önbellekteki namaz vakitleri gösteriliyor'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error loading prayer times: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Namaz vakitleri alınırken bir sorun oluştu, lütfen internet bağlantınızı kontrol edin.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );

        // Try to load cached data as last resort
        final cachedData = await _prayerTimesService.getCachedPrayerTimes(
          _selectedCity!,
          _selectedDistrict!,
        );

        if (cachedData != null) {
          setState(() {
            _prayerTimes = List<Map<String, dynamic>>.from(cachedData['times']);
            _hijriDate = cachedData['hijri_date']; // Also load hijri date from cache
            _updatePrayerTimesStatus();
          });
        }
      }
    }
  }

  /// Schedules notifications for all available prayers if user enabled notifications
  Future<void> _applySchedulingIfEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // New simplified settings keys
      final prayerEnabled = prefs.getBool('enable_prayer_notifications') ?? true;
      final holidayEnabled = prefs.getBool('enable_holiday_notifications') ?? true;
      final offsetMinutes = prefs.getInt('notification_offset_minutes') ?? 10;

      debugPrint('🔔 [Notification] Prayer enabled: $prayerEnabled, Holiday enabled: $holidayEnabled, Offset: $offsetMinutes min');

      // If both are disabled, skip scheduling
      if (!prayerEnabled && !holidayEnabled) {
        debugPrint('🔔 [Notification] Both notification types disabled, skipping scheduling');
        return;
      }

      // Initialize notification plugin and request permissions
      await NotificationService().initialize();
      await NotificationService().requestPermissions();

      // Cancel existing notifications first to avoid duplicates
      await NotificationService().cancelAllNotifications();

      // CRITICAL: Initialize timezone database before using tz.getLocation
      tzdata.initializeTimeZones();

      // Prepare timezone location (use API timezone if available)
      final tzName = _prayerTimezone ?? prefs.getString('prayer_timezone') ?? 'Europe/Istanbul';
      debugPrint('🔔 [Notification] Using timezone: $tzName');
      
      tz.Location location;
      try {
        location = tz.getLocation(tzName);
      } catch (e) {
        debugPrint('🔔 [Notification] Failed to get timezone $tzName, using local: $e');
        location = tz.local;
      }

      final nowTz = tz.TZDateTime.now(location);
      debugPrint('🔔 [Notification] Current time in $tzName: $nowTz');

      if (prayerEnabled && _prayerTimes.isNotEmpty) {
        debugPrint('🔔 [Notification] Scheduling ${_prayerTimes.length} prayer notifications...');
        
        for (var prayer in _prayerTimes) {
          final String name = prayer['name'] as String;
          final timeStr = prayer['time'] as String;
          final timeParts = timeStr.split(':');
          int hour = int.parse(timeParts[0]);
          int minute = int.parse(timeParts[1]);

          // Schedule exact prayer time notification
          tz.TZDateTime scheduledExact = tz.TZDateTime(location, nowTz.year, nowTz.month, nowTz.day, hour, minute);

          // If prayer time already passed today, schedule for tomorrow
          if (scheduledExact.isBefore(nowTz)) {
            scheduledExact = scheduledExact.add(const Duration(days: 1));
            debugPrint('🔔 [Notification] $name already passed today, scheduling for tomorrow');
          }

          final id = (prayer['id'] as int?) ?? 0;
          
          // Get beautiful notification messages for each prayer (with date for Ramadan/Friday awareness)
          final scheduledDateTime = DateTime(scheduledExact.year, scheduledExact.month, scheduledExact.day);
          final notificationData = NotificationService.getPrayerNotificationMessage(name, timeStr, scheduledDate: scheduledDateTime);

          debugPrint('🔔 [Notification] Scheduling $name (ID: $id) at EXACT time $scheduledExact (prayer time: $timeStr)');

          // Schedule notification at EXACT prayer time
          await NotificationService().schedulePrayerNotificationAtTz(
            id: id,
            title: notificationData['title']!,
            body: notificationData['body']!,
            scheduledTz: scheduledExact,
          );
          
          // Schedule pre-prayer warning 30 minutes before (only for main prayers, not İmsak/Güneş)
          if (offsetMinutes > 0 && !['İmsak', 'Güneş'].contains(name)) {
            tz.TZDateTime scheduledWarning = scheduledExact.subtract(Duration(minutes: offsetMinutes));
            
            if (scheduledWarning.isAfter(nowTz)) {
              final warningId = id + 100; // Warning IDs: 101-106
              final warningTitle = '⏰ $name Namazına $offsetMinutes Dakika Kaldı';
              final warningBody = 'Namaz vaktine hazırlanın. $timeStr\'de $name vakti girecek. 🤲';
              
              debugPrint('🔔 [Notification] Scheduling $name warning (ID: $warningId) at $scheduledWarning ($offsetMinutes min before)');
              
              await NotificationService().schedulePrayerNotificationAtTz(
                id: warningId,
                title: warningTitle,
                body: warningBody,
                scheduledTz: scheduledWarning,
                useDefaultSound: true, // Use default sound for warnings, not azan
              );
            }
          }
        }
        debugPrint('🔔 [Notification] ✅ All prayer notifications scheduled successfully');
        
        // Schedule Friday "Hayırlı Cumalar" notifications for upcoming Fridays
        await _scheduleFridayNotifications(location, nowTz);
        
      } else if (prayerEnabled) {
        debugPrint('🔔 [Notification] ⚠️ Prayer notifications enabled but no prayer times available');
      }

      // Schedule religious/holiday notifications (use IDs starting at 1000)
      if (holidayEnabled) {
        final upcoming = religiousDaysList.where((d) => d.date.isAfter(DateTime.now().subtract(const Duration(days:1)))).toList();
        debugPrint('🔔 [Notification] Scheduling ${upcoming.length} holiday notifications...');
        
        int scheduledCount = 0;
        for (var i = 0; i < upcoming.length; i++) {
          final event = upcoming[i];
          // schedule at 09:00 local on the event date
          final localDate = tz.TZDateTime(location, event.date.year, event.date.month, event.date.day, 9, 0);
          if (localDate.isBefore(nowTz)) {
            debugPrint('🔔 [Notification] Skipping past holiday: ${event.name}');
            continue;
          }
          final id = 1000 + i; // unique id for holiday
          debugPrint('🔔 [Notification] Scheduling holiday: ${event.name} (ID: $id) at $localDate');
          await NotificationService().schedulePrayerNotificationAtTz(
            id: id,
            title: '${event.name} hatırlatması',
            body: '${event.hijriDate} - ${event.name}',
            scheduledTz: localDate,
          );
          scheduledCount++;
        }
        debugPrint('🔔 [Notification] ✅ $scheduledCount holiday notifications scheduled');
      }
      
      debugPrint('🔔 [Notification] === Scheduling complete ===' );
    } catch (e, stackTrace) {
      debugPrint('❌ [Notification] Error scheduling notifications: $e');
      debugPrint('❌ [Notification] Stack trace: $stackTrace');
    }
  }
  
  /// Schedule Friday "Hayırlı Cumalar" notifications for the next 4 Fridays
  Future<void> _scheduleFridayNotifications(tz.Location location, tz.TZDateTime nowTz) async {
    debugPrint('🔔 [Notification] Scheduling Friday notifications...');
    
    // Find next 4 Fridays
    DateTime currentDate = DateTime(nowTz.year, nowTz.month, nowTz.day);
    int fridaysScheduled = 0;
    
    for (int i = 0; i < 30 && fridaysScheduled < 4; i++) {
      final checkDate = currentDate.add(Duration(days: i));
      if (checkDate.weekday == DateTime.friday) {
        // Schedule at 08:00 on Friday
        final fridayTz = tz.TZDateTime(location, checkDate.year, checkDate.month, checkDate.day, 8, 0);
        
        if (fridayTz.isAfter(nowTz)) {
          final fridayId = 2000 + fridaysScheduled; // Use IDs starting from 2000 for Friday notifications
          await NotificationService().schedulePrayerNotificationAtTz(
            id: fridayId,
            title: '🕌 Hayırlı Cumalar!',
            body: 'Bugün mübarek Cuma günü. Cuma namazını unutmayın, bol bol salavat getirin! 🤲',
            scheduledTz: fridayTz,
          );
          debugPrint('🔔 [Notification] Friday notification scheduled (ID: $fridayId) for $fridayTz');
          fridaysScheduled++;
        }
      }
    }
    debugPrint('🔔 [Notification] ✅ $fridaysScheduled Friday notifications scheduled');
    
    // Schedule daily engagement notifications (sabah 09:00, akşam 20:00)
    final prefs = await SharedPreferences.getInstance();
    final enableDailyReminders = prefs.getBool('enable_daily_reminders') ?? true;
    if (enableDailyReminders) {
      await NotificationService().scheduleDailyEngagementNotifications();
      debugPrint('🔔 [Notification] ✅ Daily engagement notifications scheduled');
    }
  }

  Future<void> _refreshPrayerTimes() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    HapticFeedback.mediumImpact();

    await _fetchPrayerTimes();

    setState(() {
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Namaz vakitleri güncellendi'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showCitySelectionBottomSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CitySelectionBottomSheetWidget(
        onCitySelected: (city, district) {
          setState(() {
            _selectedCity = city;
            _selectedDistrict = district;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _navigateToCitySelection() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/city-selection-screen').then((_) async {
      // Reload city selection and fetch new prayer times
      await _loadSavedCity();
    });
  }

  /// Shows a bottom sheet to configure prayer notifications
  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          bool enabled = false;
          int offset = 0;

          // Load current values asynchronously
          SharedPreferences.getInstance().then((prefs) {
            enabled = prefs.getBool('enablePrayerNotifications') ?? false;
            offset = prefs.getInt('notification_offset_minutes') ?? 0;
            // Call setState inside the sheet's stateful builder
            setState(() {});
          });

          return SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Namaz Bildirimleri',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 2.h),
                  SwitchListTile(
                    title: const Text('Bildirimleri Etkinleştir'),
                    value: enabled,
                    onChanged: (v) => setState(() => enabled = v),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Expanded(child: Text('Bildirim öncesi (dakika)')),
                      DropdownButton<int>(
                        value: offset,
                        items: const [0, 5, 10, 15, 30]
                            .map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Text('$m'),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => offset = v ?? 0),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('İptal'),
                      ),
                      SizedBox(width: 2.w),
                      ElevatedButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('enablePrayerNotifications', enabled);
                          await prefs.setInt('notification_offset_minutes', offset);

                          // Apply immediately
                          await _applySchedulingIfEnabled();

                          Navigator.pop(context);
                        },
                        child: const Text('Kaydet'),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showPrayerContextMenu(Map<String, dynamic> prayer) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildContextMenu(prayer),
    );
  }

  Widget _buildContextMenu(Map<String, dynamic> prayer) {
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
            Container(
              width: 40.w,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'notifications',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Bildirim Ayarla'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                _showNotificationSettings();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'explore',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Kıble Yönünü Göster'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/qibla-direction-screen');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'calendar_today',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Takvime Ekle'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  String _getHijriDate() {
    // Use Hijri date from API if available
    if (_hijriDate != null && _hijriDate!.isNotEmpty) {
      return _hijriDate!;
    }
    // Fallback - should not normally reach here
    return "Hicri tarih yükleniyor...";
  }

  String _getGregorianDate() {
    return DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(DateTime.now());
  }

  Map<String, dynamic>? _getNextPrayer() {
    if (_prayerTimes.isEmpty) {
      _updatePrayerTimesStatus();
      if (_prayerTimes.isEmpty) return null;
    }

    final now = DateTime.now();

    // Find the first prayer that hasn't passed yet
    for (var i = 0; i < _prayerTimes.length; i++) {
      final prayer = _prayerTimes[i];
      final timeParts = (prayer["time"] as String).split(':');
      final prayerTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      if (prayerTime.isAfter(now)) {
        // Mark this prayer as current
        _prayerTimes[i]["isCurrent"] = true;
        return _prayerTimes[i];
      }
    }

    // If all prayers have passed, return İmsak as the next prayer (tomorrow)
    // Mark İmsak as current for tomorrow
    if (_prayerTimes.isNotEmpty) {
      _prayerTimes[0]["isCurrent"] = true;
      return _prayerTimes[0];
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: _selectedCity != null ? _selectedCity! : 'Mirac Prayer',
        subtitle: _selectedDistrict,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'calendar_today',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/religious-days-screen');
            },
            tooltip: 'Dini Günler',
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'location_on',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            onPressed: _navigateToCitySelection,
            tooltip: 'Şehir Seç',
          ),
        ],
      ),
      body: _selectedCity == null
          ? EmptyStateWidget(onSelectCity: _navigateToCitySelection)
          : RefreshIndicator(
              onRefresh: _refreshPrayerTimes,
              color: theme.colorScheme.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Date Header
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getHijriDate(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            _getGregorianDate(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // NEW: Conditional rendering based on period mode
                  if (_isPeriodModeEnabled)
                    // Period mode message
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 2.h),
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.pink.shade50,
                              Colors.pink.shade100,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.pink.shade200,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: Colors.pink.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '🌸',
                                style: TextStyle(fontSize: 28),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Özel Gündesiniz',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink.shade900,
                                    ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    'Zikir ve dua ile vakit geçirebilirsiniz',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.pink.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    // Normal mode: Show countdown and prayer tracker
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: PrayerCountdownCardWidget(
                          nextPrayer: _getNextPrayer(),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h).toSliver(),
                    SliverToBoxAdapter(
                      child: DailyPrayerTrackerWidget(
                        prayerStatus: _prayerStatus,
                        onPrayerToggle: _togglePrayerStatus,
                        showCongratulations: _showCongratulations,
                      ),
                    ),
                  ],

                  SizedBox(height: 2.h).toSliver(),

                  // Prayer Times List
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final prayer = _prayerTimes[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: PrayerTimeCardWidget(
                              prayer: prayer,
                              onLongPress: () => _showPrayerContextMenu(prayer),
                            ),
                          );
                        },
                        childCount: _prayerTimes.length,
                      ),
                    ),
                  ),

                  // Last Updated Info
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      child: Text(
                        'Son güncelleme: ${DateFormat('HH:mm').format(_lastUpdated)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  // Banner Reklam
                  const SliverToBoxAdapter(
                    child: BannerAdWidget(),
                  ),

                  SizedBox(height: 10.h).toSliver(),
                ],
              ),
            ),
      floatingActionButton: _selectedCity != null
          ? FloatingActionButton(
              onPressed: _showCitySelectionBottomSheet,
              tooltip: 'Hızlı Şehir Seçimi',
              child: CustomIconWidget(
                iconName: 'location_city',
                color: theme.colorScheme.onPrimary,
                size: 24,
              ),
            )
          : null,
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) async {
          setState(() => _currentBottomNavIndex = index);

          // CRITICAL: Refresh when coming back from settings (index 6)
          if (index == 0 && _currentBottomNavIndex == 6) {
            // Coming back from settings to home
            await _loadSavedCity(); // This will trigger _fetchPrayerTimes
            await _loadPeriodMode(); // Reload period mode
          }
        },
      ),
    );
  }
}

extension SizedBoxSliver on SizedBox {
  Widget toSliver() {
    return SliverToBoxAdapter(child: this);
  }
}
