import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../services/notification_service.dart';
import '../../services/prayer_times_service.dart';
import '../../services/premium_service.dart';
import '../../data/religious_days_data.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../../core/theme_manager.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/premium_dialog.dart';
import '../../widgets/banner_ad_widget.dart';
import './widgets/notification_settings_widget.dart';
import './widgets/theme_settings_widget.dart';
import './widgets/location_settings_widget.dart';
import './widgets/prayer_calculation_widget.dart';
import './widgets/period_mode_settings_widget.dart';

const List<String> _qiblaGuidanceInstructions = [
  'Telefonu düz tutun ve pusula simgesinin Kâbe yönüne dönmesini bekleyin.',
  'Kalibrasyon için cihazınızı 8 şekli çizecek şekilde hareket ettirin.',
  'AR modunu açmadan önce en az %90 doğruluk gösterene kadar sabit kalın.',
  'Konum izinlerini etkinleştirin ve gerekirse yeniden yükle düğmesini kullanın.',
];

const List<Map<String, String>> _settingsDailyDuas = [
  {
    'title': 'Subhaneke',
    'text':
        'Subhâneke allâhumme ve bihamdike ve tebarekesmuke ve teâlâ ceddüke ve lâ ilâhe ğayruke.',
  },
  {
    'title': 'İstiğfar',
    'text':
        'Estaghfirullâh el-azîm ellezi lâ ilahe illâ hüve el-hayyül-kayyûm ve etûbü ileyh.',
  },
  {
    'title': 'Rabbena Atina',
    'text':
        'Rabbena âtina fiddünya haseneten ve filâhî haseneten ve qina azâbennâr.',
  },
  {
    'title': 'Eûzü',
    'text': 'Eûzü billâhi mineş-şeytânirracîm.',
  },
];

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentIndex = 6;
  bool _masterNotification = true;
  bool _isPeriodModeEnabled = false;
  String _selectedCity = 'İstanbul';
  String _calculationMethod = 'Diyanet';
  final ThemeManager _themeManager = ThemeManager();
  final PremiumService _premiumService = PremiumService();

  // New simplified notification settings
  bool _enablePrayerNotifications = true;
  bool _enableHolidayNotifications = true;
  bool _enableAzanSound = true;
  bool _enableDailyReminders = true; // Günlük hatırlatma bildirimleri
  int _notificationOffsetMinutes = 10; // default

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final azanEnabled = await NotificationService().isAzanSoundEnabled();
      setState(() {
        _masterNotification = prefs.getBool('masterNotification') ?? true;
        _isPeriodModeEnabled = prefs.getBool('isPeriodModeEnabled') ?? false;
        final savedProvince = prefs.getString('selected_province');
        _selectedCity = savedProvince ?? prefs.getString('selectedCity') ?? 'İstanbul';
        _calculationMethod = prefs.getString('calculationMethod') ?? 'Diyanet';

        _enablePrayerNotifications = prefs.getBool('enable_prayer_notifications') ?? true;
        _enableHolidayNotifications = prefs.getBool('enable_holiday_notifications') ?? true;
        _enableAzanSound = azanEnabled;
        _enableDailyReminders = prefs.getBool('enable_daily_reminders') ?? true;
        _notificationOffsetMinutes = prefs.getInt('notification_offset_minutes') ?? 10;
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('masterNotification', _masterNotification);
      await prefs.setBool('isPeriodModeEnabled', _isPeriodModeEnabled);
      await prefs.setString('selectedCity', _selectedCity);
      await prefs.setString('calculationMethod', _calculationMethod);
      // Save simplified notification settings
      await prefs.setBool('enable_prayer_notifications', _enablePrayerNotifications);
      await prefs.setBool('enable_holiday_notifications', _enableHolidayNotifications);
      await NotificationService().setAzanSoundEnabled(_enableAzanSound);
      await prefs.setBool('enable_daily_reminders', _enableDailyReminders);
      await prefs.setInt('notification_offset_minutes', _notificationOffsetMinutes);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  /// Manually reschedule all notifications from cached prayer times
  Future<void> _rescheduleAllNotifications() async {
    debugPrint('🔔 [Settings] Starting manual reschedule of all notifications...');
    
    final prefs = await SharedPreferences.getInstance();
    final city = prefs.getString('selectedCity') ?? prefs.getString('selected_province') ?? 'İstanbul';
    final district = prefs.getString('selected_district') ?? prefs.getString('selectedDistrict') ?? 'Kadıköy';

    // Initialize timezone data
    tzdata.initializeTimeZones();

    // Initialize notifications
    await NotificationService().initialize();
    await NotificationService().requestPermissions();
    await NotificationService().cancelAllNotifications();

    // Get timezone
    final tzName = prefs.getString('prayer_timezone') ?? 'Europe/Istanbul';
    tz.Location location;
    try {
      location = tz.getLocation(tzName);
    } catch (e) {
      debugPrint('🔔 [Settings] Failed to get timezone $tzName: $e');
      location = tz.local;
    }
    final nowTz = tz.TZDateTime.now(location);
    debugPrint('🔔 [Settings] Now in $tzName: $nowTz');

    final offsetMinutes = _notificationOffsetMinutes;

    // Schedule prayer notifications
    if (_enablePrayerNotifications) {
      final pts = PrayerTimesService();
      final cached = await pts.getCachedPrayerTimes(city, district);
      
      if (cached != null) {
        final times = List<Map<String, dynamic>>.from(cached['times']);
        debugPrint('🔔 [Settings] Scheduling ${times.length} prayer notifications...');
        
        for (var prayer in times) {
          final String name = prayer['name'] as String;
          final timeStr = prayer['time'] as String;
          final timeParts = timeStr.split(':');
          int hour = int.parse(timeParts[0]);
          int minute = int.parse(timeParts[1]);

          // Schedule exact prayer time notification
          tz.TZDateTime scheduledExact = tz.TZDateTime(location, nowTz.year, nowTz.month, nowTz.day, hour, minute);

          if (scheduledExact.isBefore(nowTz)) {
            scheduledExact = scheduledExact.add(const Duration(days: 1));
          }

          final id = (prayer['id'] as int?) ?? 0;
          
          // Get beautiful notification messages for each prayer (with date for Ramadan/Friday awareness)
          final scheduledDateTime = DateTime(scheduledExact.year, scheduledExact.month, scheduledExact.day);
          final notificationData = NotificationService.getPrayerNotificationMessage(name, timeStr, scheduledDate: scheduledDateTime);
          
          debugPrint('🔔 [Settings] Scheduling $name (ID: $id) at EXACT time $scheduledExact');

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
              
              debugPrint('🔔 [Settings] Scheduling $name warning (ID: $warningId) at $scheduledWarning ($offsetMinutes min before)');
              
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
        debugPrint('🔔 [Settings] ✅ Prayer notifications scheduled');
        
        // Schedule Friday notifications
        await _scheduleFridayNotificationsFromSettings(location, nowTz);
        
      } else {
        debugPrint('🔔 [Settings] ⚠️ No cached prayer times found for $city/$district');
      }
    }

    // Schedule holiday notifications
    if (_enableHolidayNotifications) {
      final upcoming = religiousDaysList.where((d) => d.date.isAfter(DateTime.now().subtract(const Duration(days: 1)))).toList();
      debugPrint('🔔 [Settings] Scheduling ${upcoming.length} holiday notifications...');
      
      int scheduledCount = 0;
      for (var i = 0; i < upcoming.length; i++) {
        final event = upcoming[i];
        final localDate = tz.TZDateTime(location, event.date.year, event.date.month, event.date.day, 9, 0);
        if (localDate.isBefore(nowTz)) continue;
        
        final id = 1000 + i;
        debugPrint('🔔 [Settings] Scheduling ${event.name} (ID: $id) at $localDate');
        
        await NotificationService().schedulePrayerNotificationAtTz(
          id: id,
          title: '${event.name} hatırlatması',
          body: '${event.hijriDate} - ${event.name}',
          scheduledTz: localDate,
          useDefaultSound: true,
        );
        scheduledCount++;
      }
      debugPrint('🔔 [Settings] ✅ $scheduledCount holiday notifications scheduled');
    }

    // Schedule daily engagement notifications
    if (_enableDailyReminders) {
      await NotificationService().scheduleDailyEngagementNotifications();
      debugPrint('🔔 [Settings] ✅ Daily engagement notifications scheduled');
    }

    debugPrint('🔔 [Settings] === Manual reschedule complete ===');
  }
  
  /// Schedule Friday "Hayırlı Cumalar" notifications for the next 4 Fridays
  Future<void> _scheduleFridayNotificationsFromSettings(tz.Location location, tz.TZDateTime nowTz) async {
    debugPrint('🔔 [Settings] Scheduling Friday notifications...');
    
    DateTime currentDate = DateTime(nowTz.year, nowTz.month, nowTz.day);
    int fridaysScheduled = 0;
    
    for (int i = 0; i < 30 && fridaysScheduled < 4; i++) {
      final checkDate = currentDate.add(Duration(days: i));
      if (checkDate.weekday == DateTime.friday) {
        final fridayTz = tz.TZDateTime(location, checkDate.year, checkDate.month, checkDate.day, 8, 0);
        
        if (fridayTz.isAfter(nowTz)) {
          final fridayId = 2000 + fridaysScheduled;
          await NotificationService().schedulePrayerNotificationAtTz(
            id: fridayId,
            title: '🕌 Hayırlı Cumalar!',
            body: 'Bugün mübarek Cuma günü. Cuma namazını unutmayın, bol bol salavat getirin! 🤲',
            scheduledTz: fridayTz,
          );
          debugPrint('🔔 [Settings] Friday notification scheduled (ID: $fridayId) for $fridayTz');
          fridaysScheduled++;
        }
      }
    }
    debugPrint('🔔 [Settings] ✅ $fridaysScheduled Friday notifications scheduled');
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: NotificationSettingsWidget(
          enablePrayerNotifications: _enablePrayerNotifications,
          enableHolidayNotifications: _enableHolidayNotifications,
          enableAzanSound: _enableAzanSound,
          offsetMinutes: _notificationOffsetMinutes,
          onPrayerToggle: (v) async {
            setState(() => _enablePrayerNotifications = v);
            await _saveSettings();
            HapticFeedback.lightImpact();
          },
          onHolidayToggle: (v) async {
            setState(() => _enableHolidayNotifications = v);
            await _saveSettings();
            HapticFeedback.lightImpact();
          },
          onAzanSoundToggle: (v) async {
            setState(() => _enableAzanSound = v);
            await _saveSettings();
            HapticFeedback.lightImpact();
            Fluttertoast.showToast(
              msg: v ? 'Ezan sesi aktif' : 'Varsayılan bildirim sesi aktif',
            );
          },
          onOffsetChange: (m) async {
            setState(() => _notificationOffsetMinutes = m);
            await _saveSettings();
          },
        ),
      ),
    );
  }

  /// Shows a dialog listing all pending (scheduled) notifications
  Future<void> _showPendingNotificationsDialog(BuildContext ctx) async {
    final pending = await NotificationService().getPendingNotifications();
    
    if (!mounted) return;
    
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.schedule, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Planlanmış Bildirimler (${pending.length})',
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 50.h,
          child: pending.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_off, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Planlanmış bildirim yok', style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 8),
                      Text(
                        'Ana ekrana gidip namaz vakitlerini yükleyin\nveya "Yeniden Planla" butonuna basın.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: pending.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final n = pending[index];
                    // Determine icon based on ID
                    IconData icon = Icons.notifications;
                    Color iconColor = Colors.blue;
                    String category = 'Bildirim';
                    
                    if (n.id >= 1000) {
                      icon = Icons.celebration;
                      iconColor = Colors.orange;
                      category = 'Dini Gün';
                    } else if (n.id < 10) {
                      icon = Icons.mosque;
                      iconColor = Colors.green;
                      category = 'Namaz Vakti';
                    }
                    
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: iconColor.withValues(alpha: 0.2),
                        child: Icon(icon, color: iconColor, size: 20),
                      ),
                      title: Text(
                        n.title ?? 'Başlık yok',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.body ?? '', style: const TextStyle(fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            'ID: ${n.id} • $category',
                            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showPeriodModeSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: PeriodModeSettingsWidget(
          isPeriodModeEnabled: _isPeriodModeEnabled,
          onToggle: (value) {
            setState(() => _isPeriodModeEnabled = value);
            _saveSettings();
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showLocationSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: LocationSettingsWidget(
          selectedCity: _selectedCity,
          onCityChange: (city) async {
            setState(() => _selectedCity = city);
            await _saveSettings();
            // CRITICAL: Notify home screen to refresh
            if (mounted) {
              Navigator.pop(
                  context, true); // Return true to indicate settings changed
            }
          },
          onChangeLocation: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/city-selection-screen')
                .then((_) async {
              await _loadSettings(); // Reload settings after city selection
            });
          },
        ),
      ),
    );
  }

  void _showCalculationSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: PrayerCalculationWidget(
          calculationMethod: _calculationMethod,
          onMethodChange: (method) async {
            setState(() => _calculationMethod = method);
            await _saveSettings();
            // CRITICAL: Notify home screen to refresh
            if (mounted) {
              Navigator.pop(
                  context, true); // Return true to indicate settings changed
            }
          },
        ),
      ),
    );
  }

  void _showQiblaGuidanceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final todayIndex = DateTime.now().day % _settingsDailyDuas.length;
        final dua = _settingsDailyDuas[todayIndex];
        return Container(
          height: 80.h,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.5.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomIconWidget(
                          iconName: 'navigation',
                          color: theme.colorScheme.primary,
                          size: 26,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Kıble Rehberi',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  ..._qiblaGuidanceInstructions.map(
                    (text) => Padding(
                      padding: EdgeInsets.only(bottom: 0.8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              text,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.2.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: theme.colorScheme.onPrimary,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dua['title']!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                dua['text']!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.refresh,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: EdgeInsets.symmetric(vertical: 1.8.h),
                          ),
                          icon: const Icon(Icons.water_drop),
                          label: const Text('Abdest Rehberi'),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, AppRoutes.abdestGuideScreen);
                          },
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: theme.colorScheme.onSecondary,
                            padding: EdgeInsets.symmetric(vertical: 1.8.h),
                          ),
                          icon: const Icon(Icons.self_improvement),
                          label: const Text('Namaz Mekaniği'),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, AppRoutes.namazMechanicsScreen);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showHajjUmrahGuideSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          height: 85.h,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.mosque,
                        color: theme.colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hac ve Umre Rehberi',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Adım adım ibadet rehberi',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: DefaultTabController(
                  length: 5,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: theme.colorScheme.primary,
                        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        indicatorColor: theme.colorScheme.primary,
                        isScrollable: true,
                        tabs: const [
                          Tab(text: 'UMRE', icon: Icon(Icons.star_outline, size: 18)),
                          Tab(text: 'HAC', icon: Icon(Icons.stars, size: 18)),
                          Tab(text: 'DUALAR', icon: Icon(Icons.menu_book, size: 18)),
                          Tab(text: 'YASAKLAR', icon: Icon(Icons.block, size: 18)),
                          Tab(text: 'BİLGİLER', icon: Icon(Icons.info_outline, size: 18)),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildUmrahGuide(theme),
                            _buildHajjGuide(theme),
                            _buildDualarGuide(theme),
                            _buildIhramGuide(theme),
                            _buildPracticalGuide(theme),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUmrahGuide(ThemeData theme) {
    final umrahSteps = [
      {
        'title': '1. İhrama Girmek',
        'icon': Icons.checkroom,
        'description': 'Mikat noktasında ihrama girilir.',
        'details': [
          '📍 MİKAT NOKTALARI:',
          '• Zülhuleyfe (Medine yönünden gelenler için)',
          '• Cuhfe (Şam, Mısır, Mağrip yönünden)',
          '• Karnül Menazil (Necid, Kuveyt yönünden)',
          '• Yelemlem (Yemen yönünden)',
          '• Zatü Irk (Irak yönünden)',
          '',
          '🚿 HAZIRLIK:',
          'Gusül abdesti alın veya en az abdest alın',
          'Tırnaklarınızı kesin, koltuk altı ve kasık temizliği yapın',
          'Koku sürünebilirsiniz (ihram öncesi son kez)',
          '',
          '👔 ERKEKLER İÇİN:',
          'İki parça dikişsiz beyaz örtü giyin (izar ve rida)',
          'Ayakkabı: Topuk ve parmak uçları açık terlik',
          'Baş açık kalmalı, şapka/takke yasak',
          '',
          '👗 KADINLAR İÇİN:',
          'Normal tesettür kıyafeti giyebilir',
          'Yüz açık kalmalı (peçe yasak)',
          'Eller açık kalmalı (eldiven yasak)',
          'Dikişli elbise giyebilirler',
          '',
          '🕌 İHRAM NAMAZI:',
          '2 rekat namaz kılın (1. rekatta Kâfirun, 2. rekatta İhlas)',
          '',
          '🤲 NİYET:',
          '"Allahümme innî urîdül umrete feyessirhâ lî ve tekabbelhâ minnî"',
          '(Allah\'ım! Umre yapmak istiyorum, onu bana kolaylaştır ve kabul et)',
          '',
          '📢 TELBİYE:',
          '"Lebbeyk Allahümme lebbeyk, lebbeyke lâ şerîke leke lebbeyk,',
          'innel hamde ven ni\'mete leke vel mülk, lâ şerîke lek"',
          '(Buyur Allah\'ım buyur! Emrine amadeyim. Senin ortağın yoktur.',
          'Hamd Sana mahsustur. Nimet Senindir. Mülk de Senindir. Ortağın yoktur)',
        ],
      },
      {
        'title': '2. Mekke\'ye Varış',
        'icon': Icons.location_city,
        'description': 'Mekke\'ye ulaşınca yapılacaklar.',
        'details': [
          '🕌 MESCİD-İ HARAM\'A GİRİŞ:',
          'Sağ ayakla girin',
          '',
          '🤲 GİRİŞ DUASI:',
          '"Bismillahi vessalâtü vesselâmü alâ Rasûlillah.',
          'Allahümmeftah lî ebvâbe rahmetik"',
          '(Allah\'ın adıyla, salât ve selam Rasûlullah\'a olsun.',
          'Allah\'ım! Bana rahmet kapılarını aç)',
          '',
          '👀 KÂBE\'Yİ GÖRÜNCE:',
          '3 kez "Allahu Ekber" deyin',
          '3 kez "Lâ ilâhe illallah" deyin',
          'Ellerinizi kaldırarak dua edin (bu an dualar kabul olur)',
          '',
          '🤲 KÂBE\'Yİ GÖRÜNCE OKUNACAK DUA:',
          '"Allahümme zid hâzel beyte teşrîfen ve ta\'zîmen',
          've tekrîmen ve mehâbeten ve zid men şerrefehu',
          've kerremehü mimmen haccehü evi\'temerahu',
          'teşrîfen ve tekrîmen ve ta\'zîmen ve birra"',
        ],
      },
      {
        'title': '3. Tavaf (7 Şavt)',
        'icon': Icons.refresh,
        'description': 'Kâbe etrafında 7 tur dönülür.',
        'details': [
          '⚫ HACER-ÜL ESVED:',
          'Mümkünse öpün veya dokunun',
          'Kalabalıksa uzaktan selamlayın (istilam):',
          'Sağ elinizi kaldırıp "Bismillahi Allahu Ekber" deyin',
          '',
          '🔄 TAVAF KURALLARI:',
          'Kâbe solunuzda kalacak şekilde dönün',
          'Abdestli olun (bozulursa yenileyin)',
          'Hatîm\'in dışından dönün',
          '',
          '🏃 REMEL (İlk 3 tur):',
          'Erkekler hızlı ve kısa adımlarla yürür',
          'Omuzları sallayarak heybetli görünür',
          'Son 4 turda normal yürünür',
          '',
          '🟫 RÜKN-İ YEMANİ:',
          'Mümkünse sağ elle mesh edin',
          'Öpmek sünnet değildir',
          '',
          '🤲 YEMANİ - HACER ARASI DUA:',
          '"Rabbenâ âtinâ fiddünyâ haseneten',
          've fil âhireti haseneten ve kınâ azâbennâr"',
          '',
          '📿 HER ŞAVTTA OKUNABİLECEK:',
          'Kur\'an, tesbih, istiğfar, salavat',
          'Türkçe dua da yapılabilir',
          '',
          '🕌 TAVAF NAMAZI (2 Rekat):',
          'Makam-ı İbrahim arkasında kılın',
          'Kalabalıksa Harem\'in herhangi bir yerinde olur',
          '1. rekatta Kâfirun, 2. rekatta İhlas okunur',
        ],
      },
      {
        'title': '4. Sa\'y (7 Şavt)',
        'icon': Icons.directions_walk,
        'description': 'Safa ile Merve arasında 7 tur.',
        'details': [
          '💧 ZEMZEM:',
          'Tavaf namazından sonra zemzem için',
          'Kâbe\'ye dönerek, ayakta, 3 yudumda için',
          '"Bismillah" ile başlayın, "Elhamdülillah" ile bitirin',
          '',
          '⛰️ SAFA\'DA BAŞLANGIÇ:',
          'Kâbe\'ye dönün, eller kaldırın',
          '3 kez tekbir, tehlil, tahmid getirin',
          '"İnnessafâ vel mervete min şeâirillah" ayetini okuyun',
          '',
          '🤲 SAFA\'DA DUA:',
          '"Lâ ilâhe illallâhu vahdehû lâ şerîke leh,',
          'lehül mülkü ve lehül hamdü ve hüve alâ külli şey\'in kadîr.',
          'Lâ ilâhe illallâhu vahdeh, enceze va\'dehû',
          've nasara abdehû ve hezemel ahzâbe vahdeh"',
          '',
          '🚶 SA\'Y KURALLARI:',
          'Safa\'dan Merve\'ye yürüyün',
          'Yeşil ışıklar arasında erkekler koşar (hervele)',
          'Kadınlar normal yürür',
          '',
          '⛰️ MERVE\'DE:',
          'Aynı şekilde Kâbe\'ye dönüp dua edin',
          '',
          '📊 ŞAVT SAYIMI:',
          'Safa → Merve = 1 şavt',
          'Merve → Safa = 2 şavt',
          '7. şavt Merve\'de biter',
          '',
          '✨ SA\'Y SIRASINDA:',
          'Dua, zikir, Kur\'an okunabilir',
          'Abdest şart değil ama abdestli olmak efdaldir',
        ],
      },
      {
        'title': '5. Tıraş / Saç Kesimi',
        'icon': Icons.content_cut,
        'description': 'İhramdan çıkış için saç kesilir.',
        'details': [
          '✂️ ERKEKLER İÇİN:',
          'HALK: Saçları tamamen tıraş (daha faziletli)',
          'KASIR: Saçları kısaltma (en az 2 cm)',
          '',
          '✂️ KADINLAR İÇİN:',
          'Saç uçlarından parmak ucu kadar (1-2 cm) kesilir',
          'Kadınlar için tıraş caiz değildir',
          '',
          '🤲 TIRAŞ DUASI:',
          '"Elhamdülillâhillezî kadâ annâ nüsükena.',
          'Allahümmeğfir lî ve lil muhallıkîn vel mukassırîn"',
          '',
          '🎉 İHRAMDAN ÇIKIŞ:',
          'Tıraş/kesim sonrası ihram biter',
          'Normal kıyafetlerinizi giyebilirsiniz',
          'Tüm ihram yasakları kalkar',
          '',
          '✅ UMRE TAMAMLANDI!',
          'Allah kabul etsin. Mebrûr bir umre olsun!',
        ],
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: umrahSteps.length,
      itemBuilder: (context, index) {
        final step = umrahSteps[index];
        return _buildGuideCard(
          theme: theme,
          title: step['title'] as String,
          icon: step['icon'] as IconData,
          description: step['description'] as String,
          details: step['details'] as List<String>,
          isLast: index == umrahSteps.length - 1,
        );
      },
    );
  }

  Widget _buildHajjGuide(ThemeData theme) {
    final hajjSteps = [
      {
        'title': '⭐ Hac Türleri',
        'icon': Icons.category,
        'description': 'Üç çeşit hac vardır.',
        'details': [
          '1️⃣ İFRAD HACCI:',
          'Sadece hac için ihrama girilir',
          'Umre yapılmaz, kurban gerekmez',
          'Niyet: "Allahümme lebbeyk haccen"',
          '',
          '2️⃣ TEMETTU HACCI (En yaygın):',
          'Önce umre yapılır, ihramdan çıkılır',
          'Hac günlerinde tekrar ihrama girilir',
          'Şükür kurbanı kesilmesi gerekir',
          'Niyet: Önce umre, sonra hac',
          '',
          '3️⃣ KIRAN HACCI:',
          'Hac ve umre birlikte niyet edilir',
          'Aynı ihramla her ikisi yapılır',
          'İhramdan umre sonrası çıkılmaz',
          'Şükür kurbanı kesilmesi gerekir',
          'Niyet: "Allahümme lebbeyk umreten ve haccen"',
        ],
      },
      {
        'title': '1. İhrama Girmek (8 Zilhicce)',
        'icon': Icons.checkroom,
        'description': 'Terviye günü - Hac için ihram.',
        'details': [
          '📅 TERVİYE GÜNÜ:',
          'Zilhicce\'nin 8. günü',
          'Mekke\'de (kaldığınız yerde) ihrama girin',
          '',
          '🚿 HAZIRLIK:',
          'Gusül veya abdest alın',
          'İhram kıyafetinizi giyin',
          '2 rekat ihram namazı kılın',
          '',
          '🤲 NİYET:',
          '"Allahümme innî urîdül hacce feyessirhu lî ve tekabbelhu minnî"',
          '(Allah\'ım! Hac yapmak istiyorum, kolaylaştır ve kabul et)',
          '',
          '📢 TELBİYE:',
          '"Lebbeyk Allahümme lebbeyk..."',
          'Telbiyeyi sık sık tekrarlayın',
          '',
          '🚌 MİNA\'YA HAREKET:',
          'Kuşluk vaktinden sonra Mina\'ya gidin',
        ],
      },
      {
        'title': '2. Mina\'da Geceleme (8 Zilhicce)',
        'icon': Icons.nights_stay,
        'description': 'Mina\'da geceyi geçirin.',
        'details': [
          '🕌 NAMAZLAR:',
          'Öğle, ikindi, akşam, yatsı namazlarını kılın',
          'Her namaz kendi vaktinde, kısaltarak (kasr)',
          'Sabah namazını da Mina\'da kılın',
          '',
          '🌙 GECE:',
          'Geceyi Mina\'da geçirin (sünnet)',
          'Çadırlarda kalınır',
          '',
          '📿 İBADET:',
          'Dua ve zikirle meşgul olun',
          'Telbiye getirin',
          'Kur\'an okuyun',
          '',
          '🌅 SABAH:',
          'Sabah namazından sonra Arafat\'a hareket',
          'Güneş doğduktan sonra yola çıkın',
        ],
      },
      {
        'title': '3. Arafat Vakfesi (9 Zilhicce)',
        'icon': Icons.wb_sunny,
        'description': '⚠️ HACCIN EN ÖNEMLİ RÜKNÜ (FARZ)',
        'details': [
          '⏰ VAKFE VAKTİ:',
          '9 Zilhicce öğle vaktinden',
          '10 Zilhicce fecr-i sadığa kadar',
          'Bu sürede bir an bile olsa Arafat\'ta bulunmak FARZ',
          '',
          '🕌 ÖĞLE & İKİNDİ:',
          'Nemire Mescidi\'nde cem-i takdim ile kılınır',
          'Öğle ve ikindi birlikte, kısaltılarak',
          'Aralarında sünnet kılınmaz',
          '',
          '⛰️ ARAFAT\'TA YAPILACAKLAR:',
          'Kıbleye dönerek vakfe yapın',
          'Bol bol dua edin (elleri kaldırarak)',
          'Tövbe ve istiğfar edin',
          'Telbiye getirin',
          '',
          '🤲 ARAFAT DUASI:',
          '"Lâ ilâhe illallâhu vahdehû lâ şerîke leh,',
          'lehül mülkü ve lehül hamdü, yuhyî ve yümît,',
          've hüve alâ külli şey\'in kadîr"',
          '',
          '❌ DİKKAT:',
          'Cebel-i Rahme\'de (Rahmet Dağı) durmak şart DEĞİL',
          'Arafat\'ın her yeri vakfe için geçerlidir',
          'Urene vadisi Arafat\'tan sayılmaz!',
          '',
          '🌅 GÜNEŞ BATINCA:',
          'Sakin ve vakarlı şekilde Müzdelife\'ye hareket',
          'Akşam namazını yolda kılmayın, Müzdelife\'de kılın',
        ],
      },
      {
        'title': '4. Müzdelife Vakfesi (9-10 Zilhicce)',
        'icon': Icons.dark_mode,
        'description': 'Geceyi Müzdelife\'de geçirin.',
        'details': [
          '🕌 AKŞAM & YATSI:',
          'Müzdelife\'ye varınca cem-i tehir ile kılın',
          'Akşam ve yatsı birlikte',
          'Aralarında sünnet kılınmaz',
          '',
          '🌙 GECE:',
          'Geceyi Müzdelife\'de geçirin (vacip)',
          'Açık alanda, gökyüzü altında',
          '',
          '🪨 TAŞ TOPLAMA:',
          '70 adet taş toplayın (nohut büyüklüğünde)',
          '• 10 Zilhicce: 7 taş (büyük şeytan)',
          '• 11 Zilhicce: 21 taş (3 şeytan x 7)',
          '• 12 Zilhicce: 21 taş (3 şeytan x 7)',
          '• 13 Zilhicce: 21 taş (acele etmeyenler için)',
          '',
          '🕌 SABAH NAMAZI:',
          'Erkenden kılın (alacakaranlıkta)',
          'Meş\'ar-i Haram\'da vakfe yapın',
          '',
          '🤲 MÜZDELİFE DUASI:',
          '"Allahümme innî es\'elüke en terzukanî min fadlike',
          've en tüferrice annî mâ enâ fîhi min zimmeti..."',
          '',
          '🌅 TAN YERİ AĞARINCA:',
          'Mina\'ya hareket edin',
          'Güneş doğmadan Mina\'ya ulaşmaya çalışın',
        ],
      },
      {
        'title': '5. Büyük Şeytan Taşlama (10 Zilhicce)',
        'icon': Icons.gps_fixed,
        'description': 'Bayramın 1. günü - Akabe Cemresi',
        'details': [
          '⏰ TAŞLAMA VAKTİ:',
          'Fecirden sonra güneş batana kadar',
          'Sünnet vakit: Güneş doğduktan sonra',
          '',
          '🎯 AKABE CEMRESİ (BÜYÜK ŞEYTAN):',
          'Sadece büyük şeytana taş atılır',
          '7 taş atın, her taşta:',
          '"Bismillahi Allahu Ekber" deyin',
          '',
          '📢 TELBİYE:',
          'İlk taşı atınca telbiye kesilir',
          'Artık telbiye getirilmez',
          '',
          '🐑 KURBAN:',
          'Taşlamadan sonra kurban kesin',
          'Kurban vekâleten kestirilebilir',
          '',
          '✂️ TIRAŞ (İLK TAHALLÜL):',
          'Kurban sonrası saç tıraşı veya kesimi',
          '',
          '🎉 İLK TAHALLÜL:',
          'Normal kıyafet giyilebilir',
          'Koku sürülebilir',
          '⚠️ Eşle birliktelik hâlâ yasak',
        ],
      },
      {
        'title': '6. Ziyaret Tavafı (10-12 Zilhicce)',
        'icon': Icons.refresh,
        'description': '⚠️ HACCIN FARZLARINDAN (Tavaf-ı İfada)',
        'details': [
          '⏰ TAVAF VAKTİ:',
          'Bayramın 1. günü en faziletli',
          '3. günün sonuna kadar yapılmalı',
          '',
          '🔄 TAVAF (7 ŞAVT):',
          'Kâbe etrafında 7 tur',
          'Tüm tavaf kuralları geçerli',
          '',
          '🕌 TAVAF NAMAZI:',
          'Makam-ı İbrahim arkasında 2 rekat',
          '',
          '🚶 SA\'Y:',
          'Daha önce yapılmadıysa sa\'y yapın',
          'Temettu haccında sa\'y şarttır',
          '',
          '🎉 TAM TAHALLÜL:',
          'Bu tavafla tüm ihram yasakları kalkar',
          'Eşle birliktelik de helal olur',
          '',
          '🔙 MİNA\'YA DÖNÜŞ:',
          'Tavaf sonrası Mina\'ya dönün',
          'Teşrik günlerinde Mina\'da kalın',
        ],
      },
      {
        'title': '7. Teşrik Günleri (11-12-13 Zilhicce)',
        'icon': Icons.calendar_today,
        'description': 'Mina\'da geceleme ve şeytan taşlama.',
        'details': [
          '📅 TEŞRİK GÜNLERİ:',
          'Kurban Bayramı\'nın 2., 3. ve 4. günleri',
          'Eyyâm-ı Teşrîk (Teşrik günleri)',
          '',
          '⏰ TAŞLAMA VAKTİ:',
          'Zevalden (öğle) sonra güneş batana kadar',
          'Zevalden önce taşlamak geçerli değil!',
          '',
          '🎯 ÜÇ ŞEYTAN TAŞLAMA:',
          'Her gün sırasıyla:',
          '1. Küçük Cemre (Mescid-i Hayf\'a en yakın)',
          '2. Orta Cemre',
          '3. Büyük Cemre (Akabe)',
          '',
          '📿 HER CEMREDE:',
          '7 taş atın (toplam 21 taş/gün)',
          'Her taşta "Bismillahi Allahu Ekber"',
          '',
          '🤲 DUA:',
          'Küçük ve orta cemre sonrası dua için durun',
          'Büyük cemre sonrası durulmaz, gidilir',
          '',
          '🌙 GECELEME:',
          'Her gece Mina\'da kalın (vacip)',
          'Gecenin çoğunu Mina\'da geçirin',
          '',
          '🏃 ACELE EDENLER (12 Zilhicce):',
          '12 Zilhicce\'de güneş batmadan Mina\'yı terk edebilir',
          'Bu durumda 13 Zilhicce taşlaması düşer',
          '',
          '⏳ ACELE ETMEYENLER (13 Zilhicce):',
          '13 Zilhicce\'de de üç şeytanı taşlayın',
          'Daha faziletlidir',
        ],
      },
      {
        'title': '8. Veda Tavafı',
        'icon': Icons.waving_hand,
        'description': 'Mekke\'den ayrılmadan son tavaf.',
        'details': [
          '⚠️ VAcİP:',
          'Mekke\'den ayrılmadan yapılması vacip',
          'Hayızlı kadın için düşer',
          '',
          '🔄 TAVAF (7 ŞAVT):',
          'Normal tavaf kuralları geçerli',
          'Remel ve ıztıba yapılmaz',
          '',
          '🕌 TAVAF NAMAZI:',
          '2 rekat namaz kılın',
          '',
          '💧 ZEMZEM:',
          'Son kez zemzem için',
          '',
          '🤲 VEDA DUASI:',
          '"Allahümme innel beyte beytüke,',
          'vel abde abdüke, vebnü abdike,',
          'hamelteni alâ mâ sehharte li min halkike..."',
          '',
          '👣 MESCİD\'DEN ÇIKIŞ:',
          'Sol ayakla çıkın',
          'Kâbe\'ye arkasını dönmeyin, geriye yürüyerek çıkın',
          '',
          '✅ HAC TAMAMLANDI!',
          'Allah kabul etsin!',
          'Hacc-ı mebrur olması için dua edin',
          'Günahlardan arınmış olarak dönün',
        ],
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: hajjSteps.length,
      itemBuilder: (context, index) {
        final step = hajjSteps[index];
        return _buildGuideCard(
          theme: theme,
          title: step['title'] as String,
          icon: step['icon'] as IconData,
          description: step['description'] as String,
          details: step['details'] as List<String>,
          isLast: index == hajjSteps.length - 1,
        );
      },
    );
  }

  Widget _buildGuideCard({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required String description,
    required List<String> details,
    required bool isLast,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 2.h),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: details.map((detail) {
                final isCompleted = detail.contains('✅');
                return Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.circle,
                        size: isCompleted ? 20 : 8,
                        color: isCompleted 
                            ? Colors.green 
                            : theme.colorScheme.primary,
                      ),
                      SizedBox(width: isCompleted ? 2.w : 3.w),
                      Expanded(
                        child: Text(
                          detail,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                            color: isCompleted 
                                ? Colors.green 
                                : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDualarGuide(ThemeData theme) {
    final dualar = [
      {
        'title': 'Telbiye Duası',
        'icon': Icons.record_voice_over,
        'description': 'İhrama girerken ve hac boyunca söylenir.',
        'details': [
          '📢 TELBİYE:',
          '',
          'لَبَّيْكَ اللّٰهُمَّ لَبَّيْكَ',
          'Lebbeyk Allâhümme lebbeyk,',
          '',
          'لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ',
          'Lebbeyk lâ şerîke leke lebbeyk,',
          '',
          'إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ',
          'İnnel hamde ven-ni\'mete leke vel-mülk,',
          '',
          'لَا شَرِيكَ لَكَ',
          'Lâ şerîke lek.',
          '',
          '📖 ANLAMI:',
          '"Buyur Allah\'ım buyur! Emrindeyim, buyur!',
          'Senin hiçbir ortağın yoktur, buyur emrindeyim!',
          'Hamd Sana, nimet Senindir, mülk de Senindir,',
          'Senin hiçbir ortağın yoktur."',
          '',
          '⏰ NE ZAMAN SÖYLENİR:',
          '• İhrama girerken',
          '• Mikat\'tan itibaren',
          '• Yürürken, otururken, yatarken',
          '• Namaz sonrası',
          '• Tepe ve vadilerde',
          '',
          '⛔ NE ZAMAN KESİLİR:',
          '• Umrede: Tavafa başlarken',
          '• Hacda: İlk taşı atarken (10 Zilhicce)',
        ],
      },
      {
        'title': 'Tavaf Duaları',
        'icon': Icons.refresh,
        'description': 'Her şavtta okunacak dualar.',
        'details': [
          '🟤 HACER-İ ESVED\'E DOKUNURKEN:',
          '"Bismillahi Allahu Ekber"',
          '(Allah\'ın adıyla, Allah en büyüktür)',
          '',
          '🔵 RÜKN-İ YEMANİ\'DE:',
          '"Rabbenâ âtinâ fid-dünyâ haseneten',
          've fil-âhireti haseneten',
          've kınâ azâben-nâr"',
          '',
          '📖 ANLAMI:',
          '"Rabbimiz! Bize dünyada iyilik ver,',
          'ahirette de iyilik ver',
          've bizi cehennem azabından koru."',
          '',
          '🤲 GENEL TAVAF DUALARI:',
          '"Sübhânallahi vel-hamdülillahi',
          've lâ ilâhe illallahu vallahu ekber',
          've lâ havle ve lâ kuvvete illâ billah"',
          '',
          '"Allahümme inni es\'elükel-afve vel-âfiyete',
          'fid-dini ved-dünya vel-âhire"',
          '',
          '📿 TAVSİYE:',
          'Kendi dilinizle de dua edebilirsiniz',
          'İçten ve samimi dua önemlidir',
          'Kur\'an okuyabilirsiniz',
        ],
      },
      {
        'title': 'Sa\'y Duaları',
        'icon': Icons.directions_walk,
        'description': 'Safa ve Merve arası okunacak dualar.',
        'details': [
          '⛰️ SAFA TEPESINDE:',
          '"İnnes-Safâ vel-Mervete min şeâirillah"',
          '',
          'Sonra Kâbe\'ye dönerek:',
          '"Lâ ilâhe illallahu vahdehû lâ şerîke leh,',
          'lehül-mülkü ve lehül-hamdü,',
          'yuhyî ve yümît,',
          've hüve alâ külli şey\'in kadîr.',
          '',
          'Lâ ilâhe illallahu vahdeh,',
          'enceze va\'deh, ve nasara abdeh,',
          've hezemel-ahzâbe vahdeh."',
          '',
          '📖 ANLAMI:',
          '"Allah\'tan başka ilah yoktur,',
          'O tektir, ortağı yoktur.',
          'Mülk O\'nundur, hamd O\'na mahsustur.',
          'O diriltir ve öldürür.',
          'O her şeye kadirdir..."',
          '',
          '🏃 YEŞİL IŞIKLAR ARASINDA:',
          'Erkekler koşarak (hervele) geçer',
          '"Rabbiğfir verham ve tecâvez ammâ ta\'lem,',
          'inneke entel-eazzül-ekram"',
          '',
          '⛰️ MERVE\'DE:',
          'Safa\'daki dualar aynen tekrarlanır',
        ],
      },
      {
        'title': 'Arafat Duaları',
        'icon': Icons.landscape,
        'description': 'Vakfe\'de okunacak dualar.',
        'details': [
          '🌟 EN FAZİLETLİ DUA:',
          '"Lâ ilâhe illallâhu vahdehû lâ şerîke leh,',
          'lehül-mülkü ve lehül-hamdü,',
          'yuhyî ve yümît,',
          've hüve alâ külli şey\'in kadîr."',
          '',
          '📖 HADİS:',
          '"Duanın en hayırlısı Arafat günü yapılandır."',
          '(Tirmizi)',
          '',
          '🤲 ARAFAT\'TA OKUNACAK DUALAR:',
          '"Allahümme innî zalemtü nefsî zulmen kesîren,',
          've lâ yağfiruz-zunûbe illâ ente,',
          'fağfir lî mağfireten min indike,',
          'verhamnî inneke entel-ğafûrur-rahîm"',
          '',
          '"Allahümme âtinâ fid-dünyâ haseneten,',
          've fil-âhireti haseneten,',
          've kınâ azâben-nâr"',
          '',
          '⏰ VAKFE VAKTİ:',
          'Zevalden güneş batışına kadar',
          'Elleri kaldırarak, kıbleye dönerek',
          'Ayakta veya oturarak yapılabilir',
          '',
          '💡 TAVSİYELER:',
          'Ağlayarak dua edin',
          'Tövbe ve istiğfar edin',
          'Kendi dilinizle dua edebilirsiniz',
          'Başkaları için de dua edin',
        ],
      },
      {
        'title': 'Müzdelife ve Mina Duaları',
        'icon': Icons.gps_fixed,
        'description': 'Taşlama ve geceleme duaları.',
        'details': [
          '🌙 MÜZDELİFE VAKFESI:',
          '"Allahümme kemâ evkaftenâ fîhi',
          've eraytenâ iyyâhu,',
          'fevaffiknâ li zikrike kemâ hedeytenâ,',
          'vağfir lenâ verhamnâ kemâ va\'edtenâ"',
          '',
          '🎯 TAŞ ATARKEN:',
          'Her taşta: "Bismillahi Allahu Ekber"',
          '',
          '🤲 KÜÇÜK CEMRE SONRASI:',
          'Kıbleye dönüp dua edin:',
          '"Allahümmec\'alhü haccen mebrûren,',
          've sa\'yen meşkûren,',
          've zenben mağfûren"',
          '',
          '📖 ANLAMI:',
          '"Allah\'ım! Bu haccı makbul bir hac,',
          'bu sa\'yi kabul görmüş bir sa\'y,',
          've günahları bağışlanmış kıl."',
          '',
          '🤲 ORTA CEMRE SONRASI:',
          'Yine kıbleye dönüp dua edin',
          'İstediğiniz duaları yapın',
          '',
          '⚠️ BÜYÜK CEMRE SONRASI:',
          'Durulmaz, hemen gidilir',
        ],
      },
      {
        'title': 'Medine Ziyaret Duaları',
        'icon': Icons.mosque,
        'description': 'Mescid-i Nebevi ve Ravza duaları.',
        'details': [
          '🕌 MESCİD\'E GİRİŞTE:',
          '"Allahümmeftah lî ebvâbe rahmetik"',
          '(Allah\'ım, rahmet kapılarını bana aç)',
          '',
          '🌹 RAVZA-İ MUTAHHARA\'DA:',
          '"Esselâmü aleyke yâ Rasûlallah,',
          'Esselâmü aleyke yâ Nebiyyallah,',
          'Esselâmü aleyke yâ Habîballah,',
          'Esselâmü aleyke yâ Hayra halkillah"',
          '',
          '👤 HZ. EBU BEKİR\'E SELAM:',
          '"Esselâmü aleyke yâ Halîfete Rasûlillah,',
          'Esselâmü aleyke yâ Ebâ Bekrin es-Sıddîk"',
          '',
          '👤 HZ. ÖMER\'E SELAM:',
          '"Esselâmü aleyke yâ Emîrel-Mü\'minîn,',
          'Esselâmü aleyke yâ Ömeral-Fârûk"',
          '',
          '💚 RAVZA\'DA NAMAZ:',
          '"Mescidimle evim arasındaki alan,',
          'cennet bahçelerinden bir bahçedir."',
          '(Buhari)',
          '',
          '🤲 GENEL DUA:',
          'İstediğiniz duaları yapın',
          'Peygamberimize salat-ü selam getirin',
        ],
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: dualar.length,
      itemBuilder: (context, index) {
        final dua = dualar[index];
        return _buildGuideCard(
          theme: theme,
          title: dua['title'] as String,
          icon: dua['icon'] as IconData,
          description: dua['description'] as String,
          details: dua['details'] as List<String>,
          isLast: index == dualar.length - 1,
        );
      },
    );
  }

  Widget _buildIhramGuide(ThemeData theme) {
    final ihramTopics = [
      {
        'title': 'İhram Yasakları',
        'icon': Icons.block,
        'description': 'İhramlıyken yapılması yasak olan şeyler.',
        'details': [
          '⛔ GENEL YASAKLAR:',
          '',
          '1️⃣ DİKİŞLİ GİYSİ (Erkekler):',
          '• Normal kıyafet giymek yasak',
          '• Çorap, ayakkabı, iç çamaşırı yasak',
          '• İzar ve rida giyilir',
          '',
          '2️⃣ BAŞ VE YÜZ ÖRTMEK (Erkekler):',
          '• Başı örtmek yasak',
          '• Yüzü örtmek yasak',
          '• Şemsiye, çadır vs. gölgelenme serbest',
          '',
          '3️⃣ KOKU SÜRÜNMEK:',
          '• Parfüm, kolonya, deodorant yasak',
          '• Kokulu sabun, şampuan yasak',
          '• Kokusuz temizlik ürünleri serbest',
          '',
          '4️⃣ SAÇ VE TIRNAK KESMEK:',
          '• Saç kesmek/koparmak yasak',
          '• Sakal kesmek yasak',
          '• Tırnak kesmek yasak',
          '',
          '5️⃣ CİNSEL İLİŞKİ:',
          '• Eşle birliktelik yasak',
          '• Şehvetle dokunmak, öpmek yasak',
          '• Tam tahallüle kadar devam eder',
        ],
      },
      {
        'title': 'Avlanma ve Bitki Yasakları',
        'icon': Icons.pets,
        'description': 'Harem bölgesinde geçerli özel yasaklar.',
        'details': [
          '🦌 AVLANMA YASAĞI:',
          '• Kara hayvanı avlamak yasak',
          '• Av hayvanına yardım etmek yasak',
          '• Avı göstermek, korkutmak yasak',
          '• Deniz hayvanları serbest',
          '',
          '🌿 BİTKİ YASAĞI (Harem Bölgesi):',
          '• Yeşil ot, ağaç kesmek yasak',
          '• Bitki koparmak yasak',
          '• İzhir otu hariç',
          '',
          '📍 HAREM BÖLGESİ:',
          '• Mekke ve çevresi',
          '• Sınırları belirlenmiş kutsal alan',
          '• İhramlı olsun olmasın geçerli',
          '',
          '⚠️ CEZASI:',
          '• Hayvan avına göre fidye',
          '• Büyük av: Deve/sığır',
          '• Orta av: Koyun/keçi',
          '• Küçük av: Sadaka',
        ],
      },
      {
        'title': 'Kadınlara Özel Hükümler',
        'icon': Icons.woman,
        'description': 'Kadınların ihramda dikkat etmesi gerekenler.',
        'details': [
          '👗 KIYAFET:',
          '• Normal tesettür kıyafeti giyilir',
          '• Dikişli giysi serbesttir',
          '• Çorap, ayakkabı giyilebilir',
          '',
          '🧕 YÜZ VE ELLER:',
          '• Yüz açık olmalı (peçe yasak)',
          '• Eldiven giymek yasak',
          '• Şapka tarzı başlık giyilebilir',
          '',
          '🩸 HAYIZ (ADET) DURUMU:',
          '• İhrama girilebilir',
          '• Telbiye söylenebilir',
          '• Dua edilebilir',
          '• Tavaf hariç her şey yapılabilir',
          '• Temizlenince tavaf yapılır',
          '',
          '🤰 HAMİLELİK:',
          '• Sağlık durumu uygunsa hac yapılır',
          '• Zorluklar için vekâlet düşünülebilir',
          '',
          '💍 EVLİLİK:',
          '• Nikah kıymak yasak',
          '• Nişanlanmak yasak',
          '• İhram sona erince yapılabilir',
        ],
      },
      {
        'title': 'Ceza Gerektiren Durumlar',
        'icon': Icons.gavel,
        'description': 'Yasak ihlallerinde uygulanacak cezalar.',
        'details': [
          '🐑 DEM (KURBAN):',
          'Şu durumlarda koyun/keçi kesilir:',
          '• İhram yasaklarını ihlal',
          '• Vacip terki',
          '• Tavafta noksanlık',
          '',
          '🐄 BEDENE (BÜYÜK KURBAN):',
          'Deve veya sığır kesilir:',
          '• Arafat vakfesini kaçırma',
          '• Cinsel ilişki (hac bozulur)',
          '',
          '💰 FİDYE:',
          'Üç seçenekten biri:',
          '• 3 gün oruç',
          '• 6 fakire yemek',
          '• 1 koyun/keçi kurban',
          '',
          '🍞 SADAKA:',
          'Küçük ihlallerde:',
          '• 1 avuç yiyecek sadaka',
          '• Fitre miktarı sadaka',
          '',
          '⚠️ MAZERET HALİ:',
          '• Hastalık, zorunluluk varsa',
          '• Fidye seçeneklerinden biri uygulanır',
          '• Tövbe ve istiğfar edilir',
          '',
          '✅ UNUTMA/HATA:',
          '• Bilerek yapılmamışsa',
          '• Kefaret azalabilir',
          '• Tövbe gerekir',
        ],
      },
      {
        'title': 'İhrama Giriş',
        'icon': Icons.login,
        'description': 'İhrama nasıl ve nerede girilir.',
        'details': [
          '🚿 HAZIRLIK:',
          '• Gusül veya abdest alın',
          '• Saç, sakal, tırnak düzeltin',
          '• Koltuk altı ve kasık temizliği',
          '',
          '👔 ERKEKLER İÇİN:',
          '• İç çamaşırları çıkarın',
          '• İzar (bel örtüsü) sarın',
          '• Rida (omuz örtüsü) örtün',
          '• Terlik giyin',
          '',
          '👗 KADINLAR İÇİN:',
          '• Normal tesettür kıyafeti',
          '• Yüz açık (peçe yok)',
          '• Eldiven yok',
          '',
          '🕌 İHRAM NAMAZI:',
          '• 2 rekat namaz kılın',
          '• 1. rekatta Kâfirûn',
          '• 2. rekatta İhlas',
          '',
          '🤲 NİYET:',
          'Umre için: "Allahümme innî ürîdül umrete,',
          'feyessirhâ lî ve tekabbelhâ minnî"',
          '',
          'Hac için: "Allahümme innî ürîdül hacce,',
          'feyessirhû lî ve tekabbelhü minnî"',
          '',
          '📢 TELBİYE:',
          'Niyet ettikten sonra telbiye getirin',
          '"Lebbeyk Allahümme lebbeyk..."',
        ],
      },
      {
        'title': 'İhramda Serbest Olanlar',
        'icon': Icons.check_circle,
        'description': 'İhramlıyken yapılması serbest olan şeyler.',
        'details': [
          '✅ TEMİZLİK:',
          '• Gusül almak',
          '• Kokusuz sabunla yıkanmak',
          '• Diş fırçalamak',
          '• Misvak kullanmak',
          '',
          '✅ BARINMA:',
          '• Çadır, bina altında kalmak',
          '• Şemsiye kullanmak',
          '• Klima, vantilatör kullanmak',
          '',
          '✅ GİYİM (Erkek):',
          '• Kemer/kuşak takmak',
          '• Para kesesi taşımak',
          '• Saat takmak',
          '• Gözlük takmak',
          '',
          '✅ GENEL:',
          '• Ayna bakmak',
          '• Yüzük takmak',
          '• Yiyecek-içecek tüketmek',
          '• İlaç kullanmak',
          '• Telefon kullanmak',
          '',
          '✅ SAĞLIK:',
          '• Kan aldırmak',
          '• Enjeksiyon yaptırmak',
          '• Yara sarmak',
          '• Ameliyat olmak (zorunlu)',
        ],
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: ihramTopics.length,
      itemBuilder: (context, index) {
        final topic = ihramTopics[index];
        return _buildGuideCard(
          theme: theme,
          title: topic['title'] as String,
          icon: topic['icon'] as IconData,
          description: topic['description'] as String,
          details: topic['details'] as List<String>,
          isLast: index == ihramTopics.length - 1,
        );
      },
    );
  }

  Widget _buildHajjTypesGuide(ThemeData theme) {
    final hajjTypes = [
      {
        'title': 'İfrad Haccı',
        'icon': Icons.looks_one,
        'description': 'Sadece hac yapılır, umre yoktur.',
        'details': [
          '📖 TANIMI:',
          'Sadece hac niyetiyle ihrama girilir',
          'Umre yapılmaz',
          '',
          '⏰ NE ZAMAN:',
          'Hac aylarında (Şevval, Zilkade, Zilhicce)',
          'Mikat\'ta hac için ihrama girilir',
          '',
          '📝 YAPILIŞ SIRASI:',
          '1. Mikat\'ta hac için ihrama gir',
          '2. Kudüm tavafı yap (sünnet)',
          '3. Arafat vakfesi',
          '4. Müzdelife vakfesi',
          '5. Şeytan taşlama',
          '6. Ziyaret tavafı',
          '7. Sa\'y (Kudümde yapılmadıysa)',
          '8. Veda tavafı',
          '',
          '🐑 KURBAN:',
          'Kurban kesmek vacip değil (ama müstehap)',
          '',
          '✅ AVANTAJLARI:',
          '• Tek ihram, kolay',
          '• Kurban zorunlu değil',
          '• Mekkeliler için uygun',
          '',
          '👥 KİMLER YAPAR:',
          'Mekke\'de ikamet edenler',
          'Sadece hac niyetiyle gelenler',
        ],
      },
      {
        'title': 'Temettu Haccı',
        'icon': Icons.looks_two,
        'description': 'Önce umre, sonra hac yapılır. En yaygın türdür.',
        'details': [
          '📖 TANIMI:',
          'Önce umre yapılır, ihramdan çıkılır',
          'Sonra hac için tekrar ihrama girilir',
          '',
          '⭐ EN FAZİLETLİ:',
          'Hz. Peygamber\'in tavsiye ettiği yöntem',
          'Afakiler (uzaktan gelenler) için en uygun',
          '',
          '📝 YAPILIŞ SIRASI:',
          '1. Mikat\'ta umre için ihrama gir',
          '2. Umre tavafı yap (7 şavt)',
          '3. Sa\'y yap',
          '4. Saç kes/tıraş ol - İhramdan çık',
          '5. Terviye günü (8 Zilhicce) hac için ihrama gir',
          '6. Arafat vakfesi',
          '7. Müzdelife vakfesi',
          '8. Şeytan taşlama',
          '9. Kurban kes',
          '10. Ziyaret tavafı ve Sa\'y',
          '11. Veda tavafı',
          '',
          '🐑 KURBAN:',
          '⚠️ Kurban kesmek VACİP',
          'Kurban kesemezse 10 gün oruç',
          '(3 gün hacda, 7 gün memleketinde)',
          '',
          '✅ AVANTAJLARI:',
          '• İki ayrı ibadet sevabı',
          '• Arrada normal kıyafet',
          '• Rahat hareket',
        ],
      },
      {
        'title': 'Kıran Haccı',
        'icon': Icons.looks_3,
        'description': 'Umre ve hac tek ihramla yapılır.',
        'details': [
          '📖 TANIMI:',
          'Umre ve hac birlikte niyet edilir',
          'Tek ihramla her ikisi yapılır',
          '',
          '📝 YAPILIŞ SIRASI:',
          '1. Mikat\'ta umre ve hac için birlikte ihrama gir',
          '2. Umre tavafı yap',
          '3. Umre sa\'yi yap',
          '4. İhramdan çıkma - İhram devam eder!',
          '5. Arafat vakfesi',
          '6. Müzdelife vakfesi',
          '7. Şeytan taşlama',
          '8. Kurban kes',
          '9. Saç kes/tıraş ol - İhramdan çık',
          '10. Ziyaret tavafı',
          '11. Veda tavafı',
          '',
          '🐑 KURBAN:',
          '⚠️ Kurban kesmek VACİP',
          '',
          '⚠️ DİKKAT:',
          'Umre sa\'yi ile hac sa\'yi ayrı ayrı yapılmalı',
          'Tavaf sayısı aynı olsa da niyetler farklı',
          '',
          '✅ AVANTAJLARI:',
          '• Tek ihramla iki ibadet',
          '• Daha çok sevap',
          '',
          '❌ ZORLUKLARI:',
          '• Uzun süre ihramlı kalınır',
          '• Yasaklara dikkat gerekir',
        ],
      },
      {
        'title': 'Hac Türleri Karşılaştırma',
        'icon': Icons.compare_arrows,
        'description': 'Üç hac türünün karşılaştırması.',
        'details': [
          '📊 KARŞILAŞTIRMA TABLOSU:',
          '',
          '🔹 İFRAD:',
          '• Umre: Yok',
          '• İhram sayısı: 1',
          '• Kurban: Zorunlu değil',
          '• Zorluk: Kolay',
          '',
          '🔹 TEMETTU:',
          '• Umre: Ayrı (önce)',
          '• İhram sayısı: 2',
          '• Kurban: VACİP',
          '• Zorluk: Orta',
          '',
          '🔹 KIRAN:',
          '• Umre: Birlikte',
          '• İhram sayısı: 1 (uzun)',
          '• Kurban: VACİP',
          '• Zorluk: Zor',
          '',
          '⭐ HANGİSİ SEÇİLMELİ?',
          '',
          '✅ TEMETTU TAVSİYE EDİLİR:',
          '• En faziletli (hadis)',
          '• Pratik ve rahat',
          '• Organizasyonlar bunu uygular',
          '',
          '📍 MEKKELİLER İÇİN:',
          '• İfrad haccı uygundur',
        ],
      },
      {
        'title': 'Bedel Haccı',
        'icon': Icons.person_outline,
        'description': 'Başkası adına yapılan hac.',
        'details': [
          '📖 TANIMI:',
          'Hac yapamayacak durumda olan birisi adına',
          'Başka birinin hac yapması',
          '',
          '✅ KİMLER İÇİN YAPILABİLİR:',
          '• Yaşlılık sebebiyle gidemeyenler',
          '• Kronik hastalar',
          '• Vefat etmiş olanlar',
          '',
          '📝 ŞARTLARI:',
          '1. Bedel hacca gidecek kişi:',
          '   • Kendi haccını yapmış olmalı',
          '   • Hac ibadetini bilmeli',
          '   • Güvenilir olmalı',
          '',
          '2. Hac yaptıracak kişi:',
          '   • Mali gücü olmalı',
          '   • Bizzat gidemeyecek durumda olmalı',
          '',
          '🤲 NİYET:',
          '"Allah\'ım! Bu haccı [kişinin adı] adına yapıyorum"',
          '',
          '💰 MASRAFLAR:',
          '• Tüm masraflar hac sahibine ait',
          '• Hac yapan kişiye ücret verilebilir',
          '',
          '⚠️ DİKKAT:',
          '• Bedel hac kendi haccın yerine geçmez',
          '• Önce kendi haccını yap',
        ],
      },
      {
        'title': 'Nafile Hac ve Umre',
        'icon': Icons.star,
        'description': 'Farz dışında yapılan hac ve umreler.',
        'details': [
          '📖 NAFİLE HAC:',
          'Farz haccını yapmış olanların',
          'tekrar hac yapması',
          '',
          '⭐ FAZİLETİ:',
          '"Peş peşe hac ve umre yapın.',
          'Çünkü bunlar günahları ve fakirliği giderir."',
          '(Tirmizi)',
          '',
          '📿 NAFİLE UMRE:',
          'İstediğiniz zaman yapılabilir',
          '',
          '📅 UMRE VAKİTLERİ:',
          '• Yıl boyunca yapılabilir',
          '• Ramazan umresi çok faziletli',
          '• Arefe günü umre mekruh',
          '',
          '🌙 RAMAZAN UMRESİ:',
          '"Ramazan\'da umre yapmak,',
          'benimle birlikte hac yapmak gibidir."',
          '(Buhari, Müslim)',
          '',
          '⏰ UMRELER ARASI SÜRE:',
          '• Saç uzayacak kadar beklemek müstehap',
          '• Peş peşe de yapılabilir',
          '',
          '🤲 NİYET:',
          'Nafile olduğunu belirterek niyet edin',
          'Sevabını bağışlayabilirsiniz',
        ],
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: hajjTypes.length,
      itemBuilder: (context, index) {
        final type = hajjTypes[index];
        return _buildGuideCard(
          theme: theme,
          title: type['title'] as String,
          icon: type['icon'] as IconData,
          description: type['description'] as String,
          details: type['details'] as List<String>,
          isLast: index == hajjTypes.length - 1,
        );
      },
    );
  }

  Widget _buildPracticalGuide(ThemeData theme) {
    final practicalInfo = [
      {
        'title': 'Mikat Noktaları',
        'icon': Icons.location_on,
        'description': 'İhrama girilecek yerler.',
        'details': [
          '📍 MİKAT NEDİR?',
          'İhrama girilmesi gereken sınır noktaları',
          'Bu noktalar geçilmeden ihrama girilmeli',
          '',
          '🛫 UÇAKLA GELENLER:',
          'Uçakta mikat üzerinden geçerken',
          'veya havalimanında ihrama girilir',
          'Cidde\'den sonra girilmez!',
          '',
          '📍 MİKAT NOKTALARI:',
          '',
          '1️⃣ ZÜLHULEYFE (Âbâr-ı Ali):',
          '• Medine yönünden gelenler',
          '• Mekke\'ye 450 km',
          '',
          '2️⃣ CUHFE:',
          '• Suriye, Mısır, Kuzey Afrika\'dan',
          '• Rabığ yakınları',
          '',
          '3️⃣ KARNÜ\'L-MENAZİL (Seyl):',
          '• Necid bölgesinden gelenler',
          '• Taif yönünden',
          '',
          '4️⃣ YELEMLEM:',
          '• Yemen yönünden gelenler',
          '',
          '5️⃣ ZATÜ IRK:',
          '• Irak yönünden gelenler',
          '',
          '⚠️ CİDDE:',
          'Cidde mikat değildir!',
          'Uçakta veya öncesinde ihrama girin',
        ],
      },
      {
        'title': 'Mekke Ziyaret Yerleri',
        'icon': Icons.mosque,
        'description': 'Mekke\'de görülecek kutsal mekanlar.',
        'details': [
          '🕋 MESCİD-İ HARAM:',
          '• Kâbe-i Muazzama',
          '• Hacer-i Esved',
          '• Makam-ı İbrahim',
          '• Hicr-i İsmail (Hatim)',
          '• Zemzem kuyusu',
          '• Rükn-i Yemani',
          '• Mültezem',
          '• Safa ve Merve tepeleri',
          '',
          '🏔️ CEBEL-İ NUR:',
          '• Hira Mağarası',
          '• İlk vahyin indiği yer',
          '• Mekke\'nin kuzeyinde',
          '',
          '🏔️ CEBEL-İ SEVR:',
          '• Sevr Mağarası',
          '• Hicret sığınağı',
          '• Hz. Ebu Bekir ile 3 gün',
          '',
          '📍 DİĞER YERLER:',
          '• Cennetü\'l-Mualla (kabristanlık)',
          '• Mescid-i Cin',
          '• Hz. Hatice\'nin evi (yaklaşık yer)',
          '• Peygamberimizin doğduğu yer',
          '',
          '⛰️ MİNA:',
          '• Cemreler (şeytan taşlama)',
          '• Mescid-i Hayf',
          '',
          '⛰️ ARAFAT:',
          '• Cebel-i Rahme (Rahmet Dağı)',
          '• Nemire Mescidi',
        ],
      },
      {
        'title': 'Medine Ziyaret Yerleri',
        'icon': Icons.location_city,
        'description': 'Medine\'de görülecek kutsal mekanlar.',
        'details': [
          '🕌 MESCİD-İ NEBEVİ:',
          '• Ravza-i Mutahhara',
          '• Peygamberimizin kabri',
          '• Hz. Ebu Bekir\'in kabri',
          '• Hz. Ömer\'in kabri',
          '',
          '🌹 RAVZA-İ MUTAHHARA:',
          '"Evimle minberim arası cennet bahçesidir"',
          '(Buhari)',
          '',
          '📍 DİĞER MESCİDLER:',
          '• Mescid-i Kuba (ilk mescid)',
          '• Mescid-i Kıbleteyn',
          '• Mescid-i Gamame',
          '',
          '🏔️ UHUD DAĞI:',
          '• Uhud Şehitliği',
          '• Hz. Hamza\'nın kabri',
          '• Okçular Tepesi',
          '',
          '📍 CENNETܒL-BAKİ:',
          '• Sahabe kabristanlığı',
          '• Ehl-i Beyt kabirleri',
          '',
          '📍 HENDEK BÖLGESİ:',
          '• Yedi Mescidler',
          '• Selman Çukuru',
          '',
          '⏰ ZİYARET VAKTİ:',
          'Hacdan önce veya sonra',
          '8-10 gün kalınması tavsiye edilir',
        ],
      },
      {
        'title': 'Sık Yapılan Hatalar',
        'icon': Icons.warning,
        'description': 'Hac ve umrede dikkat edilmesi gerekenler.',
        'details': [
          '❌ İHRAM HATALARI:',
          '• Mikat\'ı ihramsız geçmek',
          '• Dikişli giysi giymek (erkek)',
          '• Koku sürmek',
          '• Peçe/eldiven takmak (kadın)',
          '',
          '❌ TAVAF HATALARI:',
          '• Yanlış yönde dönmek',
          '• Hicr-i İsmail içinden geçmek',
          '• Şavt sayısını yanlış saymak',
          '• Remel\'i her şavtta yapmak',
          '',
          '❌ SA\'Y HATALARI:',
          '• Abdestsiz sa\'y yapmak (mekruh)',
          '• Yanlış tepeden başlamak',
          '• Hervele yapmamak (erkek)',
          '',
          '❌ ARAFAT HATALARI:',
          '• Urene vadisinde vakfe yapmak',
          '• Güneş batmadan ayrılmak',
          '• Sadece Cebel-i Rahme\'de durmak',
          '',
          '❌ TAŞLAMA HATALARI:',
          '• Zevalden önce taşlamak (teşrik)',
          '• Sırayı karıştırmak',
          '• Büyük taş atmak',
          '',
          '❌ GENEL HATALAR:',
          '• Veda tavafını unutmak',
          '• Delil dinlememek',
          '• İzdihamda sabrı kaybetmek',
        ],
      },
      {
        'title': 'Pratik Tavsiyeler',
        'icon': Icons.lightbulb,
        'description': 'Hac yolculuğu için faydalı bilgiler.',
        'details': [
          '🎒 YANINA AL:',
          '• İhram takımı (erkek)',
          '• Rahat terlik',
          '• Güneş şemsiyesi',
          '• Küçük seccade',
          '• İlaçlarınız',
          '• Şarj aleti',
          '• Ufak çanta (bel/omuz)',
          '',
          '💊 SAĞLIK:',
          '• Gerekli aşıları yaptırın',
          '• İlaçlarınızı yanınıza alın',
          '• Bol su için',
          '• Sıcaktan korunun',
          '',
          '📱 İLETİŞİM:',
          '• Grubunuzun telefonlarını kaydedin',
          '• Otel adresini yanınızda taşıyın',
          '• Kafile numaranızı ezberleyin',
          '',
          '🤲 MANEVİ HAZIRLIK:',
          '• Helalleşin',
          '• Borçları ödeyin',
          '• Vasiyet yazın',
          '• Tövbe edin',
          '',
          '📿 TAVSİYELER:',
          '• Sabırlı olun',
          '• Tartışmayın',
          '• İbadetlere odaklanın',
          '• Fırsat buldukça Kâbe\'yi tavaf edin',
          '• Bol bol dua edin',
        ],
      },
      {
        'title': 'Önemli Telefon ve Bilgiler',
        'icon': Icons.phone,
        'description': 'Acil durumlar için bilgiler.',
        'details': [
          '📞 ACİL NUMARALAR (S.Arabistan):',
          '• Genel Acil: 911',
          '• Ambulans: 997',
          '• Polis: 999',
          '• İtfaiye: 998',
          '',
          '🏥 SAĞLIK:',
          '• Hastaneler ücretsiz (hacılar için)',
          '• Mescid\'lerde sağlık birimleri var',
          '• Kafile doktorunuza danışın',
          '',
          '🕐 VAKİT FARKI:',
          '• Türkiye ile aynı saat dilimi',
          '• (Yaz saati uygulaması farklı olabilir)',
          '',
          '💵 PARA:',
          '• Para birimi: Suudi Riyali (SAR)',
          '• Dolar/Euro kolayca bozulur',
          '• Kredi kartı yaygın',
          '',
          '🌡️ HAVA DURUMU:',
          '• Yaz: 40-50°C',
          '• Kış: 20-30°C',
          '• Nem oranı düşük',
          '',
          '⏰ NAMAZ VAKİTLERİ:',
          '• Mescid\'lerde ezan okunur',
          '• Namaz saatlerine dikkat',
          '• Cuma namazı için erken gidin',
        ],
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: practicalInfo.length,
      itemBuilder: (context, index) {
        final info = practicalInfo[index];
        return _buildGuideCard(
          theme: theme,
          title: info['title'] as String,
          icon: info['icon'] as IconData,
          description: info['description'] as String,
          details: info['details'] as List<String>,
          isLast: index == practicalInfo.length - 1,
        );
      },
    );
  }

  void _showThemeSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ThemeSettingsWidget(
          isDarkMode: _themeManager.isDarkMode,
          onThemeToggle: (value) async {
            await _themeManager.toggleTheme();
            HapticFeedback.lightImpact();
          },
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hakkında'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mirac Prayer Assistant',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Versiyon: 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Text(
              'Namaz vakitlerini takip edin, zikirlerinizi sayın ve dini günleri hatırlayın.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Text(
              'İletişim: info@miracprayer.com',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showResetConfirmation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Ayarları Sıfırla'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Ayarları Sıfırla',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Tüm ayarları varsayılan değerlere döndürmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      setState(() {
        _masterNotification = true;
        _isPeriodModeEnabled = false;
        _selectedCity = 'İstanbul';
        _calculationMethod = 'Diyanet';
        _enablePrayerNotifications = true;
        _enableHolidayNotifications = true;
        _notificationOffsetMinutes = 10;
      });

      await _themeManager.setThemeMode(ThemeMode.light);

      Fluttertoast.showToast(
        msg: 'Ayarlar başarıyla sıfırlandı',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Ayarlar sıfırlanırken hata oluştu',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Ayarlar',
        automaticallyImplyLeading: false,
        showDivider: true,
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          children: [
            // Notification Settings
            _buildSettingsTile(
              context: context,
              icon: 'notifications',
              title: 'Bildirim Ayarları',
              subtitle: 'Namaz vakti bildirimleri',
              onTap: _showNotificationSettings,
            ),

            SizedBox(height: 1.h),

            // NEW: Period Mode Settings
            _buildSettingsTile(
              context: context,
              icon: 'event_available',
              title: 'Özel Gün Modu',
              subtitle: _isPeriodModeEnabled ? 'Aktif' : 'Pasif',
              onTap: _showPeriodModeSettings,
            ),

            SizedBox(height: 1.h),

            // Location & Calculation Settings
            _buildSettingsTile(
              context: context,
              icon: 'location_on',
              title: 'Konum ve Hesaplama',
              subtitle: 'Şehir ve hesaplama metodu',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: CustomIconWidget(
                              iconName: 'location_city',
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                            title: const Text('Konum Ayarları'),
                            onTap: () {
                              Navigator.pop(context);
                              _showLocationSettings();
                            },
                          ),
                          ListTile(
                            leading: CustomIconWidget(
                              iconName: 'calculate',
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                            title: const Text('Hesaplama Metodu'),
                            onTap: () {
                              Navigator.pop(context);
                              _showCalculationSettings();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 1.h),

            // Compact Kıble entry: opens modal with full guidance
            _buildSettingsTile(
              context: context,
              icon: 'navigation',
              title: 'Kıble Rehberi',
              subtitle: 'Kıble rehberi ve günlük dua',
              onTap: _showQiblaGuidanceSheet,
            ),

            SizedBox(height: 1.h),

            // Namaz Takibi
            _buildSettingsTile(
              context: context,
              icon: 'check_circle',
              title: 'Namaz Takibi',
              subtitle: 'Günlük namaz takibi ve istatistikler',
              onTap: () => Navigator.pushNamed(context, '/prayer-tracking-screen'),
            ),

            SizedBox(height: 1.h),

            // Hadis-i Şerif
            _buildSettingsTile(
              context: context,
              icon: 'menu_book',
              title: 'Hadis-i Şerif',
              subtitle: '40 hadis ve günün hadisi',
              onTap: () => Navigator.pushNamed(context, '/hadith-screen'),
            ),

            SizedBox(height: 1.h),

            // Ayet-el Kürsi ve Dualar
            _buildSettingsTile(
              context: context,
              icon: 'auto_awesome',
              title: 'Ayet-el Kürsi ve Dualar',
              subtitle: 'Önemli dualar ve anlamları',
              onTap: () => Navigator.pushNamed(context, '/dua-screen'),
            ),

            SizedBox(height: 1.h),

            // Dini Bilgi Yarışması
            _buildSettingsTile(
              context: context,
              icon: 'quiz',
              title: 'Dini Bilgi Yarışması',
              subtitle: 'Bilgini test et, öğren ve eğlen',
              onTap: () => Navigator.pushNamed(context, '/quiz-screen'),
            ),

            SizedBox(height: 1.h),

            // Cami Bulucu
            _buildSettingsTile(
              context: context,
              icon: 'mosque',
              title: 'Cami Bulucu',
              subtitle: 'Yakınındaki camileri bul, imkanları gör',
              onTap: () => Navigator.pushNamed(context, '/mosque-finder-screen'),
            ),

            SizedBox(height: 1.h),

            // Akıllı Seferi Modu (🔒 PREMIUM)
            FutureBuilder<bool>(
              future: _premiumService.canAccessFeature(PremiumFeature.travelMode),
              builder: (context, snapshot) {
                final canAccess = snapshot.data ?? false;
                return _buildSettingsTile(
                  context: context,
                  icon: 'flight_takeoff',
                  title: 'Akıllı Seferi Modu',
                  subtitle: 'GPS ile otomatik seyahat algılama',
                  isPremium: !canAccess,
                  onTap: () async {
                    if (canAccess) {
                      Navigator.pushNamed(context, '/travel-mode-screen');
                    } else {
                      showPremiumDialog(context, featureName: 'Akıllı Seferi Modu');
                    }
                  },
                );
              },
            ),

            SizedBox(height: 1.h),

            // Cami Modu (Rahatsız Etme) (🔒 PREMIUM)
            FutureBuilder<bool>(
              future: _premiumService.canAccessFeature(PremiumFeature.mosqueDND),
              builder: (context, snapshot) {
                final canAccess = snapshot.data ?? false;
                return _buildSettingsTile(
                  context: context,
                  icon: 'do_not_disturb_on',
                  title: 'Cami Modu',
                  subtitle: 'Namaz vakitlerinde otomatik sessiz mod',
                  isPremium: !canAccess,
                  onTap: () async {
                    if (canAccess) {
                      Navigator.pushNamed(context, '/do-not-disturb-screen');
                    } else {
                      showPremiumDialog(context, featureName: 'Cami Modu');
                    }
                  },
                );
              },
            ),

            SizedBox(height: 1.h),

            // Çocuk Modu (🔒 PREMIUM)
            FutureBuilder<bool>(
              future: _premiumService.canAccessFeature(PremiumFeature.kidsMode),
              builder: (context, snapshot) {
                final canAccess = snapshot.data ?? false;
                return _buildSettingsTile(
                  context: context,
                  icon: 'child_care',
                  title: 'Çocuk Modu',
                  subtitle: 'Çocuklar için eğlenceli namaz ve sure eğitimi',
                  isPremium: !canAccess,
                  onTap: () async {
                    if (canAccess) {
                      Navigator.pushNamed(context, '/kids-mode-screen');
                    } else {
                      showPremiumDialog(context, featureName: 'Çocuk Modu');
                    }
                  },
                );
              },
            ),

            SizedBox(height: 1.h),

            // Helal Gıda Kontrolü (🔒 PREMIUM)
            FutureBuilder<bool>(
              future: _premiumService.canAccessFeature(PremiumFeature.halalChecker),
              builder: (context, snapshot) {
                final canAccess = snapshot.data ?? false;
                return _buildSettingsTile(
                  context: context,
                  icon: 'qr_code_scanner',
                  title: 'Helal Gıda Kontrolü',
                  subtitle: 'Barkod tarayarak E-kodu ve içerik kontrolü',
                  isPremium: !canAccess,
                  onTap: () async {
                    if (canAccess) {
                      Navigator.pushNamed(context, '/halal-checker-screen');
                    } else {
                      showPremiumDialog(context, featureName: 'Helal Gıda Kontrolü');
                    }
                  },
                );
              },
            ),

            SizedBox(height: 1.h),

            // Hac ve Umre Rehberi
            _buildSettingsTile(
              context: context,
              icon: 'mosque',
              title: 'Hac ve Umre Rehberi',
              subtitle: 'Hac ve umre ibadetleri rehberi',
              onTap: _showHajjUmrahGuideSheet,
            ),

            SizedBox(height: 1.h),

            // Theme Settings
            _buildSettingsTile(
              context: context,
              icon: 'palette',
              title: 'Görünüm',
              subtitle: 'Tema ve renk ayarları',
              onTap: _showThemeSettings,
            ),

            SizedBox(height: 1.h),

            // About & Help
            _buildSettingsTile(
              context: context,
              icon: 'info',
              title: 'Hakkında ve Yardım',
              subtitle: 'Uygulama bilgisi ve destek',
              onTap: _showAboutDialog,
            ),

            SizedBox(height: 3.h),

            // App Version Footer
            Center(
              child: Text(
                'Mirac Prayer Assistant v1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
            
            SizedBox(height: 2.h),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdWidget(),
          CustomBottomBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    color: isPremium 
                        ? Colors.amber.shade100 
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomIconWidget(
                    iconName: icon,
                    color: isPremium 
                        ? Colors.amber.shade700 
                        : theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (isPremium) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.amber.shade400,
                                    Colors.orange.shade600,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.workspace_premium,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'PRO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 0.3.h),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: 'chevron_right',
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
