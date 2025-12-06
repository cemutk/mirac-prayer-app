import 'package:flutter/material.dart';
import '../services/premium_service.dart';

/// Reusable Banner Ad Widget - DISABLED
/// google_mobile_ads removed due to iOS crash (invalid GADApplicationIdentifier)
/// Re-enable when real AdMob App ID is configured
class BannerAdWidget extends StatefulWidget {
  final dynamic adSize;
  
  const BannerAdWidget({
    super.key,
    this.adSize,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _checkPremium();
  }

  Future<void> _checkPremium() async {
    final isPremium = await PremiumService().isPremium();
    if (mounted) {
      setState(() => _isPremium = isPremium);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ads disabled - return empty widget
    // Premium users also don't see ads
    return const SizedBox.shrink();
  }
}

/// Native Banner for lists - DISABLED
class ListBannerAdWidget extends StatefulWidget {
  const ListBannerAdWidget({super.key});

  @override
  State<ListBannerAdWidget> createState() => _ListBannerAdWidgetState();
}

class _ListBannerAdWidgetState extends State<ListBannerAdWidget> {
  @override
  Widget build(BuildContext context) {
    // Ads disabled - return empty widget
    return const SizedBox.shrink();
  }
}
