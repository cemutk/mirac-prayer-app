import 'package:flutter/foundation.dart';
import 'premium_service.dart';

/// Service to manage advertisements
/// DISABLED: google_mobile_ads removed due to iOS crash (invalid GADApplicationIdentifier)
/// Re-enable when real AdMob App ID is configured
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  final PremiumService _premiumService = PremiumService();
  
  bool _isInitialized = false;

  /// Initialize Ads - DISABLED
  Future<void> initialize() async {
    debugPrint('🎯 [AdService] AdMob disabled - no SDK compiled');
    _isInitialized = true;
  }

  /// Check if ads are available - always false (disabled)
  bool get isAdsEnabled => false;

  /// Create and load a Banner Ad - DISABLED
  /// Returns null (ads disabled)
  Future<dynamic> createBannerAd({dynamic size}) async {
    // Don't show ads to premium users anyway
    if (await _premiumService.isPremium()) {
      debugPrint('🎯 [AdService] User is premium - skipping banner ad');
      return null;
    }
    
    debugPrint('🎯 [AdService] Ads disabled - returning null');
    return null;
  }

  /// Load an Interstitial Ad - DISABLED
  Future<void> loadInterstitialAd() async {
    // Don't load ads for premium users anyway
    if (await _premiumService.isPremium()) {
      debugPrint('🎯 [AdService] User is premium - skipping interstitial ad');
      return;
    }
    
    debugPrint('🎯 [AdService] Ads disabled - not loading');
  }

  /// Show Interstitial Ad - DISABLED
  /// Returns false (no ad to show)
  Future<bool> showInterstitialAd() async {
    // Don't show ads to premium users anyway
    if (await _premiumService.isPremium()) {
      debugPrint('🎯 [AdService] User is premium - skipping interstitial ad');
      return false;
    }

    debugPrint('🎯 [AdService] Ads disabled - not showing');
    return false;
  }

  /// Check if interstitial ad is ready - always false (disabled)
  bool get isInterstitialAdReady => false;

  /// Dispose all ads - DISABLED
  void dispose() {
    // Nothing to dispose
  }
}

/// Widget helper for Banner Ads - DISABLED
class AdBannerWidget {
  /// Create banner ad - returns null (disabled)
  static Future<dynamic> create({dynamic size}) async {
    return null;
  }
}
