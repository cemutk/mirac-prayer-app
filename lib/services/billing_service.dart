import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'premium_service.dart';

/// Service to manage Google Play Billing for subscriptions
class BillingService {
  static final BillingService _instance = BillingService._internal();
  factory BillingService() => _instance;
  BillingService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final PremiumService _premiumService = PremiumService();

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;

  // Product IDs - MUST match Google Play Console subscription IDs
  static const String monthlySubscriptionId = 'premium_monthly';
  static const String yearlySubscriptionId = 'premium_yearly';
  
  List<ProductDetails> _products = [];
  
  /// Initialize billing service
  Future<void> initialize() async {
    // Check if in-app purchase is available
    _isAvailable = await _inAppPurchase.isAvailable();
    
    if (!_isAvailable) {
      debugPrint('❌ [BillingService] In-app purchase not available');
      return;
    }

    // Listen to purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('❌ [BillingService] Purchase stream error: $error'),
    );

    // Load products
    await loadProducts();
    
    // Restore previous purchases
    await restorePurchases();
    
    debugPrint('✅ [BillingService] Initialized successfully');
  }

  /// Load available products from Google Play
  Future<void> loadProducts() async {
    if (!_isAvailable) return;

    const Set<String> productIds = {
      monthlySubscriptionId,
      yearlySubscriptionId,
    };

    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);
      
      if (response.error != null) {
        debugPrint('❌ [BillingService] Error loading products: ${response.error}');
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('⚠️ [BillingService] Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      debugPrint('✅ [BillingService] Loaded ${_products.length} products');
    } catch (e) {
      debugPrint('❌ [BillingService] Exception loading products: $e');
    }
  }

  /// Get available subscription products
  List<ProductDetails> get products => _products;

  /// Purchase a subscription
  Future<bool> purchaseSubscription(ProductDetails product) async {
    if (!_isAvailable) {
      debugPrint('❌ [BillingService] In-app purchase not available');
      return false;
    }

    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      
      if (!success) {
        debugPrint('❌ [BillingService] Purchase failed to start');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ [BillingService] Exception during purchase: $e');
      return false;
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;

    try {
      await _inAppPurchase.restorePurchases();
      debugPrint('✅ [BillingService] Restore purchases initiated');
    } catch (e) {
      debugPrint('❌ [BillingService] Error restoring purchases: $e');
    }
  }

  /// Handle purchase updates
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint('📦 [BillingService] Purchase status: ${purchaseDetails.status}');

      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI
        debugPrint('⏳ [BillingService] Purchase pending...');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Handle error
        debugPrint('❌ [BillingService] Purchase error: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        // Verify and deliver purchase
        await _verifyAndDeliverPurchase(purchaseDetails);
      }

      // Complete the purchase (mark as consumed/acknowledged)
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  /// Verify and activate subscription
  Future<void> _verifyAndDeliverPurchase(PurchaseDetails purchaseDetails) async {
    // TODO: Add server-side verification for production
    // For now, trust client-side verification
    
    try {
      // Calculate expiry based on subscription type
      DateTime expiryDate;
      
      if (purchaseDetails.productID == monthlySubscriptionId) {
        expiryDate = DateTime.now().add(const Duration(days: 30));
      } else if (purchaseDetails.productID == yearlySubscriptionId) {
        expiryDate = DateTime.now().add(const Duration(days: 365));
      } else {
        debugPrint('⚠️ [BillingService] Unknown product ID: ${purchaseDetails.productID}');
        return;
      }

      // Activate premium
      await _premiumService.setPremiumStatus(true, expiryDate: expiryDate);
      
      debugPrint('✅ [BillingService] Premium activated until ${expiryDate.toString()}');
    } catch (e) {
      debugPrint('❌ [BillingService] Error delivering purchase: $e');
    }
  }

  /// Check if billing is available
  bool get isAvailable => _isAvailable;

  /// Dispose service
  void dispose() {
    _subscription?.cancel();
  }
}
