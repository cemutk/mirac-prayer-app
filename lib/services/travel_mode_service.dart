import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Seferi (Yolcu) Modu Durumu
enum TravelStatus {
  resident,  // Mukim - ikamet yerinde
  traveler,  // Seferi - 90km+ uzakta
  unknown,   // Bilinmiyor
}

/// Seferi modundaki namaz bilgileri
class TravelPrayerInfo {
  final String prayerName;
  final int normalRakats;
  final int travelRakats;
  final bool canBeShortened;
  final String description;

  const TravelPrayerInfo({
    required this.prayerName,
    required this.normalRakats,
    required this.travelRakats,
    required this.canBeShortened,
    required this.description,
  });
}

/// Akıllı Seferi Modu Servisi
/// Kullanıcının seyahat durumunu otomatik algılar ve namaz vakitlerini günceller
class TravelModeService extends ChangeNotifier {
  static const String _homeLatKey = 'home_latitude';
  static const String _homeLonKey = 'home_longitude';
  static const String _homeAddressKey = 'home_address';
  static const String _travelModeEnabledKey = 'travel_mode_enabled';
  static const String _autoDetectKey = 'travel_auto_detect';
  static const String _isTravelingKey = 'is_traveling';
  static const String _lastCheckTimeKey = 'last_travel_check';

  // Seferilik mesafesi (km)
  static const double travelDistanceThreshold = 90.0;
  
  // Konum kontrol aralığı (dakika)
  static const int checkIntervalMinutes = 15;

  // Singleton pattern
  static final TravelModeService _instance = TravelModeService._internal();
  factory TravelModeService() => _instance;
  TravelModeService._internal();

  SharedPreferences? _prefs;
  Timer? _locationCheckTimer;
  StreamSubscription<Position>? _positionStream;
  
  // State
  double? _homeLatitude;
  double? _homeLongitude;
  String? _homeAddress;
  bool _travelModeEnabled = false;
  bool _autoDetectEnabled = true;
  bool _isTraveling = false;
  double? _currentDistanceFromHome;
  Position? _currentPosition;
  TravelStatus _status = TravelStatus.unknown;

  // Getters
  double? get homeLatitude => _homeLatitude;
  double? get homeLongitude => _homeLongitude;
  String? get homeAddress => _homeAddress;
  bool get travelModeEnabled => _travelModeEnabled;
  bool get autoDetectEnabled => _autoDetectEnabled;
  bool get isTraveling => _isTraveling;
  double? get currentDistanceFromHome => _currentDistanceFromHome;
  Position? get currentPosition => _currentPosition;
  TravelStatus get status => _status;
  bool get hasHomeLocation => _homeLatitude != null && _homeLongitude != null;

  /// Servisi başlat
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
    
    if (_autoDetectEnabled && hasHomeLocation) {
      await _startLocationTracking();
    }
  }

  /// Ayarları yükle
  Future<void> _loadSettings() async {
    _homeLatitude = _prefs?.getDouble(_homeLatKey);
    _homeLongitude = _prefs?.getDouble(_homeLonKey);
    _homeAddress = _prefs?.getString(_homeAddressKey);
    _travelModeEnabled = _prefs?.getBool(_travelModeEnabledKey) ?? false;
    _autoDetectEnabled = _prefs?.getBool(_autoDetectKey) ?? true;
    _isTraveling = _prefs?.getBool(_isTravelingKey) ?? false;
    
    _updateStatus();
    notifyListeners();
  }

  /// Durumu güncelle
  void _updateStatus() {
    if (!hasHomeLocation) {
      _status = TravelStatus.unknown;
    } else if (_isTraveling) {
      _status = TravelStatus.traveler;
    } else {
      _status = TravelStatus.resident;
    }
  }

  /// Ev konumunu kaydet
  Future<void> setHomeLocation({
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    _homeLatitude = latitude;
    _homeLongitude = longitude;
    _homeAddress = address;
    
    await _prefs?.setDouble(_homeLatKey, latitude);
    await _prefs?.setDouble(_homeLonKey, longitude);
    if (address != null) {
      await _prefs?.setString(_homeAddressKey, address);
    }
    
    // Ev konumu ayarlandıysa seferi durumunu kontrol et
    await checkTravelStatus();
    notifyListeners();
  }

  /// Mevcut konumu ev olarak ayarla
  Future<bool> setCurrentLocationAsHome() async {
    try {
      final position = await _getCurrentPosition();
      if (position != null) {
        await setHomeLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          address: 'Mevcut Konum',
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Ev konumu ayarlanamadı: $e');
      return false;
    }
  }

  /// Ev konumunu sil
  Future<void> clearHomeLocation() async {
    _homeLatitude = null;
    _homeLongitude = null;
    _homeAddress = null;
    _isTraveling = false;
    _currentDistanceFromHome = null;
    
    await _prefs?.remove(_homeLatKey);
    await _prefs?.remove(_homeLonKey);
    await _prefs?.remove(_homeAddressKey);
    await _prefs?.setBool(_isTravelingKey, false);
    
    _updateStatus();
    notifyListeners();
  }

  /// Otomatik algılamayı aç/kapat
  Future<void> setAutoDetect(bool enabled) async {
    _autoDetectEnabled = enabled;
    await _prefs?.setBool(_autoDetectKey, enabled);
    
    if (enabled && hasHomeLocation) {
      await _startLocationTracking();
    } else {
      _stopLocationTracking();
    }
    
    notifyListeners();
  }

  /// Manuel olarak seferi modunu aç/kapat
  Future<void> setTravelMode(bool traveling) async {
    _isTraveling = traveling;
    await _prefs?.setBool(_isTravelingKey, traveling);
    
    _updateStatus();
    notifyListeners();
  }

  /// Konum takibini başlat
  Future<void> _startLocationTracking() async {
    // Periyodik kontrol timer'ı
    _locationCheckTimer?.cancel();
    _locationCheckTimer = Timer.periodic(
      Duration(minutes: checkIntervalMinutes),
      (_) => checkTravelStatus(),
    );
    
    // İlk kontrolü yap
    await checkTravelStatus();
  }

  /// Konum takibini durdur
  void _stopLocationTracking() {
    _locationCheckTimer?.cancel();
    _locationCheckTimer = null;
    _positionStream?.cancel();
    _positionStream = null;
  }

  /// Mevcut konumu al
  Future<Position?> _getCurrentPosition() async {
    try {
      // İzin kontrolü
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Konum al
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (e) {
      print('Konum alınamadı: $e');
      return null;
    }
  }

  /// Seferi durumunu kontrol et
  Future<TravelCheckResult> checkTravelStatus() async {
    if (!hasHomeLocation) {
      return TravelCheckResult(
        success: false,
        message: 'Ev konumu ayarlanmamış',
      );
    }

    final position = await _getCurrentPosition();
    if (position == null) {
      return TravelCheckResult(
        success: false,
        message: 'Konum alınamadı',
      );
    }

    _currentPosition = position;
    
    // Mesafeyi hesapla
    _currentDistanceFromHome = _calculateDistance(
      _homeLatitude!,
      _homeLongitude!,
      position.latitude,
      position.longitude,
    );

    final wasTraveling = _isTraveling;
    final isNowTraveling = _currentDistanceFromHome! >= travelDistanceThreshold;
    
    // Durum değişti mi?
    if (wasTraveling != isNowTraveling) {
      _isTraveling = isNowTraveling;
      await _prefs?.setBool(_isTravelingKey, isNowTraveling);
      _updateStatus();
      notifyListeners();
      
      return TravelCheckResult(
        success: true,
        statusChanged: true,
        isTraveling: isNowTraveling,
        distance: _currentDistanceFromHome!,
        message: isNowTraveling 
            ? 'Seferi durumuna geçtiniz (${_currentDistanceFromHome!.toStringAsFixed(1)} km)'
            : 'Mukim durumuna döndünüz',
      );
    }

    await _prefs?.setInt(_lastCheckTimeKey, DateTime.now().millisecondsSinceEpoch);
    notifyListeners();
    
    return TravelCheckResult(
      success: true,
      statusChanged: false,
      isTraveling: _isTraveling,
      distance: _currentDistanceFromHome!,
      message: 'Durum değişmedi',
    );
  }

  /// İki nokta arasındaki mesafeyi hesapla (Haversine formülü)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
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

  /// Seferi modunda namaz bilgilerini al
  List<TravelPrayerInfo> getTravelPrayerInfo() {
    return const [
      TravelPrayerInfo(
        prayerName: 'Sabah',
        normalRakats: 2,
        travelRakats: 2,
        canBeShortened: false,
        description: 'Sabah namazı kısaltılmaz, 2 rekat farz olarak kılınır.',
      ),
      TravelPrayerInfo(
        prayerName: 'Öğle',
        normalRakats: 4,
        travelRakats: 2,
        canBeShortened: true,
        description: 'Öğle namazı seferde 2 rekat olarak kılınır. Sünnetler terk edilebilir.',
      ),
      TravelPrayerInfo(
        prayerName: 'İkindi',
        normalRakats: 4,
        travelRakats: 2,
        canBeShortened: true,
        description: 'İkindi namazı seferde 2 rekat olarak kılınır.',
      ),
      TravelPrayerInfo(
        prayerName: 'Akşam',
        normalRakats: 3,
        travelRakats: 3,
        canBeShortened: false,
        description: 'Akşam namazı kısaltılmaz, 3 rekat farz olarak kılınır.',
      ),
      TravelPrayerInfo(
        prayerName: 'Yatsı',
        normalRakats: 4,
        travelRakats: 2,
        canBeShortened: true,
        description: 'Yatsı namazı seferde 2 rekat olarak kılınır. Vitir namazı kılınabilir.',
      ),
    ];
  }

  /// Namazları birleştirme (Cem) bilgisi
  String getCemInfo() {
    return '''
📖 Namazları Birleştirme (Cem)

Hanefi mezhebine göre:
• Namazları birleştirmek (cem) caiz değildir
• Her namaz kendi vaktinde kılınmalıdır
• Sadece Arafat ve Müzdelife'de cem yapılabilir

Şafii, Maliki ve Hanbeli mezheplerine göre:
• Öğle ile İkindi birleştirilebilir (Cem-i Takdim veya Cem-i Te'hir)
• Akşam ile Yatsı birleştirilebilir
• Seferde kolaylık sağlamak için caizdir

⚠️ Kendi mezhebinizin hükümlerine göre amel ediniz.
''';
  }

  /// Seferilik süre bilgisi
  String getTravelDurationInfo() {
    return '''
📅 Seferilik Süresi

• Bir yerde 15 günden az kalmayı niyet eden kişi seferi sayılır
• 15 gün veya daha fazla kalmayı niyet eden kişi mukim (yerleşik) sayılır
• Yolculuk süresince seferi hükümleri geçerlidir

🕌 Seferi Namazları:
• 4 rekatlık farz namazlar 2 rekat olarak kılınır
• 2 ve 3 rekatlık namazlar kısaltılmaz
• Sünnet namazlar terk edilebilir (Sabah sünneti müstehaptır)

🍽️ Oruç:
• Seferde oruç tutmamak ruhsattır
• Tutulmayan oruçlar sonra kaza edilir
''';
  }

  /// Dispose
  @override
  void dispose() {
    _stopLocationTracking();
    super.dispose();
  }
}

/// Seferi kontrol sonucu
class TravelCheckResult {
  final bool success;
  final bool statusChanged;
  final bool? isTraveling;
  final double? distance;
  final String message;

  TravelCheckResult({
    required this.success,
    this.statusChanged = false,
    this.isTraveling,
    this.distance,
    required this.message,
  });
}
