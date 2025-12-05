import 'package:flutter/material.dart';
import '../../services/travel_mode_service.dart';
import '../../theme/app_theme.dart';

class TravelModeScreen extends StatefulWidget {
  const TravelModeScreen({super.key});

  @override
  State<TravelModeScreen> createState() => _TravelModeScreenState();
}

class _TravelModeScreenState extends State<TravelModeScreen> {
  final TravelModeService _travelService = TravelModeService();
  bool _isLoading = false;
  bool _isCheckingLocation = false;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    setState(() => _isLoading = true);
    await _travelService.init();
    _travelService.addListener(_onServiceUpdate);
    setState(() => _isLoading = false);
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _travelService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧳 Akıllı Seferi Modu'),
        backgroundColor: AppTheme.primaryLight,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
            tooltip: 'Bilgi',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 16),
                  _buildHomeLocationCard(),
                  const SizedBox(height: 16),
                  _buildSettingsCard(),
                  const SizedBox(height: 16),
                  _buildPrayerInfoCard(),
                  const SizedBox(height: 16),
                  _buildAdditionalInfoCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    final isTraveling = _travelService.isTraveling;
    final distance = _travelService.currentDistanceFromHome;
    final hasHome = _travelService.hasHomeLocation;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (!hasHome) {
      statusColor = Colors.grey;
      statusText = 'Ev konumu ayarlanmamış';
      statusIcon = Icons.location_off;
    } else if (isTraveling) {
      statusColor = Colors.orange;
      statusText = 'Seferi (Yolcu)';
      statusIcon = Icons.flight_takeoff;
    } else {
      statusColor = Colors.green;
      statusText = 'Mukim (İkamet)';
      statusIcon = Icons.home;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor, width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              statusColor.withValues(alpha: 0.1),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(statusIcon, color: statusColor, size: 48),
                const SizedBox(width: 16),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mevcut Durum',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasHome && distance != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.straighten,
                    label: 'Ev\'den Uzaklık',
                    value: '${distance.toStringAsFixed(1)} km',
                  ),
                  _buildStatItem(
                    icon: Icons.speed,
                    label: 'Seferi Eşiği',
                    value: '${TravelModeService.travelDistanceThreshold.toInt()} km',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: (distance / TravelModeService.travelDistanceThreshold).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                color: isTraveling ? Colors.orange : Colors.green,
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                isTraveling
                    ? '✈️ Seferi mesafesini aştınız'
                    : '🏠 Seferi mesafesinin içindesiniz',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isCheckingLocation ? null : _checkLocation,
              icon: _isCheckingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(_isCheckingLocation ? 'Kontrol Ediliyor...' : 'Konumu Kontrol Et'),
              style: ElevatedButton.styleFrom(
                backgroundColor: statusColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryLight, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHomeLocationCard() {
    final hasHome = _travelService.hasHomeLocation;
    final homeAddress = _travelService.homeAddress;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.home, color: AppTheme.primaryLight),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'İkamet Konumu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        hasHome
                            ? homeAddress ?? 'Konum kaydedildi'
                            : 'Henüz ayarlanmadı',
                        style: TextStyle(
                          color: hasHome ? Colors.grey[600] : Colors.orange,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hasHome) ...[
              Text(
                '📍 Koordinatlar: ${_travelService.homeLatitude?.toStringAsFixed(4)}, ${_travelService.homeLongitude?.toStringAsFixed(4)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _setCurrentAsHome,
                    icon: const Icon(Icons.my_location, size: 18),
                    label: const Text('Mevcut Konumu Kaydet'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryLight,
                    ),
                  ),
                ),
                if (hasHome) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _clearHomeLocation,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Konumu Sil',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: AppTheme.primaryLight),
                const SizedBox(width: 8),
                const Text(
                  'Ayarlar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Otomatik Algılama'),
              subtitle: const Text(
                'GPS ile seferi durumunu otomatik algıla',
                style: TextStyle(fontSize: 12),
              ),
              value: _travelService.autoDetectEnabled,
              onChanged: (value) => _travelService.setAutoDetect(value),
              activeColor: AppTheme.primaryLight,
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Manuel Seferi Modu'),
              subtitle: Text(
                _travelService.isTraveling
                    ? 'Seferi modundasınız'
                    : 'Mukim modundasınız',
                style: const TextStyle(fontSize: 12),
              ),
              value: _travelService.isTraveling,
              onChanged: _travelService.autoDetectEnabled
                  ? null
                  : (value) => _travelService.setTravelMode(value),
              activeColor: Colors.orange,
              contentPadding: EdgeInsets.zero,
            ),
            if (_travelService.autoDetectEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '💡 Otomatik algılama açıkken manuel mod devre dışıdır',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerInfoCard() {
    final prayers = _travelService.getTravelPrayerInfo();
    final isTraveling = _travelService.isTraveling;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.access_time, color: Colors.orange),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Seferi Namaz Rekatları',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isTraveling ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isTraveling ? 'Seferi' : 'Mukim',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...prayers.map((prayer) => _buildPrayerRow(prayer, isTraveling)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerRow(TravelPrayerInfo prayer, bool isTraveling) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: prayer.canBeShortened && isTraveling
              ? Colors.orange.withValues(alpha: 0.5)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              prayer.prayerName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: !isTraveling ? AppTheme.primaryLight : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${prayer.normalRakats} rekat',
                    style: TextStyle(
                      color: !isTraveling ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (prayer.canBeShortened) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isTraveling ? Colors.orange : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${prayer.travelRakats} rekat',
                      style: TextStyle(
                        color: isTraveling ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (prayer.canBeShortened)
            const Icon(Icons.check_circle, color: Colors.green, size: 20)
          else
            const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book, color: AppTheme.primaryLight),
                const SizedBox(width: 8),
                const Text(
                  'Seferi Hükümleri',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              icon: Icons.schedule,
              title: 'Seferilik Süresi',
              onTap: _showDurationInfo,
            ),
            _buildInfoTile(
              icon: Icons.merge_type,
              title: 'Namazları Birleştirme (Cem)',
              onTap: _showCemInfo,
            ),
            _buildInfoTile(
              icon: Icons.restaurant,
              title: 'Seferde Oruç',
              onTap: _showFastingInfo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryLight),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  // Actions
  Future<void> _checkLocation() async {
    setState(() => _isCheckingLocation = true);
    
    final result = await _travelService.checkTravelStatus();
    
    setState(() => _isCheckingLocation = false);

    if (!mounted) return;

    if (result.success) {
      if (result.statusChanged == true) {
        _showStatusChangeDialog(result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '📍 Ev\'den uzaklık: ${result.distance?.toStringAsFixed(1)} km',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ ${result.message}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showStatusChangeDialog(TravelCheckResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.isTraveling == true ? Icons.flight_takeoff : Icons.home,
              color: result.isTraveling == true ? Colors.orange : Colors.green,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                result.isTraveling == true
                    ? 'Seferi Duruma Geçtiniz'
                    : 'Mukim Durumuna Döndünüz',
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ev\'den uzaklığınız: ${result.distance?.toStringAsFixed(1)} km',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (result.isTraveling == true) ...[
              const Text(
                '✅ Namaz rekatları seferi moduna göre güncellendi:\n'
                '• Öğle: 4 → 2 rekat\n'
                '• İkindi: 4 → 2 rekat\n'
                '• Yatsı: 4 → 2 rekat',
                style: TextStyle(fontSize: 14),
              ),
            ] else ...[
              const Text(
                '✅ Namaz rekatları mukim moduna döndürüldü:\n'
                '• Tüm namazlar normal rekat sayılarıyla kılınır',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Future<void> _setCurrentAsHome() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    final success = await _travelService.setCurrentLocationAsHome();
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '✅ Mevcut konum ev olarak kaydedildi'
              : '⚠️ Konum alınamadı',
        ),
        backgroundColor: success ? Colors.green : Colors.orange,
      ),
    );
  }

  Future<void> _clearHomeLocation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ev Konumunu Sil'),
        content: const Text('İkamet konumunuz silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _travelService.clearHomeLocation();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Ev konumu silindi'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: AppTheme.primaryLight),
            const SizedBox(width: 8),
            const Text('Akıllı Seferi Modu'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            '🧳 Akıllı Seferi Modu Nedir?\n\n'
            'Bu özellik, telefonunuzun GPS verisini kullanarak ikamet yerinizden '
            '90km (seferilik sınırı) uzaklaştığınızı otomatik olarak algılar.\n\n'
            '📍 Nasıl Çalışır?\n'
            '1. Ev konumunuzu kaydedin\n'
            '2. Otomatik algılamayı açık tutun\n'
            '3. Seyahat ederken uygulama mesafeyi kontrol eder\n'
            '4. 90km aşıldığında seferi moduna geçer\n\n'
            '🕌 Seferi Modunda:\n'
            '• 4 rekatlık farz namazlar 2 rekat olarak kılınır\n'
            '• Sünnetler terk edilebilir\n'
            '• Eve dönünce otomatik mukim moduna geçer\n\n'
            '⚠️ Uyarı:\n'
            'Bu uygulama yardımcı bir araçtır. Dini hükümler için '
            'bir ilim ehline danışmanız tavsiye edilir.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }

  void _showDurationInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📅 Seferilik Süresi'),
        content: SingleChildScrollView(
          child: Text(_travelService.getTravelDurationInfo()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showCemInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📖 Namazları Birleştirme'),
        content: SingleChildScrollView(
          child: Text(_travelService.getCemInfo()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showFastingInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🍽️ Seferde Oruç'),
        content: const SingleChildScrollView(
          child: Text(
            '📖 Seferde Oruç Hükümleri\n\n'
            'Kur\'an-ı Kerim\'de:\n'
            '"Kim hasta veya yolcu olursa, tutamadığı günler sayısınca başka '
            'günlerde tutar." (Bakara, 184)\n\n'
            '✅ Seferde Oruç Tutmamak:\n'
            '• Ruhsattır (kolaylık için izin verilmiştir)\n'
            '• Günah değildir\n'
            '• Tutulmayan oruçlar sonra kaza edilir\n\n'
            '✅ Seferde Oruç Tutmak:\n'
            '• Zorluk yoksa tutulabilir\n'
            '• Daha faziletlidir (Hanefi mezhebine göre)\n\n'
            '⚠️ Dikkat:\n'
            '• Zorluk çekilecekse tutmamak daha uygundur\n'
            '• Ramazan\'da tutulmayan oruçlar bayramdan sonra kaza edilir\n'
            '• Seferin bitmesine yakın başlanan oruç tamamlanmalıdır',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
