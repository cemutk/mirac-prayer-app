import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Çocuk profili
class KidsProfile {
  final String id;
  final String name;
  final int age;
  final String avatarEmoji;
  final DateTime createdAt;
  int totalPoints;
  int level;
  List<String> earnedBadges;
  Map<String, bool> completedLessons;
  Map<String, int> memorizedSurahs; // surah id -> progress (0-100)
  int prayerStreak;
  DateTime? lastPrayerDate;

  KidsProfile({
    required this.id,
    required this.name,
    required this.age,
    this.avatarEmoji = '👦',
    required this.createdAt,
    this.totalPoints = 0,
    this.level = 1,
    List<String>? earnedBadges,
    Map<String, bool>? completedLessons,
    Map<String, int>? memorizedSurahs,
    this.prayerStreak = 0,
    this.lastPrayerDate,
  })  : earnedBadges = earnedBadges ?? [],
        completedLessons = completedLessons ?? {},
        memorizedSurahs = memorizedSurahs ?? {};

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'avatarEmoji': avatarEmoji,
        'createdAt': createdAt.toIso8601String(),
        'totalPoints': totalPoints,
        'level': level,
        'earnedBadges': earnedBadges,
        'completedLessons': completedLessons,
        'memorizedSurahs': memorizedSurahs,
        'prayerStreak': prayerStreak,
        'lastPrayerDate': lastPrayerDate?.toIso8601String(),
      };

  factory KidsProfile.fromJson(Map<String, dynamic> json) => KidsProfile(
        id: json['id'],
        name: json['name'],
        age: json['age'],
        avatarEmoji: json['avatarEmoji'] ?? '👦',
        createdAt: DateTime.parse(json['createdAt']),
        totalPoints: json['totalPoints'] ?? 0,
        level: json['level'] ?? 1,
        earnedBadges: List<String>.from(json['earnedBadges'] ?? []),
        completedLessons: Map<String, bool>.from(json['completedLessons'] ?? {}),
        memorizedSurahs: Map<String, int>.from(json['memorizedSurahs'] ?? {}),
        prayerStreak: json['prayerStreak'] ?? 0,
        lastPrayerDate: json['lastPrayerDate'] != null
            ? DateTime.parse(json['lastPrayerDate'])
            : null,
      );
}

/// Rozet tanımı
class KidsBadge {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final Color color;
  final int requiredPoints;
  final String? requiredAction;

  const KidsBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.color,
    this.requiredPoints = 0,
    this.requiredAction,
  });
}

/// Ders tanımı
class KidsLesson {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String category; // 'abdest', 'namaz', 'sure', 'dua'
  final int points;
  final List<KidsLessonStep> steps;
  final int order;

  const KidsLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.category,
    required this.points,
    required this.steps,
    this.order = 0,
  });
}

/// Ders adımı
class KidsLessonStep {
  final String title;
  final String content;
  final String? imageEmoji;
  final String? animation;

  const KidsLessonStep({
    required this.title,
    required this.content,
    this.imageEmoji,
    this.animation,
  });
}

/// Çocuk modu servisi
class KidsModeService extends ChangeNotifier {
  static final KidsModeService _instance = KidsModeService._internal();
  factory KidsModeService() => _instance;
  KidsModeService._internal();

  SharedPreferences? _prefs;
  List<KidsProfile> _profiles = [];
  KidsProfile? _activeProfile;
  bool _isKidsModeEnabled = false;

  // Getters
  List<KidsProfile> get profiles => _profiles;
  KidsProfile? get activeProfile => _activeProfile;
  bool get isKidsModeEnabled => _isKidsModeEnabled;
  bool get hasProfiles => _profiles.isNotEmpty;

  // Tüm rozetler
  static const List<KidsBadge> allBadges = [
    // Başlangıç Rozetleri
    KidsBadge(
      id: 'first_step',
      name: 'İlk Adım',
      description: 'İlk dersini tamamladın!',
      emoji: '🌟',
      color: Colors.amber,
      requiredAction: 'complete_first_lesson',
    ),
    KidsBadge(
      id: 'abdest_master',
      name: 'Abdest Ustası',
      description: 'Tüm abdest derslerini tamamladın!',
      emoji: '💧',
      color: Colors.blue,
      requiredAction: 'complete_all_abdest',
    ),
    KidsBadge(
      id: 'namaz_hero',
      name: 'Namaz Kahramanı',
      description: 'Tüm namaz derslerini tamamladın!',
      emoji: '🕌',
      color: Colors.green,
      requiredAction: 'complete_all_namaz',
    ),
    KidsBadge(
      id: 'hafiz_yildizi',
      name: 'Hafız Yıldızı',
      description: 'İlk sureni ezberledin!',
      emoji: '⭐',
      color: Colors.purple,
      requiredAction: 'memorize_first_surah',
    ),
    KidsBadge(
      id: 'super_hafiz',
      name: 'Süper Hafız',
      description: '5 sure ezberledin!',
      emoji: '🏆',
      color: Colors.orange,
      requiredAction: 'memorize_5_surahs',
    ),
    // Streak Rozetleri
    KidsBadge(
      id: 'streak_3',
      name: '3 Gün Şampiyonu',
      description: '3 gün üst üste namaz kıldın!',
      emoji: '🔥',
      color: Colors.red,
      requiredAction: 'streak_3',
    ),
    KidsBadge(
      id: 'streak_7',
      name: 'Hafta Yıldızı',
      description: '7 gün üst üste namaz kıldın!',
      emoji: '💪',
      color: Colors.indigo,
      requiredAction: 'streak_7',
    ),
    KidsBadge(
      id: 'streak_30',
      name: 'Ay Şampiyonu',
      description: '30 gün üst üste namaz kıldın!',
      emoji: '👑',
      color: Colors.amber,
      requiredAction: 'streak_30',
    ),
    // Puan Rozetleri
    KidsBadge(
      id: 'points_100',
      name: 'Yüz Puan',
      description: '100 puan topladın!',
      emoji: '💯',
      color: Colors.teal,
      requiredPoints: 100,
    ),
    KidsBadge(
      id: 'points_500',
      name: 'Beş Yüz',
      description: '500 puan topladın!',
      emoji: '🎯',
      color: Colors.pink,
      requiredPoints: 500,
    ),
    KidsBadge(
      id: 'points_1000',
      name: 'Bin Puan Ustası',
      description: '1000 puan topladın!',
      emoji: '🎖️',
      color: Colors.deepPurple,
      requiredPoints: 1000,
    ),
  ];

  // Abdest dersleri
  static final List<KidsLesson> abdestLessons = [
    KidsLesson(
      id: 'abdest_intro',
      title: 'Abdest Nedir?',
      description: 'Abdestin ne olduğunu öğrenelim',
      emoji: '💧',
      category: 'abdest',
      points: 10,
      order: 1,
      steps: [
        KidsLessonStep(
          title: 'Merhaba Küçük Müslüman! 🌟',
          content: 'Bugün abdest almayı öğreneceğiz!\n\nAbdest, namaz kılmadan önce yaptığımız temizliktir. Allah\'a ibadet etmeden önce tertemiz olmalıyız!',
          imageEmoji: '🚿',
        ),
        KidsLessonStep(
          title: 'Neden Abdest Alırız?',
          content: 'Abdest almak bizi hem dıştan hem içten temizler.\n\nTemiz bir şekilde Allah\'ın huzuruna çıkarız. Abdest aynı zamanda günahlarımızı da temizler!',
          imageEmoji: '✨',
        ),
      ],
    ),
    KidsLesson(
      id: 'abdest_niyet',
      title: 'Niyet Etme',
      description: 'Abdeste nasıl niyet edilir?',
      emoji: '❤️',
      category: 'abdest',
      points: 10,
      order: 2,
      steps: [
        KidsLessonStep(
          title: 'Niyet Ne Demek?',
          content: 'Niyet, kalbimizle "Abdest almaya niyet ettim" demektir.\n\nAllah kalbimizden geçeni bilir, o yüzden içimizden niyet etmemiz yeterlidir.',
          imageEmoji: '💭',
        ),
        KidsLessonStep(
          title: 'Besmele Çekelim',
          content: 'Abdeste başlarken "Bismillahirrahmanirrahim" deriz.\n\nBu "Rahman ve Rahim olan Allah\'ın adıyla" demektir.',
          imageEmoji: '🤲',
        ),
      ],
    ),
    KidsLesson(
      id: 'abdest_eller',
      title: 'Elleri Yıkama',
      description: 'Elleri nasıl yıkarız?',
      emoji: '🙌',
      category: 'abdest',
      points: 15,
      order: 3,
      steps: [
        KidsLessonStep(
          title: 'Eller Önce! 👋',
          content: 'Önce ellerimizi bileklerimize kadar 3 kez yıkarız.\n\nParmak aralarını da unutmayalım!',
          imageEmoji: '🙌',
        ),
        KidsLessonStep(
          title: 'Nasıl Yıkarız?',
          content: '1. Suyu aç\n2. Ellerini ıslat\n3. Sabunla iyice ovala\n4. Parmak aralarını temizle\n5. 3 kez tekrarla',
          imageEmoji: '💦',
        ),
      ],
    ),
    KidsLesson(
      id: 'abdest_agiz_burun',
      title: 'Ağız ve Burun',
      description: 'Ağız ve burnu temizleme',
      emoji: '👃',
      category: 'abdest',
      points: 15,
      order: 4,
      steps: [
        KidsLessonStep(
          title: 'Mazmaza - Ağzı Çalkalama',
          content: 'Sağ elimizle ağzımıza su alırız.\n\nSuyu ağzımızda çalkalayıp tükürürüz. Bunu 3 kez yaparız.',
          imageEmoji: '👄',
        ),
        KidsLessonStep(
          title: 'İstinşak - Burna Su Verme',
          content: 'Sağ elimizle burnumuza su çekeriz.\n\nSol elimizle sümkürürüz. Bunu da 3 kez yaparız.',
          imageEmoji: '👃',
        ),
      ],
    ),
    KidsLesson(
      id: 'abdest_yuz',
      title: 'Yüzü Yıkama',
      description: 'Yüzümüzü nasıl yıkarız?',
      emoji: '😊',
      category: 'abdest',
      points: 15,
      order: 5,
      steps: [
        KidsLessonStep(
          title: 'Yüzümüzü Yıkayalım',
          content: 'Yüzümüzü alından çene altına, bir kulaktan diğer kulağa kadar yıkarız.\n\nBunu 3 kez tekrarlarız.',
          imageEmoji: '😊',
        ),
        KidsLessonStep(
          title: 'Dikkat!',
          content: 'Yüzümüzün her yerinin ıslandığından emin olalım.\n\nSaç diplerini ve kulak önlerini unutmayalım!',
          imageEmoji: '💡',
        ),
      ],
    ),
    KidsLesson(
      id: 'abdest_kollar',
      title: 'Kolları Yıkama',
      description: 'Kollarımızı dirseklere kadar yıkama',
      emoji: '💪',
      category: 'abdest',
      points: 15,
      order: 6,
      steps: [
        KidsLessonStep(
          title: 'Sağ Kol Önce!',
          content: 'Önce sağ kolumuzu parmak uçlarından dirseğimize kadar yıkarız.\n\n3 kez tekrarlarız.',
          imageEmoji: '💪',
        ),
        KidsLessonStep(
          title: 'Sol Kol',
          content: 'Sonra sol kolumuzu aynı şekilde yıkarız.\n\nDirseğimizi de yıkamayı unutmayalım!',
          imageEmoji: '🦾',
        ),
      ],
    ),
    KidsLesson(
      id: 'abdest_bas',
      title: 'Başı Meshetme',
      description: 'Başımızı nasıl mesh ederiz?',
      emoji: '👨',
      category: 'abdest',
      points: 15,
      order: 7,
      steps: [
        KidsLessonStep(
          title: 'Mesh Nedir?',
          content: 'Mesh, ıslak elimizi başımızın üzerinden geçirmektir.\n\nYıkamak değil, sadece ıslatmaktır.',
          imageEmoji: '✋',
        ),
        KidsLessonStep(
          title: 'Nasıl Yapılır?',
          content: 'Islak ellerimizi alnımızdan başlayıp ensemize kadar götürürüz.\n\nSonra geri getiririz. 1 kez yapmak yeterlidir.',
          imageEmoji: '👆',
        ),
      ],
    ),
    KidsLesson(
      id: 'abdest_kulaklar',
      title: 'Kulakları Meshetme',
      description: 'Kulaklarımızı mesh edelim',
      emoji: '👂',
      category: 'abdest',
      points: 10,
      order: 8,
      steps: [
        KidsLessonStep(
          title: 'Kulaklar',
          content: 'Işaret parmaklarımızla kulak içlerini mesh ederiz.\n\nBaş parmaklarımızla kulak arkalarını mesh ederiz.',
          imageEmoji: '👂',
        ),
      ],
    ),
    KidsLesson(
      id: 'abdest_ayaklar',
      title: 'Ayakları Yıkama',
      description: 'Son olarak ayaklarımızı yıkayalım',
      emoji: '🦶',
      category: 'abdest',
      points: 15,
      order: 9,
      steps: [
        KidsLessonStep(
          title: 'Sağ Ayak Önce',
          content: 'Önce sağ ayağımızı topuklarımıza kadar yıkarız.\n\nParmak aralarını da yıkamayı unutmayalım!',
          imageEmoji: '🦶',
        ),
        KidsLessonStep(
          title: 'Sol Ayak',
          content: 'Sonra sol ayağımızı aynı şekilde yıkarız.\n\nHer ayağı 3 kez yıkarız.',
          imageEmoji: '👟',
        ),
        KidsLessonStep(
          title: 'Tebrikler! 🎉',
          content: 'Abdest almayı öğrendin!\n\nŞimdi "Eşhedü en la ilahe illallah ve eşhedü enne Muhammeden abdühü ve resulüh" dua\'sını okuyabiliriz.',
          imageEmoji: '🌟',
        ),
      ],
    ),
  ];

  // Namaz dersleri
  static final List<KidsLesson> namazLessons = [
    KidsLesson(
      id: 'namaz_intro',
      title: 'Namaz Nedir?',
      description: 'Namazı tanıyalım',
      emoji: '🕌',
      category: 'namaz',
      points: 10,
      order: 1,
      steps: [
        KidsLessonStep(
          title: 'Merhaba! 🌙',
          content: 'Namaz, Allah\'a en güzel şekilde ibadet etmektir.\n\nGünde 5 vakit namaz kılarız ve bu bizi Allah\'a yaklaştırır.',
          imageEmoji: '🕌',
        ),
        KidsLessonStep(
          title: '5 Vakit Namaz',
          content: '🌅 Sabah Namazı\n☀️ Öğle Namazı\n🌤️ İkindi Namazı\n🌆 Akşam Namazı\n🌙 Yatsı Namazı',
          imageEmoji: '⏰',
        ),
      ],
    ),
    KidsLesson(
      id: 'namaz_kible',
      title: 'Kıbleye Dönme',
      description: 'Kabe\'ye nasıl döneriz?',
      emoji: '🧭',
      category: 'namaz',
      points: 10,
      order: 2,
      steps: [
        KidsLessonStep(
          title: 'Kıble Nedir?',
          content: 'Kıble, namaz kılarken döndüğümüz yöndür.\n\nKıble, Mekke\'deki Kabe\'nin olduğu yöndür.',
          imageEmoji: '🕋',
        ),
        KidsLessonStep(
          title: 'Nasıl Bulurum?',
          content: 'Türkiye\'den kıble güneydoğu yönündedir.\n\nPusula veya telefon uygulaması ile bulabilirsin!',
          imageEmoji: '🧭',
        ),
      ],
    ),
    KidsLesson(
      id: 'namaz_iftitah',
      title: 'İftitah Tekbiri',
      description: 'Namaza nasıl başlarız?',
      emoji: '🙌',
      category: 'namaz',
      points: 15,
      order: 3,
      steps: [
        KidsLessonStep(
          title: 'Ayakta Durma',
          content: 'Kıbleye dönüp ayakta dururuz.\n\nAyaklarımız omuz genişliğinde açık olmalı.',
          imageEmoji: '🧍',
        ),
        KidsLessonStep(
          title: 'Allahu Ekber',
          content: 'Ellerimizi kulaklarımıza kadar kaldırırız.\n\n"Allahu Ekber" deriz. Bu "Allah en büyüktür" demektir.',
          imageEmoji: '🙌',
        ),
        KidsLessonStep(
          title: 'Elleri Bağlama',
          content: 'Erkekler: Sağ eli sol elin üzerine koyar, göbek altında bağlar.\n\nKızlar: Elleri göğüs üzerinde bağlar.',
          imageEmoji: '🤲',
        ),
      ],
    ),
    KidsLesson(
      id: 'namaz_kiyam',
      title: 'Kıyam - Ayakta Okuma',
      description: 'Fatiha ve sure okuyoruz',
      emoji: '📖',
      category: 'namaz',
      points: 20,
      order: 4,
      steps: [
        KidsLessonStep(
          title: 'Sübhaneke',
          content: 'Önce Sübhaneke duasını okuruz:\n\n"Sübhaneke Allahümme ve bihamdik ve tebarekesmük ve teala ceddük ve la ilahe ğayrük"',
          imageEmoji: '📿',
        ),
        KidsLessonStep(
          title: 'Fatiha Suresi',
          content: 'Sonra Fatiha suresini okuruz. Bu her rekatta okunur.\n\n"Elhamdülillahi rabbil alemin..."',
          imageEmoji: '📖',
        ),
        KidsLessonStep(
          title: 'Zamm-ı Sure',
          content: 'Fatiha\'dan sonra kısa bir sure okuruz.\n\nÖrneğin: İhlas, Kevser, Fil suresi...',
          imageEmoji: '📚',
        ),
      ],
    ),
    KidsLesson(
      id: 'namaz_ruku',
      title: 'Rükû',
      description: 'Eğilme hareketi',
      emoji: '🙇',
      category: 'namaz',
      points: 15,
      order: 5,
      steps: [
        KidsLessonStep(
          title: 'Rükûya Gidiş',
          content: '"Allahu Ekber" diyerek eğiliriz.\n\nEllerimizi dizlerimize koyarız, sırtımız düz olmalı.',
          imageEmoji: '🙇',
        ),
        KidsLessonStep(
          title: 'Rükûda Okuma',
          content: 'Rükûda 3 kez:\n"Sübhane Rabbiyel Azim" deriz.\n\nBu "Yüce Rabbim\'i tesbih ederim" demektir.',
          imageEmoji: '💫',
        ),
        KidsLessonStep(
          title: 'Rükûdan Kalkış',
          content: '"Semiallahu limen hamideh" diyerek doğruluruZ.\n\nSonra "Rabbena lekel hamd" deriz.',
          imageEmoji: '🧍',
        ),
      ],
    ),
    KidsLesson(
      id: 'namaz_secde',
      title: 'Secde',
      description: 'Allah\'a en yakın olduğumuz an',
      emoji: '🤲',
      category: 'namaz',
      points: 20,
      order: 6,
      steps: [
        KidsLessonStep(
          title: 'Secdeye Gidiş',
          content: '"Allahu Ekber" diyerek yere kapanırız.\n\n7 uzuv yere değmeli: alın-burun, iki el, iki diz, iki ayak parmakları.',
          imageEmoji: '🤲',
        ),
        KidsLessonStep(
          title: 'Secdede Okuma',
          content: 'Secdede 3 kez:\n"Sübhane Rabbiyel A\'la" deriz.\n\nBu "En Yüce Rabbim\'i tesbih ederim" demektir.',
          imageEmoji: '⭐',
        ),
        KidsLessonStep(
          title: 'İki Secde',
          content: 'Her rekatta 2 secde yaparız.\n\nİki secde arasında kısa bir süre otururuz.',
          imageEmoji: '2️⃣',
        ),
      ],
    ),
    KidsLesson(
      id: 'namaz_oturuslar',
      title: 'Oturuşlar',
      description: 'Tahiyyat ve selamı öğrenelim',
      emoji: '🪑',
      category: 'namaz',
      points: 20,
      order: 7,
      steps: [
        KidsLessonStep(
          title: 'Nasıl Otururuz?',
          content: 'Sol ayağımızın üzerine oturur, sağ ayağımızı dikeriz.\n\nEllerimiz dizlerimizin üzerinde olur.',
          imageEmoji: '🪑',
        ),
        KidsLessonStep(
          title: 'Tahiyyat',
          content: 'Oturuşta Tahiyyat duasını okuruz:\n\n"Ettahiyyatü lillahi vessalavatü vettayyibatü..."',
          imageEmoji: '📿',
        ),
        KidsLessonStep(
          title: 'Son Oturuş',
          content: 'Son rekattan sonra Tahiyyat, Salli-Barik ve Rabbena dualarını okuruz.',
          imageEmoji: '🤲',
        ),
      ],
    ),
    KidsLesson(
      id: 'namaz_selam',
      title: 'Selam Verme',
      description: 'Namazı bitiriyoruz',
      emoji: '👋',
      category: 'namaz',
      points: 10,
      order: 8,
      steps: [
        KidsLessonStep(
          title: 'Sağa Selam',
          content: 'Başımızı sağa çevirip:\n"Esselamü aleyküm ve rahmetullah" deriz.',
          imageEmoji: '👉',
        ),
        KidsLessonStep(
          title: 'Sola Selam',
          content: 'Başımızı sola çevirip:\n"Esselamü aleyküm ve rahmetullah" deriz.',
          imageEmoji: '👈',
        ),
        KidsLessonStep(
          title: 'Tebrikler! 🎉',
          content: 'Namazı öğrendin!\n\nŞimdi pratik yaparak her gün 5 vakit namaz kılabilirsin.',
          imageEmoji: '🏆',
        ),
      ],
    ),
  ];

  // Ezberlenmesi kolay kısa sureler
  static final List<Map<String, dynamic>> easyToMemorizeSurahs = [
    {
      'id': 'fatiha',
      'name': 'Fatiha Suresi',
      'arabicName': 'الفاتحة',
      'emoji': '📖',
      'points': 50,
      'verses': [
        {'arabic': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', 'turkish': 'Rahman ve Rahim olan Allah\'ın adıyla'},
        {'arabic': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ', 'turkish': 'Hamd, alemlerin Rabbi Allah\'a mahsustur'},
        {'arabic': 'الرَّحْمَٰنِ الرَّحِيمِ', 'turkish': 'O, Rahman ve Rahim\'dir'},
        {'arabic': 'مَالِكِ يَوْمِ الدِّينِ', 'turkish': 'Hesap gününün sahibidir'},
        {'arabic': 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ', 'turkish': 'Yalnız sana ibadet eder, yalnız senden yardım dileriz'},
        {'arabic': 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ', 'turkish': 'Bizi doğru yola ilet'},
        {'arabic': 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ', 'turkish': 'Nimet verdiklerinin yoluna; gazaba uğrayanların ve sapkınların yoluna değil'},
      ],
    },
    {
      'id': 'ihlas',
      'name': 'İhlas Suresi',
      'arabicName': 'الإخلاص',
      'emoji': '💎',
      'points': 30,
      'verses': [
        {'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ', 'turkish': 'De ki: O, Allah\'tır, bir tektir'},
        {'arabic': 'اللَّهُ الصَّمَدُ', 'turkish': 'Allah Samed\'dir (her şey ona muhtaç, O hiçbir şeye muhtaç değil)'},
        {'arabic': 'لَمْ يَلِدْ وَلَمْ يُولَدْ', 'turkish': 'Doğurmamış ve doğurulmamıştır'},
        {'arabic': 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ', 'turkish': 'Hiçbir şey O\'na denk değildir'},
      ],
    },
    {
      'id': 'felak',
      'name': 'Felak Suresi',
      'arabicName': 'الفلق',
      'emoji': '🌅',
      'points': 30,
      'verses': [
        {'arabic': 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ', 'turkish': 'De ki: Sabahın Rabbine sığınırım'},
        {'arabic': 'مِن شَرِّ مَا خَلَقَ', 'turkish': 'Yarattığı şeylerin şerrinden'},
        {'arabic': 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ', 'turkish': 'Karanlık çöktüğü zaman gecenin şerrinden'},
        {'arabic': 'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ', 'turkish': 'Düğümlere üfleyen büyücülerin şerrinden'},
        {'arabic': 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ', 'turkish': 'Haset ettiği zaman hasetçinin şerrinden'},
      ],
    },
    {
      'id': 'nas',
      'name': 'Nas Suresi',
      'arabicName': 'الناس',
      'emoji': '🛡️',
      'points': 30,
      'verses': [
        {'arabic': 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ', 'turkish': 'De ki: İnsanların Rabbine sığınırım'},
        {'arabic': 'مَلِكِ النَّاسِ', 'turkish': 'İnsanların Melikine (Hükümdarına)'},
        {'arabic': 'إِلَٰهِ النَّاسِ', 'turkish': 'İnsanların İlahına'},
        {'arabic': 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ', 'turkish': 'Sinsi vesvesecinin şerrinden'},
        {'arabic': 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ', 'turkish': 'O ki insanların göğüslerine vesvese verir'},
        {'arabic': 'مِنَ الْجِنَّةِ وَالنَّاسِ', 'turkish': 'Gerek cinlerden, gerek insanlardan'},
      ],
    },
    {
      'id': 'kevser',
      'name': 'Kevser Suresi',
      'arabicName': 'الكوثر',
      'emoji': '💧',
      'points': 25,
      'verses': [
        {'arabic': 'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ', 'turkish': 'Şüphesiz biz sana Kevser\'i verdik'},
        {'arabic': 'فَصَلِّ لِرَبِّكَ وَانْحَرْ', 'turkish': 'Öyleyse Rabbin için namaz kıl ve kurban kes'},
        {'arabic': 'إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ', 'turkish': 'Asıl sonu kesik olan, sana kin besleyendir'},
      ],
    },
    {
      'id': 'asr',
      'name': 'Asr Suresi',
      'arabicName': 'العصر',
      'emoji': '⏰',
      'points': 25,
      'verses': [
        {'arabic': 'وَالْعَصْرِ', 'turkish': 'Asra yemin olsun ki'},
        {'arabic': 'إِنَّ الْإِنسَانَ لَفِي خُسْرٍ', 'turkish': 'İnsan gerçekten ziyan içindedir'},
        {'arabic': 'إِلَّا الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ وَتَوَاصَوْا بِالْحَقِّ وَتَوَاصَوْا بِالصَّبْرِ', 'turkish': 'Ancak iman edip salih amel işleyenler, birbirlerine hakkı ve sabrı tavsiye edenler müstesna'},
      ],
    },
    {
      'id': 'fil',
      'name': 'Fil Suresi',
      'arabicName': 'الفيل',
      'emoji': '🐘',
      'points': 30,
      'verses': [
        {'arabic': 'أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِأَصْحَابِ الْفِيلِ', 'turkish': 'Rabbinin fil sahiplerine ne yaptığını görmedin mi?'},
        {'arabic': 'أَلَمْ يَجْعَلْ كَيْدَهُمْ فِي تَضْلِيلٍ', 'turkish': 'Onların tuzaklarını boşa çıkarmadı mı?'},
        {'arabic': 'وَأَرْسَلَ عَلَيْهِمْ طَيْرًا أَبَابِيلَ', 'turkish': 'Üzerlerine sürü sürü kuşlar gönderdi'},
        {'arabic': 'تَرْمِيهِم بِحِجَارَةٍ مِّن سِجِّيلٍ', 'turkish': 'Onlara pişkin tuğladan taşlar atıyorlardı'},
        {'arabic': 'فَجَعَلَهُمْ كَعَصْفٍ مَّأْكُولٍ', 'turkish': 'Sonunda onları yenmiş ekin yaprağı gibi yaptı'},
      ],
    },
  ];

  /// Servisi başlat
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadProfiles();
    await _loadSettings();
    notifyListeners();
  }

  Future<void> _loadProfiles() async {
    final profilesJson = _prefs?.getString('kids_profiles');
    if (profilesJson != null) {
      final List<dynamic> decoded = json.decode(profilesJson);
      _profiles = decoded.map((e) => KidsProfile.fromJson(e)).toList();
    }

    final activeId = _prefs?.getString('active_kids_profile');
    if (activeId != null) {
      _activeProfile = _profiles.firstWhere(
        (p) => p.id == activeId,
        orElse: () => _profiles.first,
      );
    }
  }

  Future<void> _loadSettings() async {
    _isKidsModeEnabled = _prefs?.getBool('kids_mode_enabled') ?? false;
  }

  Future<void> _saveProfiles() async {
    final profilesJson = json.encode(_profiles.map((p) => p.toJson()).toList());
    await _prefs?.setString('kids_profiles', profilesJson);
  }

  /// Yeni profil oluştur
  Future<KidsProfile> createProfile({
    required String name,
    required int age,
    String avatarEmoji = '👦',
  }) async {
    final profile = KidsProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      age: age,
      avatarEmoji: avatarEmoji,
      createdAt: DateTime.now(),
    );

    _profiles.add(profile);
    _activeProfile = profile;
    await _saveProfiles();
    await _prefs?.setString('active_kids_profile', profile.id);
    notifyListeners();
    return profile;
  }

  /// Profili sil
  Future<void> deleteProfile(String profileId) async {
    _profiles.removeWhere((p) => p.id == profileId);
    if (_activeProfile?.id == profileId) {
      _activeProfile = _profiles.isNotEmpty ? _profiles.first : null;
      if (_activeProfile != null) {
        await _prefs?.setString('active_kids_profile', _activeProfile!.id);
      } else {
        await _prefs?.remove('active_kids_profile');
      }
    }
    await _saveProfiles();
    notifyListeners();
  }

  /// Aktif profili değiştir
  Future<void> setActiveProfile(String profileId) async {
    _activeProfile = _profiles.firstWhere((p) => p.id == profileId);
    await _prefs?.setString('active_kids_profile', profileId);
    notifyListeners();
  }

  /// Çocuk modunu aç/kapat
  Future<void> setKidsModeEnabled(bool enabled) async {
    _isKidsModeEnabled = enabled;
    await _prefs?.setBool('kids_mode_enabled', enabled);
    notifyListeners();
  }

  /// Puan ekle
  Future<void> addPoints(int points) async {
    if (_activeProfile == null) return;

    _activeProfile!.totalPoints += points;
    _updateLevel();
    await _checkPointBadges();
    await _saveProfiles();
    notifyListeners();
  }

  void _updateLevel() {
    if (_activeProfile == null) return;
    // Her 100 puanda 1 seviye
    _activeProfile!.level = (_activeProfile!.totalPoints / 100).floor() + 1;
  }

  Future<void> _checkPointBadges() async {
    if (_activeProfile == null) return;

    final points = _activeProfile!.totalPoints;
    
    if (points >= 100 && !_activeProfile!.earnedBadges.contains('points_100')) {
      await earnBadge('points_100');
    }
    if (points >= 500 && !_activeProfile!.earnedBadges.contains('points_500')) {
      await earnBadge('points_500');
    }
    if (points >= 1000 && !_activeProfile!.earnedBadges.contains('points_1000')) {
      await earnBadge('points_1000');
    }
  }

  /// Rozet kazan
  Future<bool> earnBadge(String badgeId) async {
    if (_activeProfile == null) return false;
    if (_activeProfile!.earnedBadges.contains(badgeId)) return false;

    _activeProfile!.earnedBadges.add(badgeId);
    await _saveProfiles();
    notifyListeners();
    return true;
  }

  /// Dersi tamamla
  Future<void> completeLesson(String lessonId, int points) async {
    if (_activeProfile == null) return;

    if (_activeProfile!.completedLessons[lessonId] == true) return;

    _activeProfile!.completedLessons[lessonId] = true;
    await addPoints(points);

    // İlk ders rozetini kontrol et
    if (_activeProfile!.completedLessons.length == 1) {
      await earnBadge('first_step');
    }

    // Abdest derslerini kontrol et
    final completedAbdest = abdestLessons.where(
      (l) => _activeProfile!.completedLessons[l.id] == true
    ).length;
    if (completedAbdest == abdestLessons.length) {
      await earnBadge('abdest_master');
    }

    // Namaz derslerini kontrol et
    final completedNamaz = namazLessons.where(
      (l) => _activeProfile!.completedLessons[l.id] == true
    ).length;
    if (completedNamaz == namazLessons.length) {
      await earnBadge('namaz_hero');
    }

    await _saveProfiles();
    notifyListeners();
  }

  /// Sure ezberleme ilerlemesini güncelle
  Future<void> updateSurahProgress(String surahId, int progress) async {
    if (_activeProfile == null) return;

    final oldProgress = _activeProfile!.memorizedSurahs[surahId] ?? 0;
    _activeProfile!.memorizedSurahs[surahId] = progress;

    // İlk kez tamamlandı mı?
    if (oldProgress < 100 && progress >= 100) {
      // Sure puanını bul ve ekle
      final surah = easyToMemorizeSurahs.firstWhere(
        (s) => s['id'] == surahId,
        orElse: () => {'points': 20},
      );
      await addPoints(surah['points'] as int);

      // İlk sure rozeti
      final memorizedCount = _activeProfile!.memorizedSurahs.values
          .where((p) => p >= 100).length;
      
      if (memorizedCount == 1) {
        await earnBadge('hafiz_yildizi');
      }
      if (memorizedCount >= 5) {
        await earnBadge('super_hafiz');
      }
    }

    await _saveProfiles();
    notifyListeners();
  }

  /// Namaz streak güncelle
  Future<void> recordPrayer() async {
    if (_activeProfile == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_activeProfile!.lastPrayerDate != null) {
      final lastDate = DateTime(
        _activeProfile!.lastPrayerDate!.year,
        _activeProfile!.lastPrayerDate!.month,
        _activeProfile!.lastPrayerDate!.day,
      );

      final difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        // Ardışık gün
        _activeProfile!.prayerStreak++;
      } else if (difference > 1) {
        // Streak kırıldı
        _activeProfile!.prayerStreak = 1;
      }
      // difference == 0 ise bugün zaten işaretlenmiş
    } else {
      _activeProfile!.prayerStreak = 1;
    }

    _activeProfile!.lastPrayerDate = now;

    // Streak rozetlerini kontrol et
    if (_activeProfile!.prayerStreak >= 3) {
      await earnBadge('streak_3');
    }
    if (_activeProfile!.prayerStreak >= 7) {
      await earnBadge('streak_7');
    }
    if (_activeProfile!.prayerStreak >= 30) {
      await earnBadge('streak_30');
    }

    await addPoints(5); // Her namaz için 5 puan
    await _saveProfiles();
    notifyListeners();
  }

  /// Dersin tamamlanıp tamamlanmadığını kontrol et
  bool isLessonCompleted(String lessonId) {
    return _activeProfile?.completedLessons[lessonId] == true;
  }

  /// Sure ezberleme ilerlemesini al
  int getSurahProgress(String surahId) {
    return _activeProfile?.memorizedSurahs[surahId] ?? 0;
  }

  /// Rozet bilgisini al
  KidsBadge? getBadgeById(String badgeId) {
    try {
      return allBadges.firstWhere((b) => b.id == badgeId);
    } catch (_) {
      return null;
    }
  }

  /// Profil istatistikleri
  Map<String, dynamic> getProfileStats() {
    if (_activeProfile == null) {
      return {
        'totalPoints': 0,
        'level': 1,
        'badgesCount': 0,
        'lessonsCompleted': 0,
        'surahsMemorized': 0,
        'prayerStreak': 0,
      };
    }

    return {
      'totalPoints': _activeProfile!.totalPoints,
      'level': _activeProfile!.level,
      'badgesCount': _activeProfile!.earnedBadges.length,
      'lessonsCompleted': _activeProfile!.completedLessons.values.where((v) => v).length,
      'surahsMemorized': _activeProfile!.memorizedSurahs.values.where((p) => p >= 100).length,
      'prayerStreak': _activeProfile!.prayerStreak,
    };
  }
}
