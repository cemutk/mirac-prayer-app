import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../services/premium_service.dart';
import '../../core/app_export.dart';

/// Premium Upgrade Screen
/// Shows premium features and purchase options
class PremiumUpgradeScreen extends StatefulWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  State<PremiumUpgradeScreen> createState() => _PremiumUpgradeScreenState();
}

class _PremiumUpgradeScreenState extends State<PremiumUpgradeScreen> {
  final PremiumService _premiumService = PremiumService();
  bool _isPremium = false;
  DateTime? _expiryDate;
  int _selectedPlan = 1; // 0: Aylık, 1: Yıllık (default yıllık)

  @override
  void initState() {
    super.initState();
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    final isPremium = await _premiumService.isPremium();
    final expiry = await _premiumService.getExpiryDate();
    
    setState(() {
      _isPremium = isPremium;
      _expiryDate = expiry;
    });
  }

  Future<void> _purchasePremium() async {
    // TODO: Implement actual in-app purchase here
    // For now, we'll simulate a purchase (for testing)
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Simulate purchase delay
    await Future.delayed(const Duration(seconds: 2));

    // Set premium status based on selected plan
    final days = _selectedPlan == 1 ? 365 : 30;
    await _premiumService.setPremiumStatus(
      true,
      expiryDate: DateTime.now().add(Duration(days: days)),
    );

    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: Colors.green.shade600, size: 48),
              ),
              const SizedBox(height: 16),
              const Text('Maşallah! 🎉', style: TextStyle(fontSize: 24)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Premium aboneliğiniz aktif edildi!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _selectedPlan == 1
                    ? '1 yıl boyunca tüm özelliklerin ve reklamsız deneyimin keyfini çıkarın.'
                    : '1 ay boyunca tüm özelliklerin ve reklamsız deneyimin keyfini çıkarın.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Hayırlı Olsun!', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium\'a Yükselt'),
        centerTitle: true,
      ),
      body: _isPremium
          ? _buildPremiumActiveView(theme)
          : _buildPurchaseView(theme),
    );
  }

  Widget _buildPremiumActiveView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium,
                size: 60,
                color: Colors.amber.shade700,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Premium Üyesiniz!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade700,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              '🎉 Tüm özelliklere erişiminiz var',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              '🚫 Reklam görmüyorsunuz',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (_expiryDate != null) ...[
              SizedBox(height: 3.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text('Abonelik Bitiş Tarihi:'),
                    const SizedBox(height: 8),
                    Text(
                      '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseView(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Section with Islamic touch
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 4.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1B5E20), // Deep green
                  const Color(0xFF4CAF50), // Light green
                  Colors.amber.shade600,
                ],
              ),
            ),
            child: Column(
              children: [
                // Crown icon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Icon(
                      Icons.workspace_premium,
                      size: 60,
                      color: Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                const Text(
                  '🕌 Premium\'a Yükselt 🌙',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'İbadetlerinize Kesintisiz Odaklanın',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Motivational Text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade50,
                    Colors.amber.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  const Text(
                    '✨ Neden Premium? ✨',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Reklamlarla bölünmeden, tüm özelliklere erişerek ibadetlerinize tam konsantre olun. '
                    'Premium ile namaz vakitlerini kaçırmayın, Kıble\'yi AR ile kolayca bulun ve çok daha fazlası!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Pricing Plans
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Abonelik Planı Seçin',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                
                // Yearly Plan (Recommended)
                GestureDetector(
                  onTap: () => setState(() => _selectedPlan = 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      gradient: _selectedPlan == 1
                          ? LinearGradient(
                              colors: [Colors.green.shade400, Colors.green.shade600],
                            )
                          : null,
                      color: _selectedPlan == 1 ? null : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedPlan == 1 ? Colors.green.shade600 : Colors.grey.shade300,
                        width: _selectedPlan == 1 ? 2 : 1,
                      ),
                      boxShadow: _selectedPlan == 1
                          ? [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      children: [
                        // Best Value Badge
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _selectedPlan == 1 ? Colors.amber : Colors.amber.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '🔥 EN AVANTAJLI',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Radio<int>(
                              value: 1,
                              groupValue: _selectedPlan,
                              onChanged: (v) => setState(() => _selectedPlan = v!),
                              activeColor: Colors.white,
                              fillColor: WidgetStateProperty.all(
                                _selectedPlan == 1 ? Colors.white : Colors.green,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Yıllık Plan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _selectedPlan == 1 ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '₺69,99',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedPlan == 1 ? Colors.white : Colors.green.shade700,
                                        ),
                                      ),
                                      Text(
                                        ' /yıl',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _selectedPlan == 1 ? Colors.white70 : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _selectedPlan == 1 
                                          ? Colors.white.withOpacity(0.2) 
                                          : Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '💰 Ayda sadece ₺5,83 - %17 Tasarruf!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _selectedPlan == 1 ? Colors.white : Colors.green.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 2.h),

                // Monthly Plan
                GestureDetector(
                  onTap: () => setState(() => _selectedPlan = 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      gradient: _selectedPlan == 0
                          ? LinearGradient(
                              colors: [Colors.blue.shade400, Colors.blue.shade600],
                            )
                          : null,
                      color: _selectedPlan == 0 ? null : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedPlan == 0 ? Colors.blue.shade600 : Colors.grey.shade300,
                        width: _selectedPlan == 0 ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: 0,
                          groupValue: _selectedPlan,
                          onChanged: (v) => setState(() => _selectedPlan = v!),
                          activeColor: Colors.white,
                          fillColor: WidgetStateProperty.all(
                            _selectedPlan == 0 ? Colors.white : Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Aylık Plan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedPlan == 0 ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '₺6,99',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: _selectedPlan == 0 ? Colors.white : Colors.blue.shade700,
                                    ),
                                  ),
                                  Text(
                                    ' /ay',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _selectedPlan == 0 ? Colors.white70 : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Esnek ödeme, istediğiniz zaman iptal',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _selectedPlan == 0 ? Colors.white70 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Benefits Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Premium ile Neler Kazanırsınız?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                _buildBenefitItem(
                  icon: Icons.block,
                  iconColor: Colors.red,
                  title: '🚫 Reklamsız Deneyim',
                  description: 'Hiçbir reklam görmeden ibadetlerinize odaklanın',
                ),
                _buildBenefitItem(
                  icon: Icons.view_in_ar,
                  iconColor: Colors.purple,
                  title: '🧭 AR Kıble Bulucu',
                  description: 'Artırılmış gerçeklik ile Kıble\'yi anında bulun',
                ),
                _buildBenefitItem(
                  icon: Icons.qr_code_scanner,
                  iconColor: Colors.orange,
                  title: '🔍 Helal Gıda Tarayıcı',
                  description: 'Barkod okutarak ürünlerin helal durumunu öğrenin',
                ),
                _buildBenefitItem(
                  icon: Icons.child_care,
                  iconColor: Colors.pink,
                  title: '👶 Çocuk Modu',
                  description: 'Çocuklarınıza eğlenceli şekilde din eğitimi',
                ),
                _buildBenefitItem(
                  icon: Icons.do_not_disturb_on,
                  iconColor: Colors.blue,
                  title: '🔕 Cami Modu',
                  description: 'Namaz vakitlerinde otomatik sessiz mod',
                ),
                _buildBenefitItem(
                  icon: Icons.luggage,
                  iconColor: Colors.teal,
                  title: '✈️ Seferi Modu',
                  description: 'Seyahatte namazları otomatik hesaplayın',
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Purchase Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _purchasePremium,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedPlan == 1 ? Colors.green.shade600 : Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.workspace_premium, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          _selectedPlan == 1 
                              ? 'Yıllık Premium Al - ₺69,99' 
                              : 'Aylık Premium Al - ₺6,99',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                
                // Trust badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Güvenli Ödeme',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.refresh, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'İstediğiniz Zaman İptal',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                
                SizedBox(height: 1.h),
                
                TextButton(
                  onPressed: () {
                    // Restore purchases
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Satın alımlar geri yükleniyor...')),
                    );
                  },
                  child: Text(
                    'Satın Alımları Geri Yükle',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required String icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: Colors.green, size: 24),
          ],
        ),
      ),
    );
  }
}
