import 'dart:convert';

import 'package:flutter/services.dart';

import '../data/quran_data.dart' as embedded;

class QuranService {
  static final QuranService _instance = QuranService._internal();
  factory QuranService() => _instance;
  QuranService._internal();

  Map<int, dynamic>? _surahIndex;

  /// Attempt to load a full JSON dataset from `assets/data/quran_full.json`.
  /// If not present, fall back to embedded `quran_data.dart` list.
  Future<void> _ensureLoaded() async {
    if (_surahIndex != null) return;

    try {
      final data = await rootBundle.loadString('assets/data/quran_full.json');
      final parsed = json.decode(data) as Map<String, dynamic>;
      final List surahs = parsed['surahs'] ?? [];
      _surahIndex = {for (var s in surahs) s['number'] as int: s};
      return;
    } catch (_) {
      // asset not found or parse failed — fall back to embedded data
    }

    // Use embedded data from `lib/data/quran_data.dart`
    final List<Map<String, dynamic>> embeddedSurahs = embedded.QuranData.getAllSurahs();
    _surahIndex = {for (var s in embeddedSurahs) s['number'] as int: s};
  }

  Future<List<Map<String, dynamic>>> getSurahs() async {
    await _ensureLoaded();
    final list = _surahIndex!.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    list.sort((a, b) => (a['number'] as int).compareTo(b['number'] as int));
    return list;
  }

  Future<Map<String, dynamic>?> getSurah(int number) async {
    await _ensureLoaded();
    final surah = _surahIndex![number];
    if (surah == null) return null;
    return Map<String, dynamic>.from(surah as Map);
  }
}
