import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../data/mosque_data.dart';
import 'mosque_api_service.dart';

/// Cami bulucu servisi
/// Konum tabanlı cami arama, filtreleme, favori ve yorum yönetimi
class MosqueService {
  static const String _favoritesKey = 'mosque_favorites';
  static const String _reviewsKey = 'mosque_reviews';
  static const String _userMosquesKey = 'user_mosques';
  static const String _cachedMosquesKey = 'cached_mosques';
  static const String _lastFetchTimeKey = 'last_mosque_fetch';

  // Singleton pattern
  static final MosqueService _instance = MosqueService._internal();
  factory MosqueService() => _instance;
  MosqueService._internal();

  SharedPreferences? _prefs;
  Position? _currentPosition;
  final MosqueApiService _apiService = MosqueApiService();
  List<Mosque> _cachedApiMosques = [];
  bool _isLoadingFromApi = false;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _updateCurrentPosition();
    await _loadCachedMosques();
    // Arka planda API'den camileri çek
    _fetchMosquesFromApi();
  }

  // Cache'den camileri yükle
  Future<void> _loadCachedMosques() async {
    _prefs ??= await SharedPreferences.getInstance();
    final cachedJson = _prefs!.getString(_cachedMosquesKey);
    if (cachedJson != null) {
      try {
        final List<dynamic> mosquesList = json.decode(cachedJson);
        _cachedApiMosques = mosquesList
            .map((m) => Mosque.fromMap(m as Map<String, dynamic>))
            .toList();
      } catch (e) {
        _cachedApiMosques = [];
      }
    }
  }

  // API'den camileri çek ve cache'le
  Future<void> _fetchMosquesFromApi() async {
    if (_isLoadingFromApi || _currentPosition == null) return;
    
    // Son çekme zamanını kontrol et (1 saat içinde tekrar çekme)
    final lastFetch = _prefs?.getInt(_lastFetchTimeKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastFetch < 3600000 && _cachedApiMosques.isNotEmpty) {
      return; // 1 saat içinde zaten çekilmiş
    }

    _isLoadingFromApi = true;
    try {
      final mosques = await _apiService.fetchMosquesNearby(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radiusKm: 15,
      );

      if (mosques.isNotEmpty) {
        _cachedApiMosques = mosques;
        // Cache'e kaydet
        final mosquesJson = json.encode(mosques.map((m) => m.toMap()).toList());
        await _prefs?.setString(_cachedMosquesKey, mosquesJson);
        await _prefs?.setInt(_lastFetchTimeKey, now);
      }
    } catch (e) {
      print('API\'den cami çekilirken hata: $e');
    } finally {
      _isLoadingFromApi = false;
    }
  }

  // API'den zorla yenile
  Future<List<Mosque>> refreshMosquesFromApi() async {
    if (_currentPosition == null) {
      await _updateCurrentPosition();
    }
    
    if (_currentPosition != null) {
      _isLoadingFromApi = true;
      try {
        final mosques = await _apiService.fetchMosquesNearby(
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          radiusKm: 15,
        );

        if (mosques.isNotEmpty) {
          _cachedApiMosques = mosques;
          final mosquesJson = json.encode(mosques.map((m) => m.toMap()).toList());
          await _prefs?.setString(_cachedMosquesKey, mosquesJson);
          await _prefs?.setInt(_lastFetchTimeKey, DateTime.now().millisecondsSinceEpoch);
        }
        return mosques;
      } catch (e) {
        print('API yenileme hatası: $e');
      } finally {
        _isLoadingFromApi = false;
      }
    }
    return [];
  }

  // Belirli bir il için camileri çek
  Future<List<Mosque>> getMosquesByProvince(String province) async {
    try {
      return await _apiService.fetchMosquesByProvince(province, radiusKm: 20);
    } catch (e) {
      return [];
    }
  }

  /// API'den cami yükle - ekrandan çağrılan metod
  Future<void> loadMosquesFromAPI({String? city}) async {
    if (city != null) {
      // Belirli bir il için yükle
      final mosques = await getMosquesByProvince(city);
      if (mosques.isNotEmpty) {
        _cachedApiMosques = mosques;
        final mosquesJson = json.encode(mosques.map((m) => m.toMap()).toList());
        await _prefs?.setString(_cachedMosquesKey, mosquesJson);
        await _prefs?.setInt(_lastFetchTimeKey, DateTime.now().millisecondsSinceEpoch);
      }
    } else {
      // Mevcut konuma göre yükle
      await refreshMosquesFromApi();
    }
  }

  // Tüm illerin listesi
  List<String> getAllProvinces() {
    return _apiService.getAllProvinces();
  }

  // Konumu güncelle
  Future<void> _updateCurrentPosition() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        final newPermission = await Geolocator.requestPermission();
        if (newPermission == LocationPermission.denied ||
            newPermission == LocationPermission.deniedForever) {
          return;
        }
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      // Konum alınamadı
    }
  }

  // Mevcut konumu getir
  Future<Position?> getCurrentPosition() async {
    if (_currentPosition == null) {
      await _updateCurrentPosition();
    }
    return _currentPosition;
  }

  // İki nokta arasındaki mesafeyi hesapla (Haversine formülü)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // km
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  // Tüm camileri getir (mesafe hesaplamalı)
  Future<List<Mosque>> getAllMosques() async {
    await _updateCurrentPosition();
    final userMosques = await _getUserMosques();
    
    // API'den gelen camiler + örnek camiler + kullanıcı camileri
    final allMosques = <Mosque>[
      ..._cachedApiMosques,
      ...sampleMosques,
      ...userMosques,
    ];

    // Duplicate'leri kaldır (aynı id veya çok yakın konumlar)
    final uniqueMosques = <Mosque>[];
    for (final mosque in allMosques) {
      final isDuplicate = uniqueMosques.any((m) =>
          m.id == mosque.id ||
          (calculateDistance(m.latitude, m.longitude, mosque.latitude, mosque.longitude) < 0.05));
      if (!isDuplicate) {
        uniqueMosques.add(mosque);
      }
    }

    if (_currentPosition != null) {
      return uniqueMosques.map((mosque) {
        final distance = calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          mosque.latitude,
          mosque.longitude,
        );
        return mosque.copyWith(distanceInKm: distance);
      }).toList()
        ..sort((a, b) =>
            (a.distanceInKm ?? double.infinity)
                .compareTo(b.distanceInKm ?? double.infinity));
    }

    return uniqueMosques;
  }

  // API'den yükleme durumu
  bool get isLoadingFromApi => _isLoadingFromApi;

  // Yakındaki camileri getir
  Future<List<Mosque>> getNearbyMosques({double maxDistanceKm = 10}) async {
    final mosques = await getAllMosques();
    return mosques
        .where((m) => m.distanceInKm != null && m.distanceInKm! <= maxDistanceKm)
        .toList();
  }

  // Filtrelenmiş camileri getir
  Future<List<Mosque>> getFilteredMosques(MosqueFilter filter) async {
    final mosques = await getAllMosques();
    return mosques.where((m) => filter.matches(m)).toList();
  }

  // İmkana göre filtrele
  Future<List<Mosque>> getMosquesWithAmenities(
      List<MosqueAmenity> amenities) async {
    final mosques = await getAllMosques();
    return mosques.where((m) => m.hasAllAmenities(amenities)).toList();
  }

  // Cami ara
  Future<List<Mosque>> searchMosques(String query) async {
    final mosques = await getAllMosques();
    final lowerQuery = query.toLowerCase();
    return mosques
        .where((m) =>
            m.name.toLowerCase().contains(lowerQuery) ||
            m.address.toLowerCase().contains(lowerQuery))
        .toList();
  }

  // Favori işlemleri
  Future<List<String>> getFavorites() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getStringList(_favoritesKey) ?? [];
  }

  Future<bool> isFavorite(String mosqueId) async {
    final favorites = await getFavorites();
    return favorites.contains(mosqueId);
  }

  Future<void> toggleFavorite(String mosqueId) async {
    _prefs ??= await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    if (favorites.contains(mosqueId)) {
      favorites.remove(mosqueId);
    } else {
      favorites.add(mosqueId);
    }

    await _prefs!.setStringList(_favoritesKey, favorites);
  }

  Future<List<Mosque>> getFavoriteMosques() async {
    final favorites = await getFavorites();
    final mosques = await getAllMosques();
    return mosques.where((m) => favorites.contains(m.id)).toList();
  }

  // Yorum işlemleri
  Future<List<MosqueReview>> getReviews(String mosqueId) async {
    _prefs ??= await SharedPreferences.getInstance();
    final reviewsJson = _prefs!.getString(_reviewsKey);

    if (reviewsJson == null) return [];

    final Map<String, dynamic> allReviews = json.decode(reviewsJson);
    final mosqueReviewsList = allReviews[mosqueId] as List<dynamic>? ?? [];

    return mosqueReviewsList
        .map((r) => MosqueReview.fromMap(r as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addReview(MosqueReview review) async {
    _prefs ??= await SharedPreferences.getInstance();
    final reviewsJson = _prefs!.getString(_reviewsKey);

    Map<String, dynamic> allReviews = {};
    if (reviewsJson != null) {
      allReviews = json.decode(reviewsJson);
    }

    final mosqueReviewsList =
        allReviews[review.mosqueId] as List<dynamic>? ?? [];
    mosqueReviewsList.add(review.toMap());
    allReviews[review.mosqueId] = mosqueReviewsList;

    await _prefs!.setString(_reviewsKey, json.encode(allReviews));
  }

  // Kullanıcı eklediği camileri getir
  Future<List<Mosque>> _getUserMosques() async {
    _prefs ??= await SharedPreferences.getInstance();
    final mosquesJson = _prefs!.getString(_userMosquesKey);

    if (mosquesJson == null) return [];

    final List<dynamic> mosquesList = json.decode(mosquesJson);
    return mosquesList
        .map((m) => Mosque.fromMap(m as Map<String, dynamic>))
        .toList();
  }

  // Kullanıcı cami ekle
  Future<void> addUserMosque(Mosque mosque) async {
    _prefs ??= await SharedPreferences.getInstance();
    final mosques = await _getUserMosques();
    mosques.add(mosque);

    final mosquesJson = json.encode(mosques.map((m) => m.toMap()).toList());
    await _prefs!.setString(_userMosquesKey, mosquesJson);
  }

  // Kullanıcı camisi güncelle (imkan ekle/çıkar)
  Future<void> updateMosqueAmenities(
      String mosqueId, List<MosqueAmenity> amenities) async {
    _prefs ??= await SharedPreferences.getInstance();
    final mosques = await _getUserMosques();

    final index = mosques.indexWhere((m) => m.id == mosqueId);
    if (index != -1) {
      mosques[index] = mosques[index].copyWith(
        amenities: amenities,
        lastUpdated: DateTime.now(),
      );

      final mosquesJson = json.encode(mosques.map((m) => m.toMap()).toList());
      await _prefs!.setString(_userMosquesKey, mosquesJson);
    }
  }

  // Popüler öneriler
  List<Map<String, dynamic>> getQuickFilters() {
    return [
      {
        'title': 'Yolcular İçin',
        'subtitle': 'Sıcak su ve temiz tuvalet',
        'icon': '🚗',
        'filter': MosqueFilterPresets.travelFriendly,
      },
      {
        'title': 'Aile Dostu',
        'subtitle': 'Kadınlar bölümü ve çocuk alanı',
        'icon': '👨‍👩‍👧',
        'filter': MosqueFilterPresets.familyFriendly,
      },
      {
        'title': 'Engelsiz Erişim',
        'subtitle': 'Engelli erişimi uygun',
        'icon': '♿',
        'filter': MosqueFilterPresets.disabledFriendly,
      },
      {
        'title': 'Otoparkı Var',
        'subtitle': 'Araç park imkanı',
        'icon': '🅿️',
        'filter': MosqueFilterPresets.withParking,
      },
      {
        'title': 'Yüksek Puanlı',
        'subtitle': '4+ puan alan camiler',
        'icon': '⭐',
        'filter': MosqueFilterPresets.highlyRated,
      },
    ];
  }

  // Navigasyon URL'i oluştur (Google Maps)
  String getNavigationUrl(Mosque mosque) {
    return 'https://www.google.com/maps/dir/?api=1&destination=${mosque.latitude},${mosque.longitude}&travelmode=driving';
  }

  // Yürüyüş navigasyonu
  String getWalkingNavigationUrl(Mosque mosque) {
    return 'https://www.google.com/maps/dir/?api=1&destination=${mosque.latitude},${mosque.longitude}&travelmode=walking';
  }
}
