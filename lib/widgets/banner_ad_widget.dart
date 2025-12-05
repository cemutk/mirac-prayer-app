import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../services/premium_service.dart';

/// Reusable Banner Ad Widget
/// Automatically hides for premium users
class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  
  const BannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    // Check if user is premium
    final isPremium = await PremiumService().isPremium();
    if (isPremium) {
      setState(() => _isPremium = true);
      return;
    }

    // Load banner ad
    final banner = await AdService().createBannerAd(size: widget.adSize);
    if (banner != null && mounted) {
      setState(() {
        _bannerAd = banner;
        _isLoaded = true;
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
    // Don't show anything for premium users
    if (_isPremium) {
      return const SizedBox.shrink();
    }

    // Show placeholder while loading
    if (!_isLoaded || _bannerAd == null) {
      return Container(
        height: widget.adSize.height.toDouble(),
        width: double.infinity,
        color: Colors.grey.shade200,
        child: const Center(
          child: Text(
            'Reklam yükleniyor...',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      );
    }

    // Show banner ad
    return Container(
      height: widget.adSize.height.toDouble(),
      width: double.infinity,
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

/// Native Banner for lists (every N items)
class ListBannerAdWidget extends StatefulWidget {
  const ListBannerAdWidget({super.key});

  @override
  State<ListBannerAdWidget> createState() => _ListBannerAdWidgetState();
}

class _ListBannerAdWidgetState extends State<ListBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    final isPremium = await PremiumService().isPremium();
    if (isPremium) {
      setState(() => _isPremium = true);
      return;
    }

    final banner = await AdService().createBannerAd(size: AdSize.mediumRectangle);
    if (banner != null && mounted) {
      setState(() {
        _bannerAd = banner;
        _isLoaded = true;
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
    if (_isPremium) {
      return const SizedBox.shrink();
    }

    if (!_isLoaded || _bannerAd == null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        height: 250,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      clipBehavior: Clip.antiAlias,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
