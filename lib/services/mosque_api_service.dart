import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../data/mosque_data.dart';

/// OpenStreetMap Overpass API ile Türkiye'deki camileri çeken servis
class MosqueApiService {
  static final MosqueApiService _instance = MosqueApiService._internal();
  factory MosqueApiService() => _instance;
  MosqueApiService._internal();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // Overpass API endpoint
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';

  // Türkiye'nin 81 ili ve koordinatları
  static const Map<String, Map<String, double>> turkeyProvinces = {
    'Adana': {'lat': 37.0, 'lon': 35.3213},
    'Adıyaman': {'lat': 37.7648, 'lon': 38.2786},
    'Afyonkarahisar': {'lat': 38.7507, 'lon': 30.5567},
    'Ağrı': {'lat': 39.7191, 'lon': 43.0503},
    'Aksaray': {'lat': 38.3687, 'lon': 34.0370},
    'Amasya': {'lat': 40.6499, 'lon': 35.8353},
    'Ankara': {'lat': 39.9334, 'lon': 32.8597},
    'Antalya': {'lat': 36.8969, 'lon': 30.7133},
    'Ardahan': {'lat': 41.1105, 'lon': 42.7022},
    'Artvin': {'lat': 41.1828, 'lon': 41.8183},
    'Aydın': {'lat': 37.8560, 'lon': 27.8416},
    'Balıkesir': {'lat': 39.6484, 'lon': 27.8826},
    'Bartın': {'lat': 41.6344, 'lon': 32.3375},
    'Batman': {'lat': 37.8812, 'lon': 41.1351},
    'Bayburt': {'lat': 40.2552, 'lon': 40.2249},
    'Bilecik': {'lat': 40.0567, 'lon': 30.0665},
    'Bingöl': {'lat': 38.8854, 'lon': 40.4966},
    'Bitlis': {'lat': 38.4004, 'lon': 42.1095},
    'Bolu': {'lat': 40.7360, 'lon': 31.6061},
    'Burdur': {'lat': 37.4613, 'lon': 30.0665},
    'Bursa': {'lat': 40.1826, 'lon': 29.0665},
    'Çanakkale': {'lat': 40.1553, 'lon': 26.4142},
    'Çankırı': {'lat': 40.6013, 'lon': 33.6134},
    'Çorum': {'lat': 40.5506, 'lon': 34.9556},
    'Denizli': {'lat': 37.7765, 'lon': 29.0864},
    'Diyarbakır': {'lat': 37.9144, 'lon': 40.2306},
    'Düzce': {'lat': 40.8438, 'lon': 31.1565},
    'Edirne': {'lat': 41.6818, 'lon': 26.5623},
    'Elazığ': {'lat': 38.6810, 'lon': 39.2264},
    'Erzincan': {'lat': 39.7500, 'lon': 39.5000},
    'Erzurum': {'lat': 39.9000, 'lon': 41.2700},
    'Eskişehir': {'lat': 39.7767, 'lon': 30.5206},
    'Gaziantep': {'lat': 37.0662, 'lon': 37.3833},
    'Giresun': {'lat': 40.9128, 'lon': 38.3895},
    'Gümüşhane': {'lat': 40.4386, 'lon': 39.5086},
    'Hakkari': {'lat': 37.5833, 'lon': 43.7333},
    'Hatay': {'lat': 36.4018, 'lon': 36.3498},
    'Iğdır': {'lat': 39.9167, 'lon': 44.0333},
    'Isparta': {'lat': 37.7648, 'lon': 30.5566},
    'İstanbul': {'lat': 41.0082, 'lon': 28.9784},
    'İzmir': {'lat': 38.4237, 'lon': 27.1428},
    'Kahramanmaraş': {'lat': 37.5858, 'lon': 36.9371},
    'Karabük': {'lat': 41.2061, 'lon': 32.6204},
    'Karaman': {'lat': 37.1759, 'lon': 33.2287},
    'Kars': {'lat': 40.6167, 'lon': 43.1000},
    'Kastamonu': {'lat': 41.3887, 'lon': 33.7827},
    'Kayseri': {'lat': 38.7312, 'lon': 35.4787},
    'Kırıkkale': {'lat': 39.8468, 'lon': 33.5153},
    'Kırklareli': {'lat': 41.7333, 'lon': 27.2167},
    'Kırşehir': {'lat': 39.1425, 'lon': 34.1709},
    'Kilis': {'lat': 36.7184, 'lon': 37.1212},
    'Kocaeli': {'lat': 40.8533, 'lon': 29.8815},
    'Konya': {'lat': 37.8667, 'lon': 32.4833},
    'Kütahya': {'lat': 39.4167, 'lon': 29.9833},
    'Malatya': {'lat': 38.3552, 'lon': 38.3095},
    'Manisa': {'lat': 38.6191, 'lon': 27.4289},
    'Mardin': {'lat': 37.3212, 'lon': 40.7245},
    'Mersin': {'lat': 36.8000, 'lon': 34.6333},
    'Muğla': {'lat': 37.2153, 'lon': 28.3636},
    'Muş': {'lat': 38.9462, 'lon': 41.7539},
    'Nevşehir': {'lat': 38.6939, 'lon': 34.6857},
    'Niğde': {'lat': 37.9667, 'lon': 34.6833},
    'Ordu': {'lat': 40.9839, 'lon': 37.8764},
    'Osmaniye': {'lat': 37.2130, 'lon': 36.1763},
    'Rize': {'lat': 41.0201, 'lon': 40.5234},
    'Sakarya': {'lat': 40.6940, 'lon': 30.4358},
    'Samsun': {'lat': 41.2867, 'lon': 36.3300},
    'Siirt': {'lat': 37.9333, 'lon': 41.9500},
    'Sinop': {'lat': 42.0231, 'lon': 35.1531},
    'Sivas': {'lat': 39.7477, 'lon': 37.0179},
    'Şanlıurfa': {'lat': 37.1591, 'lon': 38.7969},
    'Şırnak': {'lat': 37.4187, 'lon': 42.4918},
    'Tekirdağ': {'lat': 40.9833, 'lon': 27.5167},
    'Tokat': {'lat': 40.3167, 'lon': 36.5500},
    'Trabzon': {'lat': 41.0015, 'lon': 39.7178},
    'Tunceli': {'lat': 39.1079, 'lon': 39.5401},
    'Uşak': {'lat': 38.6823, 'lon': 29.4082},
    'Van': {'lat': 38.4891, 'lon': 43.4089},
    'Yalova': {'lat': 40.6500, 'lon': 29.2667},
    'Yozgat': {'lat': 39.8181, 'lon': 34.8147},
    'Zonguldak': {'lat': 41.4564, 'lon': 31.7987},
  };

  /// Belirli bir konum etrafındaki camileri OpenStreetMap'ten çek
  Future<List<Mosque>> fetchMosquesNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) async {
    try {
      // Overpass QL sorgusu - camileri çek
      final query = '''
[out:json][timeout:25];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:${radiusKm * 1000},$latitude,$longitude);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:${radiusKm * 1000},$latitude,$longitude);
  node["building"="mosque"](around:${radiusKm * 1000},$latitude,$longitude);
  way["building"="mosque"](around:${radiusKm * 1000},$latitude,$longitude);
);
out center;
''';

      final response = await _dio.post(
        _overpassUrl,
        data: query,
        options: Options(
          contentType: 'text/plain',
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final elements = data['elements'] as List<dynamic>;
        
        return elements.map((element) => _parseOsmElement(element, latitude, longitude)).toList();
      }
      
      return [];
    } catch (e) {
      print('Cami verileri çekilirken hata: $e');
      return [];
    }
  }

  /// Belirli bir il için camileri çek
  Future<List<Mosque>> fetchMosquesByProvince(String provinceName, {double radiusKm = 15}) async {
    final province = turkeyProvinces[provinceName];
    if (province == null) return [];

    return fetchMosquesNearby(
      latitude: province['lat']!,
      longitude: province['lon']!,
      radiusKm: radiusKm,
    );
  }

  /// Belirli bir ilçe için camileri çek (ilçe koordinatları ile)
  Future<List<Mosque>> fetchMosquesByDistrict({
    required double latitude,
    required double longitude,
    double radiusKm = 5,
  }) async {
    return fetchMosquesNearby(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }

  /// OSM element'ini Mosque modeline dönüştür
  Mosque _parseOsmElement(Map<String, dynamic> element, double userLat, double userLon) {
    final tags = element['tags'] as Map<String, dynamic>? ?? {};
    
    // Koordinatları al
    double lat, lon;
    if (element['type'] == 'node') {
      lat = (element['lat'] as num).toDouble();
      lon = (element['lon'] as num).toDouble();
    } else {
      // Way için center koordinatlarını kullan
      final center = element['center'] as Map<String, dynamic>?;
      lat = (center?['lat'] as num?)?.toDouble() ?? 0;
      lon = (center?['lon'] as num?)?.toDouble() ?? 0;
    }

    // Mesafeyi hesapla
    final distance = Geolocator.distanceBetween(userLat, userLon, lat, lon) / 1000;

    // Cami adını belirle
    String name = tags['name'] ?? 
                  tags['name:tr'] ?? 
                  tags['alt_name'] ?? 
                  'Cami';

    // Adresi oluştur
    String address = _buildAddress(tags);

    // İmkanları belirle (OSM tag'lerinden)
    List<MosqueAmenity> amenities = _parseAmenities(tags);

    return Mosque(
      id: 'osm_${element['id']}',
      name: name,
      latitude: lat,
      longitude: lon,
      address: address.isNotEmpty ? address : 'Adres bilgisi yok',
      amenities: amenities,
      distanceInKm: distance,
      averageRating: 0,
      totalRatings: 0,
      isVerified: false,
    );
  }

  /// Adres bilgisini oluştur
  String _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[];
    
    if (tags['addr:street'] != null) {
      parts.add(tags['addr:street']);
    }
    if (tags['addr:housenumber'] != null) {
      parts.add('No: ${tags['addr:housenumber']}');
    }
    if (tags['addr:district'] != null || tags['addr:suburb'] != null) {
      parts.add(tags['addr:district'] ?? tags['addr:suburb']);
    }
    if (tags['addr:city'] != null) {
      parts.add(tags['addr:city']);
    }
    if (tags['addr:province'] != null) {
      parts.add(tags['addr:province']);
    }

    return parts.join(', ');
  }

  /// OSM tag'lerinden imkanları çıkar
  List<MosqueAmenity> _parseAmenities(Map<String, dynamic> tags) {
    final amenities = <MosqueAmenity>[];

    // Kadınlar bölümü
    if (tags['female'] == 'yes' || tags['women'] == 'yes') {
      amenities.add(MosqueAmenity.womensSection);
    }

    // Engelli erişimi
    if (tags['wheelchair'] == 'yes' || tags['wheelchair'] == 'limited') {
      amenities.add(MosqueAmenity.disabledAccess);
    }

    // Otopark
    if (tags['parking'] != null || tags['amenity'] == 'parking') {
      amenities.add(MosqueAmenity.parking);
    }

    // Tuvalet
    if (tags['toilets'] == 'yes' || tags['toilet'] == 'yes') {
      amenities.add(MosqueAmenity.cleanToilet);
    }

    // Abdesthane (genellikle camilerde var)
    amenities.add(MosqueAmenity.wuduArea);

    // Cuma namazı (ana camiler için)
    if (tags['denomination'] == 'sunni' || 
        (tags['name']?.toString().toLowerCase().contains('ulu') ?? false) ||
        (tags['name']?.toString().toLowerCase().contains('merkez') ?? false)) {
      amenities.add(MosqueAmenity.fridayPrayer);
    }

    return amenities;
  }

  /// Tüm Türkiye illerinin listesini döndür
  List<String> getAllProvinces() {
    return turkeyProvinces.keys.toList()..sort();
  }

  /// Kullanılabilir illerin listesini döndür (getAllProvinces ile aynı)
  List<String> getAvailableProvinces() {
    return getAllProvinces();
  }

  /// Kullanıcının konumuna en yakın ili bul
  String? findNearestProvince(double latitude, double longitude) {
    String? nearest;
    double minDistance = double.infinity;

    for (final entry in turkeyProvinces.entries) {
      final distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        entry.value['lat']!,
        entry.value['lon']!,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearest = entry.key;
      }
    }

    return nearest;
  }
}
