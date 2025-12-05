/// Cami Bulucu için veri modelleri
/// Camiler, imkanlar, puanlamalar ve yorumlar

// Cami imkanları enum
enum MosqueAmenity {
  womensSection,      // Kadınlar bölümü
  hotWater,           // Sıcak su
  cleanToilet,        // Temiz tuvalet
  disabledAccess,     // Engelli erişimi
  parking,            // Otopark
  airConditioning,    // Klima
  heating,            // Isıtma
  wuduArea,           // Abdesthane
  library,            // Kütüphane
  conferenceHall,     // Konferans salonu
  childrenArea,       // Çocuk bölümü
  shoeStorage,        // Ayakkabılık
  prayerRug,          // Seccade
  quranAvailable,     // Kuran-ı Kerim mevcut
  freeWifi,           // Ücretsiz WiFi
  fridayPrayer,       // Cuma namazı
  religiousCourses,   // Dini kurslar
  tapisSalon,         // Halı kaplı salon
}

extension MosqueAmenityExtension on MosqueAmenity {
  String get displayName {
    switch (this) {
      case MosqueAmenity.womensSection:
        return 'Kadınlar Bölümü';
      case MosqueAmenity.hotWater:
        return 'Sıcak Su';
      case MosqueAmenity.cleanToilet:
        return 'Temiz Tuvalet';
      case MosqueAmenity.disabledAccess:
        return 'Engelli Erişimi';
      case MosqueAmenity.parking:
        return 'Otopark';
      case MosqueAmenity.airConditioning:
        return 'Klima';
      case MosqueAmenity.heating:
        return 'Isıtma';
      case MosqueAmenity.wuduArea:
        return 'Abdesthane';
      case MosqueAmenity.library:
        return 'Kütüphane';
      case MosqueAmenity.conferenceHall:
        return 'Konferans Salonu';
      case MosqueAmenity.childrenArea:
        return 'Çocuk Bölümü';
      case MosqueAmenity.shoeStorage:
        return 'Ayakkabılık';
      case MosqueAmenity.prayerRug:
        return 'Seccade Mevcut';
      case MosqueAmenity.quranAvailable:
        return 'Kuran-ı Kerim Mevcut';
      case MosqueAmenity.freeWifi:
        return 'Ücretsiz WiFi';
      case MosqueAmenity.fridayPrayer:
        return 'Cuma Namazı';
      case MosqueAmenity.religiousCourses:
        return 'Dini Kurslar';
      case MosqueAmenity.tapisSalon:
        return 'Halı Kaplı Salon';
    }
  }

  String get icon {
    switch (this) {
      case MosqueAmenity.womensSection:
        return '👩';
      case MosqueAmenity.hotWater:
        return '🔥';
      case MosqueAmenity.cleanToilet:
        return '🚻';
      case MosqueAmenity.disabledAccess:
        return '♿';
      case MosqueAmenity.parking:
        return '🅿️';
      case MosqueAmenity.airConditioning:
        return '❄️';
      case MosqueAmenity.heating:
        return '🌡️';
      case MosqueAmenity.wuduArea:
        return '💧';
      case MosqueAmenity.library:
        return '📚';
      case MosqueAmenity.conferenceHall:
        return '🎤';
      case MosqueAmenity.childrenArea:
        return '👶';
      case MosqueAmenity.shoeStorage:
        return '👟';
      case MosqueAmenity.prayerRug:
        return '🧎';
      case MosqueAmenity.quranAvailable:
        return '📖';
      case MosqueAmenity.freeWifi:
        return '📶';
      case MosqueAmenity.fridayPrayer:
        return '🕌';
      case MosqueAmenity.religiousCourses:
        return '📿';
      case MosqueAmenity.tapisSalon:
        return '🟫';
    }
  }
}

// Cami modeli
class Mosque {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String? phone;
  final String? website;
  final String? imageUrl;
  final List<MosqueAmenity> amenities;
  final double averageRating;
  final int totalRatings;
  final double? distanceInKm;
  final String? openingHours;
  final String? imamName;
  final int? capacity;
  final bool isVerified;
  final DateTime? lastUpdated;

  const Mosque({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.phone,
    this.website,
    this.imageUrl,
    this.amenities = const [],
    this.averageRating = 0.0,
    this.totalRatings = 0,
    this.distanceInKm,
    this.openingHours,
    this.imamName,
    this.capacity,
    this.isVerified = false,
    this.lastUpdated,
  });

  Mosque copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    String? phone,
    String? website,
    String? imageUrl,
    List<MosqueAmenity>? amenities,
    double? averageRating,
    int? totalRatings,
    double? distanceInKm,
    String? openingHours,
    String? imamName,
    int? capacity,
    bool? isVerified,
    DateTime? lastUpdated,
  }) {
    return Mosque(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      imageUrl: imageUrl ?? this.imageUrl,
      amenities: amenities ?? this.amenities,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      distanceInKm: distanceInKm ?? this.distanceInKm,
      openingHours: openingHours ?? this.openingHours,
      imamName: imamName ?? this.imamName,
      capacity: capacity ?? this.capacity,
      isVerified: isVerified ?? this.isVerified,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'phone': phone,
      'website': website,
      'imageUrl': imageUrl,
      'amenities': amenities.map((a) => a.index).toList(),
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'distanceInKm': distanceInKm,
      'openingHours': openingHours,
      'imamName': imamName,
      'capacity': capacity,
      'isVerified': isVerified ? 1 : 0,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory Mosque.fromMap(Map<String, dynamic> map) {
    return Mosque(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
      phone: map['phone'],
      website: map['website'],
      imageUrl: map['imageUrl'],
      amenities: (map['amenities'] as List<dynamic>?)
              ?.map((index) => MosqueAmenity.values[index as int])
              .toList() ??
          [],
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      totalRatings: map['totalRatings'] ?? 0,
      distanceInKm: map['distanceInKm']?.toDouble(),
      openingHours: map['openingHours'],
      imamName: map['imamName'],
      capacity: map['capacity'],
      isVerified: map['isVerified'] == 1,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : null,
    );
  }

  // İmkan kontrolü
  bool hasAmenity(MosqueAmenity amenity) => amenities.contains(amenity);

  // Birden fazla imkan kontrolü (hepsi var mı?)
  bool hasAllAmenities(List<MosqueAmenity> requiredAmenities) {
    return requiredAmenities.every((amenity) => amenities.contains(amenity));
  }

  // Birden fazla imkan kontrolü (herhangi biri var mı?)
  bool hasAnyAmenity(List<MosqueAmenity> checkAmenities) {
    return checkAmenities.any((amenity) => amenities.contains(amenity));
  }
}

// Kullanıcı yorumu modeli
class MosqueReview {
  final String id;
  final String mosqueId;
  final String userId;
  final String userName;
  final double rating;
  final String? comment;
  final List<MosqueAmenity> confirmedAmenities;
  final DateTime createdAt;
  final int helpfulCount;
  final bool isVerified;

  const MosqueReview({
    required this.id,
    required this.mosqueId,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment,
    this.confirmedAmenities = const [],
    required this.createdAt,
    this.helpfulCount = 0,
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mosqueId': mosqueId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'confirmedAmenities': confirmedAmenities.map((a) => a.index).toList(),
      'createdAt': createdAt.toIso8601String(),
      'helpfulCount': helpfulCount,
      'isVerified': isVerified ? 1 : 0,
    };
  }

  factory MosqueReview.fromMap(Map<String, dynamic> map) {
    return MosqueReview(
      id: map['id'] ?? '',
      mosqueId: map['mosqueId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonim',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'],
      confirmedAmenities: (map['confirmedAmenities'] as List<dynamic>?)
              ?.map((index) => MosqueAmenity.values[index as int])
              .toList() ??
          [],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      helpfulCount: map['helpfulCount'] ?? 0,
      isVerified: map['isVerified'] == 1,
    );
  }
}

// Filtre seçenekleri
class MosqueFilter {
  final List<MosqueAmenity> requiredAmenities;
  final double? maxDistance;
  final double? minRating;
  final bool onlyVerified;
  final String? searchQuery;

  const MosqueFilter({
    this.requiredAmenities = const [],
    this.maxDistance,
    this.minRating,
    this.onlyVerified = false,
    this.searchQuery,
  });

  MosqueFilter copyWith({
    List<MosqueAmenity>? requiredAmenities,
    double? maxDistance,
    double? minRating,
    bool? onlyVerified,
    String? searchQuery,
  }) {
    return MosqueFilter(
      requiredAmenities: requiredAmenities ?? this.requiredAmenities,
      maxDistance: maxDistance ?? this.maxDistance,
      minRating: minRating ?? this.minRating,
      onlyVerified: onlyVerified ?? this.onlyVerified,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool matches(Mosque mosque) {
    // İmkan filtresi
    if (requiredAmenities.isNotEmpty) {
      if (!mosque.hasAllAmenities(requiredAmenities)) {
        return false;
      }
    }

    // Mesafe filtresi
    if (maxDistance != null && mosque.distanceInKm != null) {
      if (mosque.distanceInKm! > maxDistance!) {
        return false;
      }
    }

    // Puan filtresi
    if (minRating != null) {
      if (mosque.averageRating < minRating!) {
        return false;
      }
    }

    // Doğrulanmış filtresi
    if (onlyVerified && !mosque.isVerified) {
      return false;
    }

    // Arama filtresi
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      if (!mosque.name.toLowerCase().contains(query) &&
          !mosque.address.toLowerCase().contains(query)) {
        return false;
      }
    }

    return true;
  }
}

// Popüler filtre presetleri
class MosqueFilterPresets {
  static const MosqueFilter familyFriendly = MosqueFilter(
    requiredAmenities: [
      MosqueAmenity.womensSection,
      MosqueAmenity.childrenArea,
    ],
  );

  static const MosqueFilter travelFriendly = MosqueFilter(
    requiredAmenities: [
      MosqueAmenity.hotWater,
      MosqueAmenity.cleanToilet,
      MosqueAmenity.wuduArea,
    ],
  );

  static const MosqueFilter disabledFriendly = MosqueFilter(
    requiredAmenities: [
      MosqueAmenity.disabledAccess,
    ],
  );

  static const MosqueFilter withParking = MosqueFilter(
    requiredAmenities: [
      MosqueAmenity.parking,
    ],
  );

  static const MosqueFilter highlyRated = MosqueFilter(
    minRating: 4.0,
  );
}

// Örnek camiler (Türkiye'den bazı önemli camiler)
final List<Mosque> sampleMosques = [
  const Mosque(
    id: '1',
    name: 'Sultanahmet Camii (Mavi Cami)',
    latitude: 41.0054,
    longitude: 28.9768,
    address: 'Sultan Ahmet, Atmeydanı Cd. No:7, 34122 Fatih/İstanbul',
    phone: '+90 212 458 44 68',
    amenities: [
      MosqueAmenity.womensSection,
      MosqueAmenity.cleanToilet,
      MosqueAmenity.wuduArea,
      MosqueAmenity.shoeStorage,
      MosqueAmenity.prayerRug,
      MosqueAmenity.quranAvailable,
      MosqueAmenity.fridayPrayer,
      MosqueAmenity.disabledAccess,
    ],
    averageRating: 4.8,
    totalRatings: 1250,
    capacity: 10000,
    isVerified: true,
  ),
  const Mosque(
    id: '2',
    name: 'Süleymaniye Camii',
    latitude: 41.0161,
    longitude: 28.9644,
    address: 'Süleymaniye Mah., Prof. Sıddık Sami Onar Cd. No:1, 34116 Fatih/İstanbul',
    phone: '+90 212 514 01 39',
    amenities: [
      MosqueAmenity.womensSection,
      MosqueAmenity.cleanToilet,
      MosqueAmenity.wuduArea,
      MosqueAmenity.shoeStorage,
      MosqueAmenity.prayerRug,
      MosqueAmenity.quranAvailable,
      MosqueAmenity.fridayPrayer,
      MosqueAmenity.library,
      MosqueAmenity.parking,
    ],
    averageRating: 4.9,
    totalRatings: 980,
    capacity: 5000,
    isVerified: true,
  ),
  const Mosque(
    id: '3',
    name: 'Eyüpsultan Camii',
    latitude: 41.0478,
    longitude: 28.9337,
    address: 'Eyüp Merkez, Camii Kebir Sk. No:1, 34050 Eyüpsultan/İstanbul',
    amenities: [
      MosqueAmenity.womensSection,
      MosqueAmenity.cleanToilet,
      MosqueAmenity.hotWater,
      MosqueAmenity.wuduArea,
      MosqueAmenity.shoeStorage,
      MosqueAmenity.prayerRug,
      MosqueAmenity.quranAvailable,
      MosqueAmenity.fridayPrayer,
    ],
    averageRating: 4.7,
    totalRatings: 756,
    isVerified: true,
  ),
  const Mosque(
    id: '4',
    name: 'Kocatepe Camii',
    latitude: 39.9181,
    longitude: 32.8539,
    address: 'Kocatepe, Kocatepe Cd., 06420 Çankaya/Ankara',
    amenities: [
      MosqueAmenity.womensSection,
      MosqueAmenity.cleanToilet,
      MosqueAmenity.hotWater,
      MosqueAmenity.wuduArea,
      MosqueAmenity.shoeStorage,
      MosqueAmenity.prayerRug,
      MosqueAmenity.quranAvailable,
      MosqueAmenity.fridayPrayer,
      MosqueAmenity.parking,
      MosqueAmenity.airConditioning,
      MosqueAmenity.disabledAccess,
      MosqueAmenity.conferenceHall,
    ],
    averageRating: 4.6,
    totalRatings: 543,
    capacity: 24000,
    isVerified: true,
  ),
  const Mosque(
    id: '5',
    name: 'Hisar Camii',
    latitude: 40.1917,
    longitude: 29.0589,
    address: 'Hisar Mah., Yıldırım/Bursa',
    amenities: [
      MosqueAmenity.womensSection,
      MosqueAmenity.cleanToilet,
      MosqueAmenity.wuduArea,
      MosqueAmenity.prayerRug,
      MosqueAmenity.quranAvailable,
      MosqueAmenity.fridayPrayer,
    ],
    averageRating: 4.5,
    totalRatings: 234,
    isVerified: true,
  ),
  const Mosque(
    id: '6',
    name: 'Şeb-i Arus Camii',
    latitude: 37.8715,
    longitude: 32.5034,
    address: 'Mevlana Mah., Mevlana Cd., 42030 Meram/Konya',
    amenities: [
      MosqueAmenity.womensSection,
      MosqueAmenity.cleanToilet,
      MosqueAmenity.hotWater,
      MosqueAmenity.wuduArea,
      MosqueAmenity.shoeStorage,
      MosqueAmenity.prayerRug,
      MosqueAmenity.quranAvailable,
      MosqueAmenity.fridayPrayer,
      MosqueAmenity.childrenArea,
    ],
    averageRating: 4.4,
    totalRatings: 189,
    isVerified: true,
  ),
  const Mosque(
    id: '7',
    name: 'Sabancı Merkez Camii',
    latitude: 36.9912,
    longitude: 35.3275,
    address: 'Merkez, 01170 Seyhan/Adana',
    amenities: [
      MosqueAmenity.womensSection,
      MosqueAmenity.cleanToilet,
      MosqueAmenity.hotWater,
      MosqueAmenity.wuduArea,
      MosqueAmenity.shoeStorage,
      MosqueAmenity.prayerRug,
      MosqueAmenity.quranAvailable,
      MosqueAmenity.fridayPrayer,
      MosqueAmenity.parking,
      MosqueAmenity.airConditioning,
      MosqueAmenity.disabledAccess,
    ],
    averageRating: 4.7,
    totalRatings: 421,
    capacity: 28500,
    isVerified: true,
  ),
  const Mosque(
    id: '8',
    name: 'Çamlıca Camii',
    latitude: 41.0273,
    longitude: 29.0691,
    address: 'Ferah Yolu Sk., 34692 Üsküdar/İstanbul',
    amenities: [
      MosqueAmenity.womensSection,
      MosqueAmenity.cleanToilet,
      MosqueAmenity.hotWater,
      MosqueAmenity.wuduArea,
      MosqueAmenity.shoeStorage,
      MosqueAmenity.prayerRug,
      MosqueAmenity.quranAvailable,
      MosqueAmenity.fridayPrayer,
      MosqueAmenity.parking,
      MosqueAmenity.airConditioning,
      MosqueAmenity.heating,
      MosqueAmenity.disabledAccess,
      MosqueAmenity.library,
      MosqueAmenity.conferenceHall,
      MosqueAmenity.childrenArea,
      MosqueAmenity.freeWifi,
    ],
    averageRating: 4.9,
    totalRatings: 1567,
    capacity: 63000,
    isVerified: true,
  ),
];
