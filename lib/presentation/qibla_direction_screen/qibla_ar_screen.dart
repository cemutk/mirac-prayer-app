import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass_v2/flutter_compass_v2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sizer/sizer.dart';

class QiblaArScreen extends StatefulWidget {
  const QiblaArScreen({super.key});

  @override
  State<QiblaArScreen> createState() => _QiblaArScreenState();
}

class _QiblaArScreenState extends State<QiblaArScreen> {
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  CameraController? _cameraController;
  StreamSubscription<CompassEvent>? _compassSubscription;
  Position? _currentPosition;
  double _deviceHeading = 0;
  double _qiblaDirection = 0;
  bool _hasHeading = false;
  bool _hasQiblaDirection = false;
  bool _isHeadingAccurate = false;
  bool _cameraReady = false;
  bool _isInitializing = true;
  String _statusMessage = 'Sensör verisi bekleniyor...';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeSensors();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _cameraController?.initialize();
      if (mounted) {
        setState(() {
          _cameraReady = _cameraController?.value.isInitialized ?? false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _cameraReady = false;
        });
      }
    }
  }

  Future<void> _initializeSensors() async {
    if (mounted) {
      setState(() {
        _isInitializing = true;
        _statusMessage = 'Konum ve sensör kuruluyor...';
        _hasHeading = false;
        _hasQiblaDirection = false;
        _isHeadingAccurate = false;
      });
    }

    if (kIsWeb) {
      if (mounted) {
        setState(() {
          _statusMessage = 'AR modu Web üzerinde desteklenmiyor';
          _isInitializing = false;
        });
      }
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

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition()
          .timeout(const Duration(seconds: 10));

      if (_currentPosition != null) {
        _qiblaDirection = _calculateQiblaBearing(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        _hasQiblaDirection = true;
        if (mounted) {
          setState(() {
            _statusMessage = 'Konum alındı, doğruluk ayarlanıyor';
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Konum okunamadı';
        });
      }
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
            : 0;
        setState(() {
          _deviceHeading = heading;
          _hasHeading = true;
          if (_hasQiblaDirection) {
            _isHeadingAccurate = diff.abs() <= 3;
            _statusMessage = 'Kıble yönü güncel';
            _isInitializing = false;
          } else {
            _statusMessage = 'Konum bekleniyor...';
          }
        });
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

  Future<bool> _requestLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _statusMessage = 'Konum servisi kapalı';
          });
        }
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _statusMessage = 'Konum izni reddedildi';
            });
          }
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _statusMessage = 'Konum izni kalıcı olarak reddedildi';
          });
        }
        return false;
      }

      return true;
    } catch (_) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Konum isteği başarısız oldu';
        });
      }
      return false;
    }
  }

  double _angleDifference() {
    if (!_hasQiblaDirection || !_hasHeading) return 0;
    return _normalizeAngle(_qiblaDirection - _deviceHeading);
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

  double _normalizeAngle(double angle) {
    if (angle > 180) return angle - 360;
    if (angle < -180) return angle + 360;
    return angle;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alignmentPercent = _hasQiblaDirection && _hasHeading
        ? (100 - _angleDifference().abs()).clamp(0, 100).round()
        : 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Kıble Rehberi'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_cameraReady && _cameraController != null)
            CameraPreview(_cameraController!)
          else
            Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: const Text(
                'Kamera başlatılamadı.\nLütfen uygulama izinlerini kontrol edin.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Center(
                        child: Transform.rotate(
                          angle: math.pi / 180 * _angleDifference(),
                          child: Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _isHeadingAccurate
                                    ? Colors.green
                                    : Colors.yellow,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.navigation,
                                size: 12.w,
                                color: _isHeadingAccurate
                                    ? Colors.green
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_isInitializing)
                        const Positioned(
                          top: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      else
                        _buildStatusBadge(theme),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(166),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kalibrasyon Durumu',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        _hasQiblaDirection
                            ? 'Hedefinize ${_angleDifference().abs().toStringAsFixed(1)}° sapma ile yönlendiriliyorsunuz.'
                            : 'Konum bilgisi alındıktan sonra AR pusulası aktif olur.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      LinearProgressIndicator(
                        value: alignmentPercent / 100,
                        color: _isHeadingAccurate ? Colors.green : Colors.orange,
                        backgroundColor: Colors.white12,
                        minHeight: 6,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Cihazınızı dik tutun ve 8 hareketi ile kalibre edin.',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
                      ),
                      SizedBox(height: 1.h),
                      _buildArInstructions(theme),
                      SizedBox(height: 1.5.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Yeniden Hizala'),
                            onPressed: _initializeSensors,
                          ),
                          Text(
                            '$alignmentPercent% uyum',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: _isHeadingAccurate ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
      color: Colors.black.withAlpha(179),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        _statusMessage,
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildArInstructions(ThemeData theme) {
    const tips = [
      'Kamerayı Kâbe yönüne çevirirken ekranın ortasındaki yön göstergesine bakın.',
      'Işığın yeterli olduğundan ve doğrudan parlamadığından emin olun.',
      'Yüz deseni oluşturmadan önce uyum değeri görünene kadar sabit durun.',
      'Sorun olursa "Yeniden Hizala" ile akışı tekrar başlatın.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tips
          .map(
            (tip) => Padding(
              padding: EdgeInsets.only(bottom: 0.6.h),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 16, color: Colors.white70),
                  SizedBox(width: 1.w),
                  Expanded(
                    child: Text(
                      tip,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
