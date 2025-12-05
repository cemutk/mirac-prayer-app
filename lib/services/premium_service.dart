import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage Premium/Freemium features
/// Handles subscription status and feature access control
class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  static const String _premiumKey = 'is_premium_user';
  static const String _purchaseDateKey = 'premium_purchase_date';
  static const String _expiryDateKey = 'premium_expiry_date';

  /// Check if user is Premium subscriber
  Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool(_premiumKey) ?? false;
    
    // Check if subscription is still valid
    if (isPremium) {
      final expiryTimestamp = prefs.getInt(_expiryDateKey);
      if (expiryTimestamp != null) {
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
        if (DateTime.now().isAfter(expiryDate)) {
          // Subscription expired
          await setPremiumStatus(false);
          return false;
        }
      }
    }
    
    return isPremium;
  }

  /// Set premium status (for testing or after successful purchase)
  Future<void> setPremiumStatus(bool isPremium, {DateTime? expiryDate}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, isPremium);
    
    if (isPremium) {
      await prefs.setInt(_purchaseDateKey, DateTime.now().millisecondsSinceEpoch);
      
      // Default: 30 days subscription
      final expiry = expiryDate ?? DateTime.now().add(const Duration(days: 30));
      await prefs.setInt(_expiryDateKey, expiry.millisecondsSinceEpoch);
    } else {
      await prefs.remove(_purchaseDateKey);
      await prefs.remove(_expiryDateKey);
    }
  }

  /// Get premium expiry date
  Future<DateTime?> getExpiryDate() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTimestamp = prefs.getInt(_expiryDateKey);
    if (expiryTimestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
    }
    return null;
  }

  /// Get premium purchase date
  Future<DateTime?> getPurchaseDate() async {
    final prefs = await SharedPreferences.getInstance();
    final purchaseTimestamp = prefs.getInt(_purchaseDateKey);
    if (purchaseTimestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(purchaseTimestamp);
    }
    return null;
  }

  /// Check if specific feature is accessible
  Future<bool> canAccessFeature(PremiumFeature feature) async {
    // Free features are always accessible
    if (_freeFeatures.contains(feature)) {
      return true;
    }
    
    // Premium features require subscription
    return await isPremium();
  }

  /// Get list of all premium features
  static const List<PremiumFeature> _freeFeatures = [
    PremiumFeature.prayerTimes,
    PremiumFeature.standardQibla,
    PremiumFeature.quran,
    PremiumFeature.tasbih,
    PremiumFeature.mosqueLocator,
    PremiumFeature.basicSettings,
  ];

  static const List<PremiumFeature> premiumFeatures = [
    PremiumFeature.arQibla,
    PremiumFeature.travelMode,
    PremiumFeature.mosqueDND,
    PremiumFeature.halalChecker,
    PremiumFeature.kidsMode,
    PremiumFeature.themes,
    PremiumFeature.fullStatistics,
  ];

  /// Get feature name for display
  static String getFeatureName(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.arQibla:
        return 'AR Kıble Modu';
      case PremiumFeature.travelMode:
        return 'Akıllı Seferi Mod';
      case PremiumFeature.mosqueDND:
        return 'Cami Modu (Oto-Sessiz)';
      case PremiumFeature.halalChecker:
        return 'Helal Gıda Kontrolü';
      case PremiumFeature.kidsMode:
        return 'Çocuk Modu';
      case PremiumFeature.themes:
        return 'Görünüm/Temalar';
      case PremiumFeature.fullStatistics:
        return 'İstatistik Geçmişi';
      case PremiumFeature.prayerTimes:
        return 'Ana Ekran (Vakitler)';
      case PremiumFeature.standardQibla:
        return 'Standart Kıble';
      case PremiumFeature.quran:
        return 'Kur\'an-ı Kerim';
      case PremiumFeature.tasbih:
        return 'Tesbih';
      case PremiumFeature.mosqueLocator:
        return 'Cami Bulucu';
      case PremiumFeature.basicSettings:
        return 'Ayarlar';
    }
  }

  /// Get feature description
  static String getFeatureDescription(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.arQibla:
        return 'Kameranızla AR teknolojisiyle Kabe\'yi görün';
      case PremiumFeature.travelMode:
        return 'Seyahatte otomatik kısa namaz sürelerine geç';
      case PremiumFeature.mosqueDND:
        return 'Camideyken telefonu otomatik sessiz yap';
      case PremiumFeature.halalChecker:
        return 'Barkod tarayarak E-kodları ve helal ürünleri kontrol et';
      case PremiumFeature.kidsMode:
        return 'Çocuklar için oyunlaştırılmış namaz öğrenme';
      case PremiumFeature.themes:
        return 'Uygulama renklerini ve temalarını özelleştir';
      case PremiumFeature.fullStatistics:
        return 'Geçmiş ibadet verilerinizi görüntüle';
      case PremiumFeature.prayerTimes:
        return 'Geri sayım, İmsakiye, Günlük İbadet Takibi';
      case PremiumFeature.standardQibla:
        return 'Pusula görünümü (2D)';
      case PremiumFeature.quran:
        return 'Tüm sureleri okuma ve dinleme';
      case PremiumFeature.tasbih:
        return 'Zikir çekme ve anlık sayaç';
      case PremiumFeature.mosqueLocator:
        return 'Haritada en yakın camileri görme';
      case PremiumFeature.basicSettings:
        return 'Bildirimleri açıp kapatma';
    }
  }

  /// Get feature icon
  static String getFeatureIcon(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.arQibla:
        return '📱';
      case PremiumFeature.travelMode:
        return '✈️';
      case PremiumFeature.mosqueDND:
        return '🔇';
      case PremiumFeature.halalChecker:
        return '🏷️';
      case PremiumFeature.kidsMode:
        return '👶';
      case PremiumFeature.themes:
        return '🎨';
      case PremiumFeature.fullStatistics:
        return '📊';
      case PremiumFeature.prayerTimes:
        return '🕌';
      case PremiumFeature.standardQibla:
        return '🧭';
      case PremiumFeature.quran:
        return '📖';
      case PremiumFeature.tasbih:
        return '📿';
      case PremiumFeature.mosqueLocator:
        return '🗺️';
      case PremiumFeature.basicSettings:
        return '⚙️';
    }
  }
}

/// Enum for all app features
enum PremiumFeature {
  // Free features
  prayerTimes,
  standardQibla,
  quran,
  tasbih,
  mosqueLocator,
  basicSettings,
  
  // Premium features (🔒)
  arQibla,
  travelMode,
  mosqueDND,
  halalChecker,
  kidsMode,
  themes,
  fullStatistics,
}
