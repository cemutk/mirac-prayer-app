import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PrayerTimesService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.aladhan.com/v1',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  /// Fetches prayer times with dynamic calculation method from settings
  Future<Map<String, dynamic>?> fetchPrayerTimes({
    required String city,
    required String district,
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();

      // CRITICAL: Get calculation method from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final methodId =
          prefs.getInt('calculationMethodId') ?? 13; // Default Diyanet

      final response = await _dio.get(
        '/timingsByCity',
        queryParameters: {
          'city': city,
          'country': 'Turkey',
          'method': methodId, // Use dynamic method from settings
          'date': '${targetDate.day}-${targetDate.month}-${targetDate.year}',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data['code'] == 200 && data['data'] != null) {
          final timings = data['data']['timings'];
          final dateInfo = data['data']['date'];
          
          // Extract Hijri date info from API
          final hijriData = dateInfo['hijri'];
          final hijriDay = hijriData?['day'] ?? '';
          final hijriMonthAr = hijriData?['month']?['ar'] ?? '';
          final hijriMonthEn = hijriData?['month']?['en'] ?? '';
          final hijriYear = hijriData?['year'] ?? '';
          
          // Map Arabic/English month names to Turkish
          final hijriMonthTr = _getHijriMonthTurkish(hijriMonthEn);

          final prayerTimes = {
            'city': city,
            'district': district,
            'date': targetDate.toIso8601String(),
            'readable_date': dateInfo['readable'] ?? '',
            'timezone': data['data']['meta']['timezone'] ?? 'Europe/Istanbul',
            'method_id': methodId, // Store which method was used
            'hijri_date': '$hijriDay $hijriMonthTr $hijriYear', // Turkish Hijri date
            'hijri_day': hijriDay,
            'hijri_month': hijriMonthTr,
            'hijri_month_ar': hijriMonthAr,
            'hijri_year': hijriYear,
            'times': [
              {
                'id': 1,
                'name': 'İmsak',
                'time': _formatTime(timings['Fajr']),
                'isPast': false,
                'isCurrent': false,
              },
              {
                'id': 2,
                'name': 'Güneş',
                'time': _formatTime(timings['Sunrise']),
                'isPast': false,
                'isCurrent': false,
              },
              {
                'id': 3,
                'name': 'Öğle',
                'time': _formatTime(timings['Dhuhr']),
                'isPast': false,
                'isCurrent': false,
              },
              {
                'id': 4,
                'name': 'İkindi',
                'time': _formatTime(timings['Asr']),
                'isPast': false,
                'isCurrent': false,
              },
              {
                'id': 5,
                'name': 'Akşam',
                'time': _formatTime(timings['Maghrib']),
                'isPast': false,
                'isCurrent': false,
              },
              {
                'id': 6,
                'name': 'Yatsı',
                'time': _formatTime(timings['Isha']),
                'isPast': false,
                'isCurrent': false,
              },
            ],
          };

          await _cachePrayerTimes(city, district, prayerTimes);
          return prayerTimes;
        }
      }

      return await _getCachedPrayerTimes(city, district);
    } on DioException catch (e) {
      print('Network error fetching prayer times: ${e.message}');
      return await _getCachedPrayerTimes(city, district);
    } catch (e) {
      print('Error fetching prayer times: $e');
      return await _getCachedPrayerTimes(city, district);
    }
  }

  /// Formats time string to HH:mm format
  /// Removes timezone suffixes and extra information
  String _formatTime(String time) {
    try {
      // Aladhan API returns time in format "HH:mm (TIMEZONE)"
      // We need to extract just the HH:mm part
      final timeOnly = time.split(' ')[0].trim();
      return timeOnly;
    } catch (e) {
      return '00:00';
    }
  }

  /// Converts English Hijri month name to Turkish
  String _getHijriMonthTurkish(String englishMonth) {
    // Normalize input: lowercase, trim, AND remove diacritics/accents
    final normalized = _removeDiacritics(englishMonth.toLowerCase().trim());
    
    // Fallback patterns based on common substrings - most reliable approach
    if (normalized.contains('muharram')) return 'Muharrem';
    if (normalized.contains('safar')) return 'Safer';
    
    // Rabi months
    if (normalized.contains('rabi')) {
      if (normalized.contains('awwal') || normalized.contains('ula') || normalized.contains(' i') || normalized.endsWith(' i')) {
        return 'Rebiülevvel';
      }
      if (normalized.contains('thani') || normalized.contains('akhir') || normalized.contains(' ii') || normalized.endsWith(' ii')) {
        return 'Rebiülahir';
      }
      return 'Rebiülevvel';
    }
    
    // Jumada months
    if (normalized.contains('jumad') || normalized.contains('jamad')) {
      if (normalized.contains('akhir') || normalized.contains('thani') || normalized.contains(' ii') || normalized.endsWith(' ii')) {
        return 'Cemaziyelahir';
      }
      if (normalized.contains('awwal') || normalized.contains('ula') || normalized.contains(' i') || normalized.endsWith(' i')) {
        return 'Cemaziyelevvel';
      }
      return 'Cemaziyelevvel';
    }
    
    if (normalized.contains('rajab')) return 'Recep';
    if (normalized.contains('shaban') || normalized.contains('sha\'ban')) return 'Şaban';
    if (normalized.contains('ramad') || normalized.contains('ramaz')) return 'Ramazan';
    if (normalized.contains('shawwal')) return 'Şevval';
    if (normalized.contains('qadah') || normalized.contains('qa\'dah') || normalized.contains('qidah')) return 'Zilkade';
    if (normalized.contains('hijjah') || normalized.contains('hijja')) return 'Zilhicce';
    
    // Return original if no match found
    return englishMonth;
  }
  
  /// Remove diacritics/accents from a string (ā -> a, á -> a, etc.)
  String _removeDiacritics(String str) {
    const diacritics = 'àáâãäåāăąèéêëēĕėęěìíîïīĭįıòóôõöøōŏőùúûüūŭůűųýÿỳñ';
    const replacements = 'aaaaaaaaaeeeeeeeeeiiiiiiiiooooooooouuuuuuuuuyyyn';
    
    String result = str;
    for (int i = 0; i < diacritics.length; i++) {
      result = result.replaceAll(diacritics[i], replacements[i]);
    }
    return result;
  }

  /// Caches prayer times locally for offline access
  Future<void> _cachePrayerTimes(
    String city,
    String district,
    Map<String, dynamic> prayerTimes,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'prayer_times_${city}_${district}';
      await prefs.setString(cacheKey, json.encode(prayerTimes));
    } catch (e) {
      print('Error caching prayer times: $e');
    }
  }

  /// Retrieves cached prayer times for offline access
  Future<Map<String, dynamic>?> _getCachedPrayerTimes(
    String city,
    String district,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'prayer_times_${city}_${district}';
      final cachedData = prefs.getString(cacheKey);

      if (cachedData != null) {
        final data = json.decode(cachedData) as Map<String, dynamic>;
        
        // Fix: Always ensure hijri_date is in Turkish
        // This handles old cached data that might have English month names
        if (data['hijri_date'] != null) {
          final hijriDate = data['hijri_date'] as String;
          // Check if it contains English month names and convert
          final parts = hijriDate.split(' ');
          if (parts.length >= 3) {
            final day = parts[0];
            final month = parts.sublist(1, parts.length - 1).join(' ');
            final year = parts.last;
            final turkishMonth = _getHijriMonthTurkish(month);
            data['hijri_date'] = '$day $turkishMonth $year';
            data['hijri_month'] = turkishMonth;
          }
        }
        
        return data;
      }

      return null;
    } catch (e) {
      print('Error retrieving cached prayer times: $e');
      return null;
    }
  }

  /// Gets cached prayer times without fetching from API
  Future<Map<String, dynamic>?> getCachedPrayerTimes(
    String city,
    String district,
  ) async {
    return await _getCachedPrayerTimes(city, district);
  }

  /// Clears all cached prayer times
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (var key in keys) {
        if (key.startsWith('prayer_times_')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Error clearing prayer times cache: $e');
    }
  }
}
