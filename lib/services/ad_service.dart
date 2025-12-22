import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'premium_service.dart';

/// Service to manage AdMob advertisements
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  final PremiumService _premiumService = PremiumService();
  
  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  // Ad Unit IDs - Using test IDs for now
  // TODO: Replace with real ad unit IDs after app-ads.txt verification (24h)
  static const String _bannerAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111' // Test ID
      : 'ca-app-pub-3627256909548242/XXXXXX'; // Replace after creating ad unit
      
  static const String _interstitialAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712' // Test ID
      : 'ca-app-pub-3627256909548242/YYYYYY'; // Replace after creating ad unit

  /// Initialize AdMob SDK
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await MobileAds.instance.initialize();
      debugPrint('✅ [AdService] AdMob initialized successfully');
      _isInitialized = true;
      
      // Pre-load interstitial ad
      await loadInterstitialAd();
    } catch (e) {
      debugPrint('❌ [AdService] Failed to initialize AdMob: $e');
    }
  }

  /// Check if ads are available
  bool get isAdsEnabled => _isInitialized;

  /// Create and load a Banner Ad
  Future<BannerAd?> createBannerAd({AdSize? size}) async {
    if (await _premiumService.isPremium()) {
      debugPrint('🎯 [AdService] User is premium - skipping banner ad');
      return null;
    }
    
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final BannerAd bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: size ?? AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('✅ [AdService] Banner ad loaded');
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('❌ [AdService] Banner ad failed to load: $error');
            ad.dispose();
          },
        ),
      );

      await bannerAd.load();
      return bannerAd;
    } catch (e) {
      debugPrint('❌ [AdService] Error creating banner ad: $e');
      return null;
    }
  }

  /// Load an Interstitial Ad
  Future<void> loadInterstitialAd() async {
    if (await _premiumService.isPremium()) {
      debugPrint('🎯 [AdService] User is premium - skipping interstitial ad');
      return;
    }
    
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isInterstitialAdReady = true;
            debugPrint('✅ [AdService] Interstitial ad loaded');

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialAdReady = false;
                // Pre-load next ad
                loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('❌ [AdService] Interstitial ad failed to show: $error');
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialAdReady = false;
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('❌ [AdService] Interstitial ad failed to load: $error');
            _isInterstitialAdReady = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ [AdService] Error loading interstitial ad: $e');
    }
  }

  /// Show Interstitial Ad
  Future<bool> showInterstitialAd() async {
    if (await _premiumService.isPremium()) {
      debugPrint('🎯 [AdService] User is premium - skipping interstitial ad');
      return false;
    }

    if (_interstitialAd != null && _isInterstitialAdReady) {
      await _interstitialAd!.show();
      _interstitialAd = null;
      _isInterstitialAdReady = false;
      return true;
    } else {
      debugPrint('⚠️ [AdService] Interstitial ad not ready');
      // Try to load for next time
      await loadInterstitialAd();
      return false;
    }
  }

  /// Check if interstitial ad is ready
  bool get isInterstitialAdReady => _isInterstitialAdReady;

  /// Dispose all ads
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }
}
