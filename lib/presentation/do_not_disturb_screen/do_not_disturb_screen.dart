import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/do_not_disturb_service.dart';

class DoNotDisturbScreen extends StatefulWidget {
  const DoNotDisturbScreen({super.key});

  @override
  State<DoNotDisturbScreen> createState() => _DoNotDisturbScreenState();
}

class _DoNotDisturbScreenState extends State<DoNotDisturbScreen> {
  final DoNotDisturbService _dndService = DoNotDisturbService();
  bool _isLoading = true;
  bool _hasPermission = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initService();
    _dndService.addListener(_onServiceChanged);
    // Her saniye güncelle (kalan süre için)
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _dndService.isCurrentlyActive) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dndService.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _initService() async {
    await _dndService.initialize();
    _hasPermission = await _dndService.checkDndPermission();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _requestPermission() async {
    // Önce detaylı rehber göster
    await _showPermissionGuide();
  }

  Future<void> _showPermissionGuide() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık çubuğu
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Başlık
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.do_not_disturb_on,
                    color: Colors.orange.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Rahatsız Etme İzni Nasıl Verilir?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Adımlar
            _buildPermissionStep(
              stepNumber: 1,
              title: '"Ayarları Aç" butonuna basın',
              description: 'Sizi telefon ayarlarına yönlendireceğiz.',
              icon: Icons.touch_app,
            ),
            
            _buildPermissionStep(
              stepNumber: 2,
              title: 'Uygulamayı listede bulun',
              description: 'Listeyi aşağı kaydırarak "Miraç" veya "mirac" uygulamasını bulun.',
              icon: Icons.search,
            ),
            
            _buildPermissionStep(
              stepNumber: 3,
              title: 'Uygulamanın yanındaki düğmeyi açın',
              description: 'Switch/toggle butonunu açık konuma getirin.',
              icon: Icons.toggle_on,
              iconColor: Colors.green,
            ),
            
            _buildPermissionStep(
              stepNumber: 4,
              title: 'Geri dönün',
              description: 'Telefon geri tuşuyla uygulamaya dönün.',
              icon: Icons.arrow_back,
              isLast: true,
            ),
            
            const SizedBox(height: 8),
            
            // Uygulama bilgisi kutusu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Uygulama Bilgisi',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Icon(
                          Icons.mosque,
                          color: Colors.orange.shade700,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Miraç',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'com.miracapp.namazvakti',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 12,
                                fontFamily: 'monospace',
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
            
            const SizedBox(height: 12),
            
            // Görsel ipucu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'İpucu: "M" harfine kadar kaydırın. Uygulama "Miraç" veya "mirac" olarak görünür.',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Butonlar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Vazgeç'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.settings),
                    label: const Text('Ayarları Aç'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
    
    if (result == true) {
      await _dndService.requestDndPermission();
      // Kullanıcı ayarlardan döndükten sonra kontrol et
      await Future.delayed(const Duration(seconds: 1));
      _hasPermission = await _dndService.checkDndPermission();
      if (mounted) {
        setState(() {});
        if (_hasPermission) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('✅ İzin başarıyla verildi!'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  Widget _buildPermissionStep({
    required int stepNumber,
    required String title,
    required String description,
    required IconData icon,
    Color? iconColor,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Numara ve çizgi
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '$stepNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: Colors.teal.shade200,
                ),
            ],
          ),
          const SizedBox(width: 16),
          // İçerik
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: iconColor ?? Colors.grey[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cami Modu'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ana açıklama
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.teal.shade400,
                          Colors.teal.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.mosque,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rahatsız Etme Modu',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Namaz vakitlerinde veya camideyken telefonunuz otomatik olarak sessiz moda geçer.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // İzin durumu bilgisi (sadece bilgilendirme, zorlama yok)
                  if (!_hasPermission) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Özelliği aktifleştirmek için izin gerekecek',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Aktif durum kartı
                  if (_dndService.isCurrentlyActive) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Icon(
                                  Icons.volume_off,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Cami Modu Aktif',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _dndService.activationReason ?? '',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Kalan süre
                          if (_dndService.autoRestore) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.timer, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Kalan: ${_dndService.remainingTimeFormatted}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => _dndService.deactivate(),
                            icon: const Icon(Icons.volume_up),
                            label: const Text('Sesi Aç'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green.shade800,
                              side: BorderSide(color: Colors.green.shade400),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Ana switch
                  _buildSettingsCard(
                    title: 'Cami Modu',
                    subtitle: 'Otomatik sessiz mod özelliğini aç/kapat',
                    trailing: Switch(
                      value: _dndService.isEnabled,
                      onChanged: (value) async {
                        if (value && !_hasPermission) {
                          // Açmak istiyor ama izin yok - izin iste
                          await _requestPermission();
                          // İzin verildiyse aç
                          if (_hasPermission) {
                            _dndService.setEnabled(true);
                          }
                        } else {
                          // İzin var veya kapatmak istiyor
                          _dndService.setEnabled(value);
                        }
                      },
                      activeColor: Colors.teal,
                    ),
                    icon: Icons.do_not_disturb_on,
                    iconColor: Colors.teal,
                  ),

                  const SizedBox(height: 12),

                  // Namaz vakitlerinde aktifleştir
                  _buildSettingsCard(
                    title: 'Namaz Vakitlerinde',
                    subtitle: 'Namaz vakti girdiğinde otomatik sessiz mod',
                    trailing: Switch(
                      value: _dndService.enableForPrayerTimes,
                      onChanged: _dndService.isEnabled
                          ? (value) => _dndService.setEnableForPrayerTimes(value)
                          : null,
                      activeColor: Colors.teal,
                    ),
                    icon: Icons.access_time,
                    iconColor: Colors.blue,
                  ),

                  const SizedBox(height: 12),

                  // Cami yakınlığında aktifleştir
                  _buildSettingsCard(
                    title: 'Cami Yakınlığında',
                    subtitle: 'Kayıtlı camiye yaklaştığınızda otomatik sessiz mod',
                    trailing: Switch(
                      value: _dndService.enableForMosqueProximity,
                      onChanged: _dndService.isEnabled
                          ? (value) => _dndService.setEnableForMosqueProximity(value)
                          : null,
                      activeColor: Colors.teal,
                    ),
                    icon: Icons.location_on,
                    iconColor: Colors.orange,
                  ),

                  const SizedBox(height: 24),

                  // Ayarlar başlığı
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Ayarlar',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),

                  // Süre ayarı
                  _buildSettingsCard(
                    title: 'Sessiz Mod Süresi',
                    subtitle: '${_dndService.durationMinutes} dakika',
                    trailing: const Icon(Icons.chevron_right),
                    icon: Icons.timelapse,
                    iconColor: Colors.purple,
                    onTap: _showDurationPicker,
                  ),

                  const SizedBox(height: 12),

                  // Ses modu
                  _buildSettingsCard(
                    title: 'Ses Modu',
                    subtitle: _dndService.soundMode == 'silent' ? 'Tamamen Sessiz' : 'Titreşim',
                    trailing: const Icon(Icons.chevron_right),
                    icon: _dndService.soundMode == 'silent' 
                        ? Icons.volume_off 
                        : Icons.vibration,
                    iconColor: Colors.indigo,
                    onTap: _showSoundModePicker,
                  ),

                  const SizedBox(height: 12),

                  // Otomatik geri yükleme
                  _buildSettingsCard(
                    title: 'Süre Sonunda Sesi Aç',
                    subtitle: 'Belirtilen süre sonunda ses otomatik açılsın',
                    trailing: Switch(
                      value: _dndService.autoRestore,
                      onChanged: _dndService.isEnabled
                          ? (value) => _dndService.setAutoRestore(value)
                          : null,
                      activeColor: Colors.teal,
                    ),
                    icon: Icons.restore,
                    iconColor: Colors.green,
                  ),

                  if (_dndService.enableForMosqueProximity) ...[
                    const SizedBox(height: 12),
                    
                    // Algılama yarıçapı
                    _buildSettingsCard(
                      title: 'Algılama Yarıçapı',
                      subtitle: '${_dndService.mosqueDetectionRadius} metre',
                      trailing: const Icon(Icons.chevron_right),
                      icon: Icons.radar,
                      iconColor: Colors.cyan,
                      onTap: _showRadiusPicker,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Kayıtlı camiler
                  if (_dndService.enableForMosqueProximity) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kayıtlı Camiler',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addCurrentLocationAsMosque,
                          icon: const Icon(Icons.add_location),
                          label: const Text('Ekle'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    if (_dndService.savedMosques.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.mosque, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'Henüz kayıtlı cami yok',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bulunduğunuz camiyi kaydedin',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...List.generate(_dndService.savedMosques.length, (index) {
                        final mosque = _dndService.savedMosques[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.mosque,
                                color: Colors.teal.shade600,
                              ),
                            ),
                            title: Text(mosque.name),
                            subtitle: Text(
                              '${mosque.latitude.toStringAsFixed(4)}, ${mosque.longitude.toStringAsFixed(4)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _dndService.removeMosque(index),
                            ),
                          ),
                        );
                      }),
                  ],

                  const SizedBox(height: 24),

                  // Manuel kontrol
                  if (!_dndService.isCurrentlyActive && _dndService.isEnabled)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _dndService.activate(reason: 'Manuel'),
                        icon: const Icon(Icons.volume_off),
                        label: const Text('Şimdi Sessiz Moda Geç'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required String subtitle,
    required Widget trailing,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        trailing: trailing,
      ),
    );
  }

  void _showDurationPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sessiz Mod Süresi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...[ 15, 20, 25, 30, 45, 60].map((minutes) => ListTile(
              title: Text('$minutes dakika'),
              trailing: _dndService.durationMinutes == minutes
                  ? const Icon(Icons.check, color: Colors.teal)
                  : null,
              onTap: () {
                _dndService.setDurationMinutes(minutes);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showSoundModePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ses Modu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.volume_off),
              title: const Text('Tamamen Sessiz'),
              subtitle: const Text('Hiç ses çıkmaz'),
              trailing: _dndService.soundMode == 'silent'
                  ? const Icon(Icons.check, color: Colors.teal)
                  : null,
              onTap: () {
                _dndService.setSoundMode('silent');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.vibration),
              title: const Text('Titreşim'),
              subtitle: const Text('Sadece titreşim'),
              trailing: _dndService.soundMode == 'vibrate'
                  ? const Icon(Icons.check, color: Colors.teal)
                  : null,
              onTap: () {
                _dndService.setSoundMode('vibrate');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRadiusPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Algılama Yarıçapı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...[50, 75, 100, 150, 200, 300].map((meters) => ListTile(
              title: Text('$meters metre'),
              trailing: _dndService.mosqueDetectionRadius == meters
                  ? const Icon(Icons.check, color: Colors.teal)
                  : null,
              onTap: () {
                _dndService.setMosqueDetectionRadius(meters);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _addCurrentLocationAsMosque() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cami Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Mevcut konumunuz cami olarak kaydedilecek.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Cami Adı',
                hintText: 'Örn: Mahalle Camii',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                final success = await _dndService.saveCurrentLocationAsMosque(
                  controller.text.trim(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? '✅ Cami kaydedildi'
                            : '⚠️ Konum alınamadı',
                      ),
                      backgroundColor: success ? Colors.green : Colors.orange,
                    ),
                  );
                }
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
