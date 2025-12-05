import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

/// Splash Screen - Branded app launch with initialization
/// Displays app logo with Islamic calligraphy during 2-3 second initialization
/// Handles location permissions, saved preferences, and navigation routing
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isInitialized = false;
  bool _showOfflineOption = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  /// Setup fade animation for logo
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  /// Initialize app with all required checks and data loading
  Future<void> _initializeApp() async {
    try {
      // Start timeout timer for network operations
      _timeoutTimer = Timer(const Duration(seconds: 5), () {
        if (!_isInitialized && mounted) {
          setState(() => _showOfflineOption = true);
        }
      });

      // Run initialization tasks in parallel
      await Future.wait([
        _checkConnectivity(),
        _checkLocationPermission(),
        _loadSavedPreferences(),
        Future.delayed(const Duration(seconds: 2)), // Minimum splash duration
      ]);

      _isInitialized = true;
      _timeoutTimer?.cancel();

      // Navigate based on initialization results
      if (mounted) {
        await _navigateToNextScreen();
      }
    } catch (e) {
      // Handle initialization errors gracefully
      if (mounted) {
        setState(() => _showOfflineOption = true);
      }
    }
  }

  /// Check network connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      // Store connectivity status for later use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
          'has_connectivity', connectivityResult != ConnectivityResult.none);
    } catch (e) {
      // Connectivity check failed, assume offline
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_connectivity', false);
    }
  }

  /// Check and request location permission
  Future<void> _checkLocationPermission() async {
    try {
      final status = await Permission.location.status;
      final prefs = await SharedPreferences.getInstance();

      if (status.isGranted) {
        await prefs.setBool('location_permission_granted', true);
      } else if (status.isDenied) {
        // Request permission
        final result = await Permission.location.request();
        await prefs.setBool('location_permission_granted', result.isGranted);
      } else {
        await prefs.setBool('location_permission_granted', false);
      }
    } catch (e) {
      // Permission check failed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('location_permission_granted', false);
    }
  }

  /// Load saved user preferences
  Future<void> _loadSavedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if user has saved city preference
      final savedCity = prefs.getString('saved_city');
      final savedDistrict = prefs.getString('saved_district');

      // Store for navigation decision
      await prefs.setBool(
          'has_saved_location', savedCity != null && savedDistrict != null);

      // Load other preferences
        // Cache loaded preferences
        await prefs.setBool('preferences_loaded', true);
    } catch (e) {
      // Preferences loading failed, use defaults
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_saved_location', false);
      await prefs.setBool('preferences_loaded', false);
    }
  }

  /// Navigate to appropriate screen based on initialization results
  Future<void> _navigateToNextScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSavedLocation = prefs.getBool('has_saved_location') ?? false;
      final locationPermissionGranted =
          prefs.getBool('location_permission_granted') ?? false;

      // Add smooth transition delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Navigation logic
      if (hasSavedLocation) {
        // User has saved location, go to home
        Navigator.pushReplacementNamed(context, '/home-screen-prayer-times');
      } else if (locationPermissionGranted) {
        // Has permission but no saved location, show city selection
        Navigator.pushReplacementNamed(context, '/city-selection-screen');
      } else {
        // No permission, show manual city selection
        Navigator.pushReplacementNamed(context, '/city-selection-screen');
      }
    } catch (e) {
      // Navigation failed, default to city selection
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/city-selection-screen');
      }
    }
  }

  /// Handle continue offline button press
  void _handleContinueOffline() {
    _timeoutTimer?.cancel();
    _navigateToNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: theme.colorScheme.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer,
              theme.colorScheme.surface.withValues(alpha: 0.95),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // App Logo with fade animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildAppLogo(theme),
              ),

              SizedBox(height: 8.h),

              // App Name
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Mirac Prayer Assistant',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 2.h),

              // Tagline
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Your Daily Prayer Companion',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(flex: 2),

              // Loading indicator or offline option
              _buildBottomSection(theme),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Build app logo with Islamic calligraphy elements
  Widget _buildAppLogo(ThemeData theme) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: SvgPicture.asset(
            'assets/images/img_app_logo.svg',
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  /// Build bottom section with loading indicator or offline option
  Widget _buildBottomSection(ThemeData theme) {
    if (_showOfflineOption) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Network timeout',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: _handleContinueOffline,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.primary,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Continue Offline',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 8.w,
          height: 8.w,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.onPrimary,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Initializing...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
