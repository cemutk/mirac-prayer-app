import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/prayer_tracking_data.dart';

/// Service for managing prayer tracking data
class PrayerTrackingService {
  static final PrayerTrackingService _instance = PrayerTrackingService._internal();
  factory PrayerTrackingService() => _instance;
  PrayerTrackingService._internal();

  static const String _recordsKey = 'prayer_tracking_records';
  static const String _streakKey = 'prayer_tracking_streak';
  static const String _lastCompleteKey = 'prayer_tracking_last_complete';

  /// Get today's date string
  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Get date string for a specific date
  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Load all records
  Future<Map<String, PrayerRecord>> loadAllRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString(_recordsKey);
    
    if (recordsJson == null) return {};
    
    try {
      final Map<String, dynamic> decoded = jsonDecode(recordsJson);
      return decoded.map((key, value) => MapEntry(
        key,
        PrayerRecord.fromJson(value as Map<String, dynamic>),
      ));
    } catch (e) {
      return {};
    }
  }

  /// Save all records
  Future<void> _saveAllRecords(Map<String, PrayerRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> encoded = records.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await prefs.setString(_recordsKey, jsonEncode(encoded));
  }

  /// Get today's record
  Future<PrayerRecord> getTodayRecord() async {
    final records = await loadAllRecords();
    final today = _getTodayString();
    return records[today] ?? PrayerRecord.empty(today);
  }

  /// Get record for a specific date
  Future<PrayerRecord> getRecordForDate(DateTime date) async {
    final records = await loadAllRecords();
    final dateStr = _getDateString(date);
    return records[dateStr] ?? PrayerRecord.empty(dateStr);
  }

  /// Toggle prayer completion
  Future<PrayerRecord> togglePrayer(String prayerName) async {
    final records = await loadAllRecords();
    final today = _getTodayString();
    
    final currentRecord = records[today] ?? PrayerRecord.empty(today);
    final currentStatus = currentRecord.prayers[prayerName] ?? false;
    final updatedRecord = currentRecord.copyWithPrayer(prayerName, !currentStatus);
    
    records[today] = updatedRecord;
    await _saveAllRecords(records);
    
    // Update streak if all prayers completed
    if (updatedRecord.isComplete) {
      await _updateStreak(today);
    }
    
    return updatedRecord;
  }

  /// Set prayer completion status
  Future<PrayerRecord> setPrayerStatus(String prayerName, bool completed) async {
    final records = await loadAllRecords();
    final today = _getTodayString();
    
    final currentRecord = records[today] ?? PrayerRecord.empty(today);
    final updatedRecord = currentRecord.copyWithPrayer(prayerName, completed);
    
    records[today] = updatedRecord;
    await _saveAllRecords(records);
    
    // Update streak if all prayers completed
    if (updatedRecord.isComplete) {
      await _updateStreak(today);
    }
    
    return updatedRecord;
  }

  /// Update streak count
  Future<void> _updateStreak(String todayStr) async {
    final prefs = await SharedPreferences.getInstance();
    final lastComplete = prefs.getString(_lastCompleteKey);
    
    if (lastComplete == null) {
      // First complete day
      await prefs.setInt(_streakKey, 1);
      await prefs.setString(_lastCompleteKey, todayStr);
      return;
    }
    
    // Parse dates
    final lastDate = DateTime.parse(lastComplete);
    final today = DateTime.parse(todayStr);
    final difference = today.difference(lastDate).inDays;
    
    if (difference == 0) {
      // Same day, no change
      return;
    } else if (difference == 1) {
      // Consecutive day, increase streak
      final currentStreak = prefs.getInt(_streakKey) ?? 0;
      await prefs.setInt(_streakKey, currentStreak + 1);
      await prefs.setString(_lastCompleteKey, todayStr);
    } else {
      // Streak broken, reset to 1
      await prefs.setInt(_streakKey, 1);
      await prefs.setString(_lastCompleteKey, todayStr);
    }
  }

  /// Get current streak
  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastComplete = prefs.getString(_lastCompleteKey);
    
    if (lastComplete == null) return 0;
    
    // Check if streak is still valid
    final lastDate = DateTime.parse(lastComplete);
    final today = DateTime.now();
    final todayStr = _getTodayString();
    final difference = DateTime.parse(todayStr).difference(lastDate).inDays;
    
    if (difference > 1) {
      // Streak broken
      return 0;
    }
    
    return prefs.getInt(_streakKey) ?? 0;
  }

  /// Get weekly statistics (last 7 days)
  Future<List<PrayerRecord>> getWeeklyRecords() async {
    final records = await loadAllRecords();
    final List<PrayerRecord> weeklyRecords = [];
    
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = _getDateString(date);
      weeklyRecords.add(records[dateStr] ?? PrayerRecord.empty(dateStr));
    }
    
    return weeklyRecords;
  }

  /// Get monthly statistics
  Future<Map<String, int>> getMonthlyStats() async {
    final records = await loadAllRecords();
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);
    
    int totalPrayers = 0;
    int completedPrayers = 0;
    int perfectDays = 0;
    
    for (int i = 0; i < now.day; i++) {
      final date = firstOfMonth.add(Duration(days: i));
      final dateStr = _getDateString(date);
      final record = records[dateStr];
      
      totalPrayers += 5;
      if (record != null) {
        completedPrayers += record.completedCount;
        if (record.isComplete) perfectDays++;
      }
    }
    
    return {
      'totalPrayers': totalPrayers,
      'completedPrayers': completedPrayers,
      'perfectDays': perfectDays,
      'daysInMonth': now.day,
    };
  }

  /// Get all-time statistics
  Future<Map<String, int>> getAllTimeStats() async {
    final records = await loadAllRecords();
    
    int totalPrayers = 0;
    int completedPrayers = 0;
    int perfectDays = 0;
    
    for (final record in records.values) {
      totalPrayers += 5;
      completedPrayers += record.completedCount;
      if (record.isComplete) perfectDays++;
    }
    
    return {
      'totalDays': records.length,
      'totalPrayers': totalPrayers,
      'completedPrayers': completedPrayers,
      'perfectDays': perfectDays,
    };
  }
}
