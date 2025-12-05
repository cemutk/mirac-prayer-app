import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math' as math;

/// Cami Modu (Rahatsız Etme Modu) Servisi
/// Namaz vakitlerinde veya camiye yaklaşıldığında otomatik sessiz mod
class DoNotDisturbService extends ChangeNotifier {
  static final DoNotDisturbService _instance = DoNotDisturbService._internal();
  factory DoNotDisturbService() => _instance;
  DoNotDisturbService._internal();

  static const MethodChannel _channel = MethodChannel('com.miracapp.namazvakti/dnd');
  
  // Ayarlar
  bool _isEnabled = false;
  bool _enableForPrayerTimes = true;
  bool _enableForMosqueProximity = false;
  int _durationMinutes = 30; // Namaz süresi (dakika)
  int _mosquetDetectionRadius = 100; // Cami algılama yarıçapı (metre)
  String _soundMode = 'silent'; // silent, vibrate
  bool _autoRestore = true; // Süre sonunda sesi geri aç
  
  // Durum
  bool _isCurrentlyActive = false;
  DateTime? _activatedAt;
  DateTime? _willDeactivateAt;
  String? _activationReason;
  int? _previousRingerMode;
  Timer? _deactivationTimer;
  StreamSubscription<Position>? _locationSubscription;
  
  // Kayıtlı cami konumları
  List<MosqueLocation> _savedMosques = [];
  
  // Getters
  bool get isEnabled => _isEnabled;
  bool get enableForPrayerTimes => _enableForPrayerTimes;
  bool get enableForMosqueProximity => _enableForMosqueProximity;
  int get durationMinutes => _durationMinutes;
  int get mosqueDetectionRadius => _mosquetDetectionRadius;
  String get soundMode => _soundMode;
  bool get autoRestore => _autoRestore;
  bool get isCurrentlyActive => _isCurrentlyActive;
  DateTime? get activatedAt => _activatedAt;
  DateTime? get willDeactivateAt => _willDeactivateAt;
  String? get activationReason => _activationReason;
  List<MosqueLocation> get savedMosques => _savedMosques;

  /// Servisi başlat
  Future<void> initialize() async {
    await _loadSettings();
    if (_isEnabled && _enableForMosqueProximity) {
      await _startLocationMonitoring();
    }
    notifyListeners();
  }

  /// Ayarları yükle
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool('dnd_enabled') ?? false;
      _enableForPrayerTimes = prefs.getBool('dnd_prayer_times') ?? true;
      _enableForMosqueProximity = prefs.getBool('dnd_mosque_proximity') ?? false;
      _durationMinutes = prefs.getInt('dnd_duration') ?? 30;
      _mosquetDetectionRadius = prefs.getInt('dnd_mosque_radius') ?? 100;
      _soundMode = prefs.getString('dnd_sound_mode') ?? 'silent';
      _autoRestore = prefs.getBool('dnd_auto_restore') ?? true;
      
      // Kayıtlı camileri yükle
      final mosquesJson = prefs.getStringList('dnd_saved_mosques') ?? [];
      _savedMosques = mosquesJson.map((json) => MosqueLocation.fromJson(json)).toList();
    } catch (e) {
      debugPrint('DoNotDisturbService: Ayarlar yüklenemedi: $e');
    }
  }

  /// Ayarları kaydet
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dnd_enabled', _isEnabled);
      await prefs.setBool('dnd_prayer_times', _enableForPrayerTimes);
      await prefs.setBool('dnd_mosque_proximity', _enableForMosqueProximity);
      await prefs.setInt('dnd_duration', _durationMinutes);
      await prefs.setInt('dnd_mosque_radius', _mosquetDetectionRadius);
      await prefs.setString('dnd_sound_mode', _soundMode);
      await prefs.setBool('dnd_auto_restore', _autoRestore);
      
      // Camileri kaydet
      final mosquesJson = _savedMosques.map((m) => m.toJson()).toList();
      await prefs.setStringList('dnd_saved_mosques', mosquesJson);
    } catch (e) {
      debugPrint('DoNotDisturbService: Ayarlar kaydedilemedi: $e');
    }
  }

  /// Ana özelliği aç/kapat
  Future<void> setEnabled(bool value) async {
    _isEnabled = value;
    await _saveSettings();
    
    if (value && _enableForMosqueProximity) {
      await _startLocationMonitoring();
    } else if (!value) {
      await _stopLocationMonitoring();
      if (_isCurrentlyActive) {
        await deactivate();
      }
    }
    notifyListeners();
  }

  /// Namaz vakitlerinde aktifleştirmeyi aç/kapat
  Future<void> setEnableForPrayerTimes(bool value) async {
    _enableForPrayerTimes = value;
    await _saveSettings();
    notifyListeners();
  }

  /// Cami yakınlığında aktifleştirmeyi aç/kapat
  Future<void> setEnableForMosqueProximity(bool value) async {
    _enableForMosqueProximity = value;
    await _saveSettings();
    
    if (_isEnabled && value) {
      await _startLocationMonitoring();
    } else {
      await _stopLocationMonitoring();
    }
    notifyListeners();
  }

  /// Süreyi ayarla
  Future<void> setDurationMinutes(int minutes) async {
    _durationMinutes = minutes;
    await _saveSettings();
    notifyListeners();
  }

  /// Cami algılama yarıçapını ayarla
  Future<void> setMosqueDetectionRadius(int meters) async {
    _mosquetDetectionRadius = meters;
    await _saveSettings();
    notifyListeners();
  }

  /// Ses modunu ayarla (silent/vibrate)
  Future<void> setSoundMode(String mode) async {
    _soundMode = mode;
    await _saveSettings();
    notifyListeners();
  }

  /// Otomatik geri yüklemeyi ayarla
  Future<void> setAutoRestore(bool value) async {
    _autoRestore = value;
    await _saveSettings();
    notifyListeners();
  }

  /// Cami Modunu aktifleştir
  Future<bool> activate({String reason = 'Manuel'}) async {
    if (_isCurrentlyActive) return true;
    
    try {
      // Mevcut ses modunu kaydet
      _previousRingerMode = await _getCurrentRingerMode();
      
      // Sessiz veya titreşim moduna geç
      final success = await _setRingerMode(_soundMode == 'silent' ? 0 : 1);
      
      if (success) {
        _isCurrentlyActive = true;
        _activatedAt = DateTime.now();
        _activationReason = reason;
        
        // Otomatik deaktivasyonunu zamanla
        if (_autoRestore) {
          _willDeactivateAt = DateTime.now().add(Duration(minutes: _durationMinutes));
          _deactivationTimer?.cancel();
          _deactivationTimer = Timer(Duration(minutes: _durationMinutes), () {
            deactivate();
          });
        }
        
        notifyListeners();
        debugPrint('🔇 Cami Modu aktifleştirildi: $reason');
        return true;
      }
    } catch (e) {
      debugPrint('DoNotDisturbService: Aktifleştirme hatası: $e');
    }
    return false;
  }

  /// Cami Modunu deaktifleştir
  Future<bool> deactivate() async {
    if (!_isCurrentlyActive) return true;
    
    try {
      _deactivationTimer?.cancel();
      _deactivationTimer = null;
      
      // Önceki ses moduna geri dön
      if (_previousRingerMode != null && _autoRestore) {
        await _setRingerMode(_previousRingerMode!);
      }
      
      _isCurrentlyActive = false;
      _activatedAt = null;
      _willDeactivateAt = null;
      _activationReason = null;
      _previousRingerMode = null;
      
      notifyListeners();
      debugPrint('🔔 Cami Modu deaktifleştirildi');
      return true;
    } catch (e) {
      debugPrint('DoNotDisturbService: Deaktifleştirme hatası: $e');
    }
    return false;
  }

  /// Namaz vakti için çağrılır (NotificationService'den)
  Future<void> onPrayerTimeStarted(String prayerName) async {
    if (!_isEnabled || !_enableForPrayerTimes) return;
    
    await activate(reason: '$prayerName vakti');
  }

  /// Konum izlemeyi başlat
  Future<void> _startLocationMonitoring() async {
    await _stopLocationMonitoring();
    
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        return;
      }
      
      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 50, // 50 metre hareket olduğunda güncelle
        ),
      ).listen(_onLocationUpdate);
      
      debugPrint('📍 Cami yakınlığı izleme başlatıldı');
    } catch (e) {
      debugPrint('DoNotDisturbService: Konum izleme hatası: $e');
    }
  }

  /// Konum izlemeyi durdur
  Future<void> _stopLocationMonitoring() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  /// Konum güncellemesi
  void _onLocationUpdate(Position position) {
    if (!_isEnabled || !_enableForMosqueProximity) return;
    
    // Kayıtlı camilerle mesafe kontrolü
    for (final mosque in _savedMosques) {
      final distance = _calculateDistance(
        position.latitude,
        position.longitude,
        mosque.latitude,
        mosque.longitude,
      );
      
      if (distance <= _mosquetDetectionRadius) {
        if (!_isCurrentlyActive) {
          activate(reason: '${mosque.name} yakınında');
        }
        return;
      }
    }
    
    // Camiden uzaklaştıysa ve aktifse, deaktifleştir
    if (_isCurrentlyActive && _activationReason?.contains('yakınında') == true) {
      deactivate();
    }
  }

  /// Haversine formülü ile mesafe hesapla (metre)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0; // Dünya yarıçapı (metre)
    final phi1 = lat1 * math.pi / 180;
    final phi2 = lat2 * math.pi / 180;
    final deltaPhi = (lat2 - lat1) * math.pi / 180;
    final deltaLambda = (lon2 - lon1) * math.pi / 180;
    
    final a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) * math.cos(phi2) *
        math.sin(deltaLambda / 2) * math.sin(deltaLambda / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return R * c;
  }

  /// Cami kaydet
  Future<void> addMosque(MosqueLocation mosque) async {
    _savedMosques.add(mosque);
    await _saveSettings();
    notifyListeners();
  }

  /// Cami sil
  Future<void> removeMosque(int index) async {
    if (index >= 0 && index < _savedMosques.length) {
      _savedMosques.removeAt(index);
      await _saveSettings();
      notifyListeners();
    }
  }

  /// Mevcut konumu cami olarak kaydet
  Future<bool> saveCurrentLocationAsMosque(String name) async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final mosque = MosqueLocation(
        name: name,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      await addMosque(mosque);
      return true;
    } catch (e) {
      debugPrint('DoNotDisturbService: Konum kaydedilemedi: $e');
      return false;
    }
  }

  /// Native: Mevcut zil modunu al
  Future<int?> _getCurrentRingerMode() async {
    try {
      final result = await _channel.invokeMethod<int>('getRingerMode');
      return result;
    } catch (e) {
      debugPrint('DoNotDisturbService: Zil modu alınamadı: $e');
      return null;
    }
  }

  /// Native: Zil modunu ayarla
  /// 0 = Sessiz, 1 = Titreşim, 2 = Normal
  Future<bool> _setRingerMode(int mode) async {
    try {
      final result = await _channel.invokeMethod<bool>('setRingerMode', {'mode': mode});
      return result ?? false;
    } catch (e) {
      debugPrint('DoNotDisturbService: Zil modu ayarlanamadı: $e');
      return false;
    }
  }

  /// DND izni kontrol et
  Future<bool> checkDndPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkDndPermission');
      return result ?? false;
    } catch (e) {
      debugPrint('DoNotDisturbService: İzin kontrolü hatası: $e');
      return false;
    }
  }

  /// DND izni iste
  Future<void> requestDndPermission() async {
    try {
      await _channel.invokeMethod<void>('requestDndPermission');
    } catch (e) {
      debugPrint('DoNotDisturbService: İzin isteme hatası: $e');
    }
  }

  /// Kalan süre (saniye)
  int get remainingSeconds {
    if (!_isCurrentlyActive || _willDeactivateAt == null) return 0;
    final remaining = _willDeactivateAt!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Kalan süre formatlanmış
  String get remainingTimeFormatted {
    final seconds = remainingSeconds;
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _deactivationTimer?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }
}

/// Kayıtlı cami konumu
class MosqueLocation {
  final String name;
  final double latitude;
  final double longitude;

  MosqueLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  String toJson() => '$name|$latitude|$longitude';

  factory MosqueLocation.fromJson(String json) {
    final parts = json.split('|');
    return MosqueLocation(
      name: parts[0],
      latitude: double.parse(parts[1]),
      longitude: double.parse(parts[2]),
    );
  }
}
