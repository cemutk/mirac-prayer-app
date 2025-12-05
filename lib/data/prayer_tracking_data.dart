/// Prayer Tracking Data Models and Storage
/// Manages daily prayer completion records

class PrayerRecord {
  final String date; // Format: yyyy-MM-dd
  final Map<String, bool> prayers; // {Sabah: true, Öğle: false, ...}
  final String? note;

  PrayerRecord({
    required this.date,
    required this.prayers,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'prayers': prayers,
    'note': note,
  };

  factory PrayerRecord.fromJson(Map<String, dynamic> json) => PrayerRecord(
    date: json['date'] as String,
    prayers: Map<String, bool>.from(json['prayers'] as Map),
    note: json['note'] as String?,
  );

  /// Create empty record for a date
  factory PrayerRecord.empty(String date) => PrayerRecord(
    date: date,
    prayers: {
      'Sabah': false,
      'Öğle': false,
      'İkindi': false,
      'Akşam': false,
      'Yatsı': false,
    },
  );

  /// Count completed prayers
  int get completedCount => prayers.values.where((v) => v).length;
  
  /// Check if all prayers are completed
  bool get isComplete => completedCount == 5;
  
  /// Get completion percentage
  double get completionPercentage => completedCount / 5.0;

  /// Copy with updated prayer
  PrayerRecord copyWithPrayer(String prayerName, bool completed) {
    final newPrayers = Map<String, bool>.from(prayers);
    newPrayers[prayerName] = completed;
    return PrayerRecord(
      date: date,
      prayers: newPrayers,
      note: note,
    );
  }
}

/// Prayer names in Turkish
const List<String> prayerNames = [
  'Sabah',
  'Öğle',
  'İkindi',
  'Akşam',
  'Yatsı',
];

/// Prayer icons
const Map<String, String> prayerIcons = {
  'Sabah': '🌅',
  'Öğle': '☀️',
  'İkindi': '🌤️',
  'Akşam': '🌅',
  'Yatsı': '🌙',
};

/// Motivational messages based on completion
List<String> getMotivationalMessage(int completedToday, int streak) {
  if (completedToday == 5) {
    return ['Maşallah! 🎉', 'Bugün tüm namazlarını kıldın!'];
  } else if (completedToday >= 3) {
    return ['Harika gidiyorsun! 💪', '${5 - completedToday} namaz kaldı.'];
  } else if (completedToday >= 1) {
    return ['Devam et! 🌟', 'Her namaz bir adım.'];
  } else {
    return ['Haydi başla! 🕌', 'Bugün için henüz namaz kaydın yok.'];
  }
}
