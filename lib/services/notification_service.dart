import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  // Notification sound preference key
  static const String _azanSoundEnabledKey = 'azan_sound_enabled';
  
  // Method channel for battery optimization
  static const MethodChannel _batteryChannel = MethodChannel('com.miracapp.namazvakti/battery');

  Future<void> initialize() async {
    // Timezone data
    tz.initializeTimeZones();

    // Android settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initializationSettings);
    
    // Create notification channel with custom sound
    await _createNotificationChannels();
  }
  
  /// Check if battery optimization is currently ignored
  Future<bool> isBatteryOptimizationIgnored() async {
    if (!Platform.isAndroid) return true;
    try {
      final result = await _batteryChannel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return result ?? false;
    } catch (e) {
      debugPrint('⚠️ [NotificationService] Could not check battery optimization: $e');
      return false;
    }
  }
  
  /// Request battery optimization exemption for reliable background notifications
  Future<bool> requestBatteryOptimizationExemption() async {
    if (!Platform.isAndroid) return true;
    try {
      await _batteryChannel.invokeMethod('requestIgnoreBatteryOptimization');
      debugPrint('✅ [NotificationService] Battery optimization exemption requested');
      return true;
    } catch (e) {
      debugPrint('⚠️ [NotificationService] Could not request battery optimization: $e');
      return false;
    }
  }
  
  /// Check if we should show battery optimization dialog (first time or not ignored)
  static const String _batteryDialogShownKey = 'battery_dialog_shown';
  
  Future<bool> shouldShowBatteryDialog() async {
    if (!Platform.isAndroid) return false;
    
    final prefs = await SharedPreferences.getInstance();
    final alreadyShown = prefs.getBool(_batteryDialogShownKey) ?? false;
    
    if (alreadyShown) {
      // Already shown once, check if still not ignored
      final isIgnored = await isBatteryOptimizationIgnored();
      return !isIgnored;
    }
    
    return true; // First time, show dialog
  }
  
  Future<void> markBatteryDialogShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_batteryDialogShownKey, true);
  }
  
  /// Creates notification channels for Android
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      // Prayer notification channel with azan sound
      const azanChannel = AndroidNotificationChannel(
        'prayer_azan_channel',
        'Namaz Vakti (Ezan Sesli)',
        description: 'Ezan sesiyle namaz vakti bildirimleri',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('azan_sound'),
        enableVibration: true,
        enableLights: true,
      );
      
      // Prayer notification channel without azan (default sound)
      const defaultChannel = AndroidNotificationChannel(
        'prayer_default_channel',
        'Namaz Vakti (Varsayılan Ses)',
        description: 'Varsayılan sesle namaz vakti bildirimleri',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );
      
      // Silent channel for non-prayer notifications
      const silentChannel = AndroidNotificationChannel(
        'general_channel',
        'Genel Bildirimler',
        description: 'Genel uygulama bildirimleri',
        importance: Importance.defaultImportance,
      );
      
      try {
        await androidPlugin.createNotificationChannel(azanChannel);
      } catch (e) {
        debugPrint('⚠️ Could not create azan channel: $e');
      }
      await androidPlugin.createNotificationChannel(defaultChannel);
      await androidPlugin.createNotificationChannel(silentChannel);
    }
  }
  
  /// Check if azan sound is enabled
  Future<bool> isAzanSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_azanSoundEnabledKey) ?? true; // Default enabled
  }
  
  /// Set azan sound preference
  Future<void> setAzanSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_azanSoundEnabledKey, enabled);
  }
  
  /// Check if a given date is during Ramadan
  /// Ramadan 2026: February 28 - March 29
  /// Ramadan 2027: February 17 - March 18
  /// Ramadan 2028: February 6 - March 7
  static bool isRamadan(DateTime date) {
    // Ramadan dates for upcoming years (approximate, may vary by 1-2 days)
    final ramadanPeriods = [
      // 2025 - Already passed (Feb 28 - Mar 29)
      {'start': DateTime(2025, 2, 28), 'end': DateTime(2025, 3, 30)},
      // 2026
      {'start': DateTime(2026, 2, 17), 'end': DateTime(2026, 3, 19)},
      // 2027
      {'start': DateTime(2027, 2, 6), 'end': DateTime(2027, 3, 8)},
      // 2028
      {'start': DateTime(2028, 1, 26), 'end': DateTime(2028, 2, 25)},
      // 2029
      {'start': DateTime(2029, 1, 14), 'end': DateTime(2029, 2, 13)},
    ];
    
    for (var period in ramadanPeriods) {
      if (date.isAfter(period['start']!.subtract(const Duration(days: 1))) && 
          date.isBefore(period['end']!.add(const Duration(days: 1)))) {
        return true;
      }
    }
    return false;
  }
  
  /// Check if a given date is Friday
  static bool isFriday(DateTime date) {
    return date.weekday == DateTime.friday;
  }
  
  /// Get beautiful notification messages for each prayer time
  /// Now supports Ramadan-specific messages and date awareness
  static Map<String, String> getPrayerNotificationMessage(String prayerName, String timeStr, {DateTime? scheduledDate}) {
    final date = scheduledDate ?? DateTime.now();
    final isRamadanPeriod = isRamadan(date);
    final isFridayToday = isFriday(date);
    
    // Ramadan-specific messages
    if (isRamadanPeriod) {
      final ramadanMessages = {
        'İmsak': {
          'title': '🌙 İmsak Vakti Girdi - Sahur Bitti',
          'body': 'Oruç tutma vakti başladı. Ramazan mübarek! 🤲',
        },
        'Güneş': {
          'title': '☀️ Güneş Vakti Girdi',
          'body': 'Oruçlu bir günün başlangıcı. Allah orucumuzu kabul etsin. 🌅',
        },
        'Öğle': {
          'title': '🕌 Öğle Vakti Girdi',
          'body': 'Öğle namazı vakti başladı. Oruçlarınız kabul olsun. 🤲',
        },
        'İkindi': {
          'title': '🕌 İkindi Vakti Girdi',
          'body': 'İkindi namazı vakti başladı. İftar yaklaşıyor... 🤲',
        },
        'Akşam': {
          'title': '🌇 Akşam Vakti - İftar Zamanı!',
          'body': 'Oruç açma vakti geldi. Afiyet olsun! 🤲🍽️',
        },
        'Yatsı': {
          'title': '🌙 Yatsı Vakti - Teravih Zamanı',
          'body': 'Yatsı ve teravih namazı vakti başladı. 🤲',
        },
      };
      
      String matchedPrayer = prayerName;
      if (prayerName.toLowerCase().contains('sabah') || prayerName.toLowerCase().contains('fecir')) {
        matchedPrayer = 'İmsak';
      }
      
      final messages = ramadanMessages[matchedPrayer];
      if (messages != null) {
        return messages;
      }
    }
    
    // Friday special message for Öğle (Cuma namazı)
    if (isFridayToday && prayerName == 'Öğle') {
      return {
        'title': '🕌 Cuma Namazı Vakti Girdi',
        'body': 'Hayırlı Cumalar! Cuma namazına hazırlanın. 🤲',
      };
    }
    
    // Normal day messages
    final prayerMessages = {
      'İmsak': {
        'title': '🌙 İmsak Vakti Girdi',
        'body': 'İmsak vakti başladı. Sabah namazına hazırlanın. 🤲',
      },
      'Güneş': {
        'title': '☀️ Güneş Vakti Girdi',
        'body': 'Güneş doğdu, sabah namazının kazası için ideal vakit. 🌅',
      },
      'Öğle': {
        'title': '🕌 Öğle Vakti Girdi',
        'body': 'Öğle namazı vakti başladı. Allah dualarınızı kabul etsin. 🤲',
      },
      'İkindi': {
        'title': '🕌 İkindi Vakti Girdi',
        'body': 'İkindi namazı vakti başladı. Allah dualarınızı kabul etsin. 🤲',
      },
      'Akşam': {
        'title': '🌇 Akşam Vakti Girdi',
        'body': 'Akşam namazı vakti başladı. Allah dualarınızı kabul etsin. 🤲',
      },
      'Yatsı': {
        'title': '🌙 Yatsı Vakti Girdi',
        'body': 'Yatsı namazı vakti başladı. Allah dualarınızı kabul etsin. 🤲',
      },
    };
    
    // Find matching prayer (handle variations like "Sabah" vs "İmsak")
    String matchedPrayer = prayerName;
    if (prayerName.toLowerCase().contains('sabah') || prayerName.toLowerCase().contains('fecir')) {
      matchedPrayer = 'İmsak';
    }
    
    final messages = prayerMessages[matchedPrayer];
    if (messages != null) {
      return messages;
    }
    
    // Default fallback message
    return {
      'title': '🕌 $prayerName Vakti Girdi',
      'body': 'Namaz vakti başladı. Allah dualarınızı kabul etsin. 🤲',
    };
  }
  
  /// Daily engagement notification messages - morning and evening
  /// Returns different messages based on day of week for variety
  static Map<String, Map<String, String>> getDailyEngagementMessages(int dayOfWeek) {
    // Sabah bildirimleri (09:00)
    final morningMessages = {
      DateTime.monday: {
        'title': '🌅 Hayırlı Pazartesiler!',
        'body': 'Yeni bir haftaya bismillah ile başlayın. "Rabbim, işlerimi kolaylaştır" demeyi unutmayın! 🤲',
      },
      DateTime.tuesday: {
        'title': '📿 Salı Sabahı Tesbih Hatırlatması',
        'body': '33 Sübhanallah, 33 Elhamdülillah, 33 Allahu Ekber... Günü zikirle aydınlatın! ✨',
      },
      DateTime.wednesday: {
        'title': '📖 Çarşamba Kuran Vakti',
        'body': 'Bugün en az 1 sayfa Kuran okumaya ne dersiniz? Her harf için 10 sevap kazanın! 📚',
      },
      DateTime.thursday: {
        'title': '🤲 Perşembe Dua Günü',
        'body': 'Yarın Cuma! Bugün oruç tutmak sünnettir. Dua listenizi hazırlayın! 📝',
      },
      DateTime.friday: {
        'title': '🕌 Mübarek Cuma Sabahı!',
        'body': 'Kehf suresini okuyun, bol salavat getirin! "Allahümme salli ala Muhammed" ﷺ',
      },
      DateTime.saturday: {
        'title': '👨‍👩‍👧‍👦 Cumartesi Aile Günü',
        'body': 'Bugün ailenizle birlikte ibadet etmeye ne dersiniz? Beraber yapılan dua kabul olur! 🏠',
      },
      DateTime.sunday: {
        'title': '🌸 Pazar Şükür Günü',
        'body': 'Geçen haftanın nimetlerini düşünün. "Elhamdülillah" demenin tam zamanı! 🙏',
      },
    };
    
    // Akşam bildirimleri (20:00)
    final eveningMessages = {
      DateTime.monday: {
        'title': '🌙 Pazartesi Akşam Muhasebes',
        'body': 'Günü değerlendirin: Bugün kaç vakit namaz kıldınız? Yarın daha iyisini hedefleyin! 📊',
      },
      DateTime.tuesday: {
        'title': '🛡️ Salı Gecesi Korunma',
        'body': 'Yatmadan önce 3 İhlas, 1 Felak, 1 Nas okuyun. Şerlerden korunun! 🤲',
      },
      DateTime.wednesday: {
        'title': '⭐ Çarşamba Gecesi Tefekkür',
        'body': 'Bugün neler için şükredeceğiz? 3 nimet sayın ve "Elhamdülillah" deyin! 💭',
      },
      DateTime.thursday: {
        'title': '🌙 Mübarek Cuma Gecesi!',
        'body': 'Bu gece yapılan dualar kabul olur! Sevdikleriniz için de dua etmeyi unutmayın. 🤲',
      },
      DateTime.friday: {
        'title': '📿 Cuma Akşamı Salavat',
        'body': 'Bugün kaç salavat getirdiniz? Hz. Peygamber (s.a.v): "Kim bana salavat getirirse..." ﷺ',
      },
      DateTime.saturday: {
        'title': '🕌 Cumartesi Gece İbadeti',
        'body': 'Teheccüd namazı için niyet edin! Gece yarısı kalkan kulun duası reddedilmez. 🌙',
      },
      DateTime.sunday: {
        'title': '📝 Pazar Haftalık Planlama',
        'body': 'Yeni hafta için hedef belirleyin: Kaç sayfa Kuran? Kaç kaza namazı? Hangi güzel amel? ✍️',
      },
    };
    
    return {
      'morning': morningMessages[dayOfWeek] ?? morningMessages[DateTime.monday]!,
      'evening': eveningMessages[dayOfWeek] ?? eveningMessages[DateTime.monday]!,
    };
  }
  
  /// Schedule daily engagement notifications for the next 7 days
  Future<void> scheduleDailyEngagementNotifications() async {
    final location = tz.local;
    final nowTz = tz.TZDateTime.now(location);
    
    debugPrint('🔔 [NotificationService] Scheduling daily engagement notifications...');
    
    int scheduledCount = 0;
    
    for (int i = 0; i < 7; i++) {
      final targetDate = DateTime(nowTz.year, nowTz.month, nowTz.day).add(Duration(days: i));
      final dayOfWeek = targetDate.weekday;
      final messages = getDailyEngagementMessages(dayOfWeek);
      
      // Morning notification at 09:00
      final morningTz = tz.TZDateTime(location, targetDate.year, targetDate.month, targetDate.day, 9, 0);
      if (morningTz.isAfter(nowTz)) {
        final morningId = 3000 + (i * 2); // IDs: 3000, 3002, 3004, ...
        await schedulePrayerNotificationAtTz(
          id: morningId,
          title: messages['morning']!['title']!,
          body: messages['morning']!['body']!,
          scheduledTz: morningTz,
          useDefaultSound: true, // Use default sound, not azan
        );
        debugPrint('🔔 [Engagement] Morning notification (ID: $morningId) scheduled for $morningTz');
        scheduledCount++;
      }
      
      // Evening notification at 20:00
      final eveningTz = tz.TZDateTime(location, targetDate.year, targetDate.month, targetDate.day, 20, 0);
      if (eveningTz.isAfter(nowTz)) {
        final eveningId = 3001 + (i * 2); // IDs: 3001, 3003, 3005, ...
        await schedulePrayerNotificationAtTz(
          id: eveningId,
          title: messages['evening']!['title']!,
          body: messages['evening']!['body']!,
          scheduledTz: eveningTz,
          useDefaultSound: true, // Use default sound, not azan
        );
        debugPrint('🔔 [Engagement] Evening notification (ID: $eveningId) scheduled for $eveningTz');
        scheduledCount++;
      }
    }
    
    debugPrint('✅ [NotificationService] $scheduledCount daily engagement notifications scheduled');
  }
  
  /// Schedule Friday "Hayırlı Cumalar" notification
  Future<void> scheduleFridayNotification({
    required int id,
    required DateTime fridayDate,
  }) async {
    // Schedule for 08:00 on Friday morning
    final location = tz.local;
    final scheduledTz = tz.TZDateTime(location, fridayDate.year, fridayDate.month, fridayDate.day, 8, 0);
    
    final nowTz = tz.TZDateTime.now(location);
    if (scheduledTz.isBefore(nowTz)) return;
    
    await schedulePrayerNotificationAtTz(
      id: id,
      title: '🕌 Hayırlı Cumalar!',
      body: 'Bugün mübarek Cuma günü. Cuma namazını unutmayın! 🤲',
      scheduledTz: scheduledTz,
    );
    debugPrint('✅ [NotificationService] Friday notification scheduled for $scheduledTz');
  }

  Future<void> requestPermissions() async {
    final plugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (plugin != null) {
      await plugin.requestNotificationsPermission();
    }

    final iosPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (scheduledTime.isBefore(DateTime.now())) {
      return; // Do not schedule for past times
    }

    // Try scheduling with custom sound first. If the platform throws an
    // invalid_sound PlatformException (missing resource), retry without sound.
    try {
      final androidDetails = AndroidNotificationDetails(
        'prayer_time_channel',
        'Namaz Vakti Bildirimleri',
        channelDescription: 'Namaz vakitleri için bildirim kanalı.',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('azan_sound'), // Custom sound
      );

      final iosDetails = DarwinNotificationDetails(
        sound: 'azan_sound.aiff', // Custom sound
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on Exception catch (e) {
      // If the platform reports invalid sound/resource, retry without custom sound
      final msg = e.toString().toLowerCase();
      if (msg.contains('invalid') || msg.contains('sound') || msg.contains('no such file')) {
        final androidDetailsNoSound = AndroidNotificationDetails(
          'prayer_time_channel',
          'Namaz Vakti Bildirimleri',
          channelDescription: 'Namaz vakitleri için bildirim kanalı.',
          importance: Importance.max,
          priority: Priority.high,
        );

        final iosDetailsNoSound = DarwinNotificationDetails();

        final notificationDetailsNoSound = NotificationDetails(
          android: androidDetailsNoSound,
          iOS: iosDetailsNoSound,
        );

        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledTime, tz.local),
          notificationDetailsNoSound,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } else {
        rethrow;
      }
    }
  }

  /// Schedule using a tz-aware DateTime (preferred for timezone correctness)
  Future<void> schedulePrayerNotificationAtTz({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTz,
    bool useDefaultSound = false, // If true, always use default sound (for engagement notifications)
  }) async {
    final nowTz = tz.TZDateTime.now(scheduledTz.location);
    if (scheduledTz.isBefore(nowTz)) {
      debugPrint('⚠️ [NotificationService] Skipping past notification ID $id: $scheduledTz is before $nowTz');
      return;
    }
    
    debugPrint('📅 [NotificationService] Scheduling notification ID $id for $scheduledTz');

    // Check if azan sound is enabled (but not for engagement notifications)
    final useAzanSound = useDefaultSound ? false : await isAzanSoundEnabled();
    
    try {
      AndroidNotificationDetails androidDetails;
      DarwinNotificationDetails iosDetails;
      
      if (useAzanSound) {
        // Use azan sound channel
        androidDetails = const AndroidNotificationDetails(
          'prayer_azan_channel',
          'Namaz Vakti (Ezan Sesli)',
          channelDescription: 'Ezan sesiyle namaz vakti bildirimleri',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('azan_sound'),
          playSound: true,
          enableVibration: true,
          enableLights: true,
          fullScreenIntent: true, // Wake up screen
          category: AndroidNotificationCategory.event,
          visibility: NotificationVisibility.public,
        );
        
        iosDetails = const DarwinNotificationDetails(
          sound: 'azan_sound.aiff',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        );
      } else {
        // Use default sound channel
        androidDetails = const AndroidNotificationDetails(
          'prayer_default_channel',
          'Namaz Vakti (Varsayılan Ses)',
          channelDescription: 'Varsayılan sesle namaz vakti bildirimleri',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.event,
          visibility: NotificationVisibility.public,
        );
        
        iosDetails = const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        );
      }

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTz,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('✅ [NotificationService] Successfully scheduled notification ID $id ${useAzanSound ? "(with azan)" : "(default sound)"}');
    } on Exception catch (e) {
      debugPrint('⚠️ [NotificationService] Exception scheduling ID $id: $e');
      final msg = e.toString().toLowerCase();
      if (msg.contains('invalid') || msg.contains('sound') || msg.contains('no such file')) {
        // Fallback to default sound if azan sound file is missing
        final androidDetailsNoSound = const AndroidNotificationDetails(
          'prayer_default_channel',
          'Namaz Vakti (Varsayılan Ses)',
          channelDescription: 'Varsayılan sesle namaz vakti bildirimleri',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
        );

        const iosDetailsNoSound = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        final notificationDetailsNoSound = NotificationDetails(
          android: androidDetailsNoSound,
          iOS: iosDetailsNoSound,
        );

        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTz,
          notificationDetailsNoSound,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint('✅ [NotificationService] Successfully scheduled notification ID $id (fallback - default sound)');
      } else {
        debugPrint('❌ [NotificationService] Failed to schedule ID $id: $e');
        rethrow;
      }
    }
  }

  Future<void> cancelAllNotifications() async {
    debugPrint('🗑️ [NotificationService] Cancelling all notifications');
    await _notificationsPlugin.cancelAll();
  }
  
  /// Cancel a specific notification by ID
  Future<void> cancelNotification(int id) async {
    debugPrint('🗑️ [NotificationService] Cancelling notification ID: $id');
    await _notificationsPlugin.cancel(id);
  }

  /// Shows an immediate notification (useful for testing permissions and UI)
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'prayer_time_channel',
        'Namaz Vakti Bildirimleri',
        channelDescription: 'Namaz vakitleri için bildirim kanalı.',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(id, title, body, details);
    } catch (e) {
      // Log but don't throw — used for debugging from UI
      print('Error showing immediate notification: $e');
    }
  }

  /// Returns a list of all pending (scheduled) notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  /// Prints all pending notifications to debug console
  Future<void> debugPrintPendingNotifications() async {
    final pending = await _notificationsPlugin.pendingNotificationRequests();
    debugPrint('📋 [NotificationService] === PENDING NOTIFICATIONS (${pending.length}) ===');
    for (var n in pending) {
      debugPrint('  ID: ${n.id} | Title: ${n.title} | Body: ${n.body}');
    }
    debugPrint('📋 [NotificationService] === END ===');
  }
}
