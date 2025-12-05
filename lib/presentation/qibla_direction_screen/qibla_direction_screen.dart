import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass_v2/flutter_compass_v2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/compass_widget.dart';
import 'qibla_ar_screen.dart';

class QiblaDirectionScreen extends StatefulWidget {
  const QiblaDirectionScreen({super.key});

  @override
  State<QiblaDirectionScreen> createState() => _QiblaDirectionScreenState();
}

class _QiblaDirectionScreenState extends State<QiblaDirectionScreen> {
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  double _deviceHeading = 0;
  double _qiblaDirection = 0;
  double _distanceToKaaba = 0;
  bool _isSensorMode = false;
  bool _isInitializing = true;
  bool _isHeadingAccurate = true;
  bool _hasQiblaDirection = false;
  String _statusMessage = 'Sensör verisi kuruluyor...';

  StreamSubscription<CompassEvent>? _compassSubscription;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initializeSensors();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeSensors() async {
    if (mounted) {
      setState(() {
        _isInitializing = true;
        _statusMessage = 'Sensör ve konum kuruluyor...';
        _isSensorMode = false;
        _hasQiblaDirection = false;
      });
    }

    if (kIsWeb) {
      await _setupStaticMode();
      return;
    }

    final hasLocation = await _requestLocationPermission();
    if (!hasLocation) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Konum izni gerekiyor';
          _isInitializing = false;
        });
      }
      return;
    }

    await _getCurrentLocation();
    _startCompass();
  }

  Future<bool> _requestLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition()
          .timeout(const Duration(seconds: 10));

      if (_currentPosition != null) {
        _distanceToKaaba = Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              kaabaLatitude,
              kaabaLongitude,
            ) /
            1000;

        _qiblaDirection = _calculateQiblaBearing(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        _hasQiblaDirection = true;

        if (mounted) {
          setState(() {
            _statusMessage = 'Konum başarıyla alındı';
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Konum alınamadı';
        });
      }
    }
  }

  Future<void> _setupStaticMode() async {
    if (mounted) {
      setState(() {
        _isSensorMode = false;
        _isInitializing = false;
        _deviceHeading = 150.0;
        _qiblaDirection = 154.0;
        _isHeadingAccurate = true;
        _statusMessage = 'Web demo modu aktifleştirildi';
      });
    }
  }

  void _startCompass() {
    _compassSubscription?.cancel();
    final stream = FlutterCompass.events;
    if (stream == null) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Pusula sensörü bulunamadı';
          _isInitializing = false;
        });
      }
      return;
    }

    _compassSubscription = stream.listen(
      (event) {
        final heading = event.heading;
        if (heading == null || !mounted) return;
        final diff = _hasQiblaDirection
            ? _normalizeAngle(_qiblaDirection - heading)
            : 0.0;
        setState(() {
          _deviceHeading = heading;
          _isSensorMode = _hasQiblaDirection;
          _isHeadingAccurate = _hasQiblaDirection && diff.abs() <= 3;
          _isInitializing = false;
          _statusMessage = _hasQiblaDirection
              ? 'Kıble yönü güncel'
              : 'Konum verisi bekleniyor...';
        });
        if (_hasQiblaDirection) {
          _triggerHapticIfAligned();
        }
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _statusMessage = 'Pusula akışı alınamıyor';
          _isInitializing = false;
        });
      },
    );
  }

  double _calculateQiblaBearing(double lat, double lon) {
    final lat1 = _deg2rad(lat);
    final lat2 = _deg2rad(kaabaLatitude);
    final dLon = _deg2rad(kaabaLongitude - lon);
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    final brng = math.atan2(y, x);
    return (_rad2deg(brng) + 360) % 360;
  }

  double _deg2rad(double deg) => deg * (math.pi / 180);

  double _rad2deg(double rad) => rad * (180 / math.pi);

  double _angleDifference() {
    if (!_hasQiblaDirection) return 0;
    return _normalizeAngle(_qiblaDirection - _deviceHeading);
  }

  void _triggerHapticIfAligned() {
    final angleDifference = _angleDifference();
    if (angleDifference.abs() <= 3 && _isHeadingAccurate) {
      HapticFeedback.lightImpact();
    }
  }

  double _normalizeAngle(double angle) {
    if (angle > 180) return angle - 360;
    if (angle < -180) return angle + 360;
    return angle;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Kıble Yönü',
        centerTitle: true,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'info_outline',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _showInfoDialog,
            tooltip: 'Bilgi',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildInfoBar(theme),
            if (_statusMessage.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  _statusMessage,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            SizedBox(height: 1.h),
            Expanded(
              child: Center(
                child: _isInitializing
                    ? const CircularProgressIndicator()
                    : CompassWidget(
                        qiblahDirection: _qiblaDirection,
                        deviceDirection: _deviceHeading,
                        isAccurate: _isHeadingAccurate,
                        isStatic: !_isSensorMode,
                        showKaabaIcon: true,
                      ),
              ),
            ),
            if (_isSensorMode) ...[
              _buildCalibrationBanner(theme),
              _buildArButton(theme),
            ],
            _buildActionBar(theme),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          Navigator.pushReplacementNamed(context, _routeForIndex(index));
        },
      ),
    );
  }

  Widget _buildCalibrationBanner(ThemeData theme) {
    final accuracyText = _isHeadingAccurate ? 'Yüksek' : 'Düşük';
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isHeadingAccurate ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Sensör doğruluğu: $accuracyText. Kalibrasyon için cihazınızı 8 şeklinde hareket ettirin.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Icon(
            Icons.sensors,
            color: _isHeadingAccurate ? Colors.green : Colors.orange,
            size: 20,
          ),
        ],
      ),
    );
  }


  Widget _buildArButton(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(
          Icons.view_in_ar,
          color: theme.colorScheme.onSecondary,
        ),
        label: Text(
          'AR Kıble Modu',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const QiblaArScreen(),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
      color: theme.colorScheme.primaryContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Kâbe’ye Uzaklık: ${_distanceToKaaba.toStringAsFixed(0)} km',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Icon(Icons.info_outline,
                  size: 16, color: theme.colorScheme.onPrimaryContainer),
              SizedBox(width: 2.w),
              Text(
                _isSensorMode ? 'Sensör: Aktif' : 'Sensör: Demo',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            icon: Icons.refresh,
            label: 'Yenile',
            onPressed: _initializeSensors,
            theme: theme,
          ),
          _buildActionButton(
            icon: Icons.location_on,
            label: 'Konum',
            onPressed: _getCurrentLocation,
            theme: theme,
          ),
          _buildActionButton(
            icon: Icons.info_outline,
            label: 'Bilgi',
            onPressed: _showInfoDialog,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ThemeData theme,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 28),
          onPressed: onPressed,
          color: theme.colorScheme.primary,
          tooltip: label,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _routeForIndex(int index) {
    switch (index) {
      case 0:
        return '/home-screen-prayer-times';
      case 1:
        return '/qibla-direction-screen';
      case 2:
        return '/digital-tasbih-counter-screen';
      case 3:
        return '/quran-i-kerim-screen';
      case 4:
        return '/settings-screen';
      default:
        return '/home-screen-prayer-times';
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kıble Pusulası Hakkında'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isSensorMode
                    ? 'Bu pusula, gerçek zamanlı olarak Kâbe yönünü gösterir.'
                    : 'Demo modunda, sabit bir pusula gösterilir.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildInfoSection(
                'Nasıl Kullanılır?',
                _isSensorMode
                    ? '• Cihazınızı yatay tutun\n'
                        '• Yeşil ok Kâbe yönünü gösterir\n'
                        '• Ok ekranın ortasına geldiğinde Cebre yönelmiş olursunuz'
                    : '• Demo modunda sabit olarak yön gösterilir\n'
                        '• Mobilde konum izni vererek gerçek pusulayı kullanın',
              ),
              const SizedBox(height: 16),
              _buildInfoSection(
                'Kalibrasyon',
                'Metalik yüzeylerden uzak durun ve cihazınızı 8 şeklinde hareket ettirin.',
              ),
              const SizedBox(height: 16),
              _buildInfoSection(
                'Not',
                'Doğru konum bilgisi vetdiğinde mesafe ve yön daha hassas olur.',
              ),
            ],
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

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Text(content),
      ],
    );
  }
}
