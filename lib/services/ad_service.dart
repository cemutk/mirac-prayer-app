import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'premium_service.dart';

/// Service to manage Google AdMob advertisements
/// Handles Banner and Interstitial ads based on premium status
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  final PremiumService _premiumService = PremiumService();
  
  // Test Ad Unit IDs (use these during development)
  // Replace with real Ad Unit IDs before publishing
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  
  // Real Ad Unit IDs (replace these with your actual AdMob IDs)
  static const String _bannerAdUnitIdAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // TODO: Replace
  static const String _bannerAdUnitIdIOS = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // TODO: Replace
  static const String _interstitialAdUnitIdAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // TODO: Replace
  static const String _interstitialAdUnitIdIOS = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // TODO: Replace
  
  // CRITICAL FIX: Always use test ads until real AdMob IDs are configured
  // This prevents crash in TestFlight/Production builds with invalid ad unit IDs
  static bool get _useTestAds => true; // Changed from: kDebugMode

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  bool _isInitialized = false;

  /// Initialize Google Mobile Ads
  /// CRITICAL: On iOS, this will crash if GADApplicationIdentifier is invalid/missing
  Future<void> initialize() async {
    // Skip initialization on iOS until real AdMob ID is configured
    if (Platform.isIOS) {
      debugPrint('🎯 [AdService] AdMob disabled on iOS (no valid GADApplicationIdentifier)');
      return;
    }
    
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('🎯 [AdService] Google Mobile Ads initialized');
    } catch (e) {
      debugPrint('❌ [AdService] Failed to initialize: $e');
    }
  }

  /// Check if ads are available
  bool get isAdsEnabled => _isInitialized && !Platform.isIOS;

  /// Get Banner Ad Unit ID based on platform
  String get bannerAdUnitId {
    if (_useTestAds) return _testBannerAdUnitId;
    
    if (Platform.isAndroid) {
      return _bannerAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return _bannerAdUnitIdIOS;
    }
    return _testBannerAdUnitId;
  }

  /// Get Interstitial Ad Unit ID based on platform
  String get interstitialAdUnitId {
    if (_useTestAds) return _testInterstitialAdUnitId;
    
    if (Platform.isAndroid) {
      return _interstitialAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return _interstitialAdUnitIdIOS;
    }
    return _testInterstitialAdUnitId;
  }

  /// Create and load a Banner Ad
  /// Returns null if user is premium or ads disabled
  Future<BannerAd?> createBannerAd({AdSize size = AdSize.banner}) async {
    // Don't show ads on iOS (no valid AdMob ID configured)
    if (Platform.isIOS) {
      debugPrint('🎯 [AdService] Ads disabled on iOS');
      return null;
    }
    
    // Don't show ads to premium users
    if (await _premiumService.isPremium()) {
      debugPrint('🎯 [AdService] User is premium - skipping banner ad');
      return null;
    }

    final BannerAd banner = BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ [AdService] Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ [AdService] Banner ad failed to load: $error');
          ad.dispose();
        },
        onAdOpened: (ad) {
          debugPrint('📱 [AdService] Banner ad opened');
        },
        onAdClosed: (ad) {
          debugPrint('🔒 [AdService] Banner ad closed');
        },
      ),
    );

    await banner.load();
    return banner;
  }

  /// Load an Interstitial Ad
  Future<void> loadInterstitialAd() async {
    // Don't load ads on iOS (no valid AdMob ID configured)
    if (Platform.isIOS) {
      debugPrint('🎯 [AdService] Ads disabled on iOS');
      return;
    }
    
    // Don't load ads for premium users
    if (await _premiumService.isPremium()) {
      debugPrint('🎯 [AdService] User is premium - skipping interstitial ad');
      return;
    }

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ [AdService] Interstitial ad loaded');
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('📱 [AdService] Interstitial ad showed full screen');
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('🔒 [AdService] Interstitial ad dismissed');
              ad.dispose();
              _isInterstitialAdReady = false;
              // Preload next interstitial ad
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('❌ [AdService] Interstitial ad failed to show: $error');
              ad.dispose();
              _isInterstitialAdReady = false;
              // Preload next interstitial ad
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ [AdService] Interstitial ad failed to load: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  /// Show Interstitial Ad if ready
  /// Returns true if ad was shown, false otherwise
  Future<bool> showInterstitialAd() async {
    // Don't show ads to premium users
    if (await _premiumService.isPremium()) {
      debugPrint('🎯 [AdService] User is premium - skipping interstitial ad');
      return false;
    }

    if (_isInterstitialAdReady && _interstitialAd != null) {
      await _interstitialAd!.show();
      _interstitialAd = null;
      _isInterstitialAdReady = false;
      return true;
    } else {
      debugPrint('⚠️ [AdService] Interstitial ad not ready');
      // Try to load for next time
      loadInterstitialAd();
      return false;
    }
  }

  /// Check if interstitial ad is ready to show
  bool get isInterstitialAdReady => _isInterstitialAdReady;

  /// Dispose all ads
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }
}

/// Widget helper for Banner Ads
/// Use this to display banner ads in your screens
class AdBannerWidget {
  /// Show banner ad at specific location
  /// Common locations: settings bottom, mosque list, calendar, tasbih screen
  static Future<BannerAd?> create({AdSize size = AdSize.banner}) async {
    return await AdService().createBannerAd(size: size);
  }
}
