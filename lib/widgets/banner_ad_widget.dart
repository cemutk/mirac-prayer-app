import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/premium_service.dart';
import '../services/ad_service.dart';

/// Reusable Banner Ad Widget - Minimal and respectful
/// Only shows in non-intrusive locations
class BannerAdWidget extends StatefulWidget {
  final AdSize? adSize;
  
  const BannerAdWidget({
    super.key,
    this.adSize,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  bool _isPremium = false;
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _checkPremiumAndLoadAd();
  }

  Future<void> _checkPremiumAndLoadAd() async {
    final isPremium = await PremiumService().isPremium();
    
    if (mounted) {
      setState(() => _isPremium = isPremium);
      
      if (!isPremium) {
        _loadAd();
      }
    }
  }

  Future<void> _loadAd() async {
    final ad = await AdService().createBannerAd(size: widget.adSize ?? AdSize.banner);
    
    if (mounted && ad != null) {
      setState(() {
        _bannerAd = ad;
        _isAdLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Premium users don't see ads
    if (_isPremium || !_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

/// Native Banner for lists - Minimal
class ListBannerAdWidget extends StatefulWidget {
  const ListBannerAdWidget({super.key});

  @override
  State<ListBannerAdWidget> createState() => _ListBannerAdWidgetState();
}

class _ListBannerAdWidgetState extends State<ListBannerAdWidget> {
  bool _isPremium = false;
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _checkPremiumAndLoadAd();
  }

  Future<void> _checkPremiumAndLoadAd() async {
    final isPremium = await PremiumService().isPremium();
    
    if (mounted) {
      setState(() => _isPremium = isPremium);
      
      if (!isPremium) {
        _loadAd();
      }
    }
  }

  Future<void> _loadAd() async {
    final ad = await AdService().createBannerAd(size: AdSize.mediumRectangle);
    
    if (mounted && ad != null) {
      setState(() {
        _bannerAd = ad;
        _isAdLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isPremium || !_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 16),
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
