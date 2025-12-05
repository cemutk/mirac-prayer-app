import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../services/ad_service.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/completion_dialog_widget.dart';
import './widgets/counter_circle_widget.dart';
import './widgets/dhikr_selector_widget.dart';
import './widgets/history_bottom_sheet_widget.dart';
import './widgets/statistics_view_widget.dart';
import './widgets/target_selector_widget.dart';

/// Digital Tasbih Counter Screen - Third tab in bottom navigation
/// Provides customizable dhikr counting with haptic feedback and progress tracking
class DigitalTasbihCounterScreen extends StatefulWidget {
  const DigitalTasbihCounterScreen({super.key});

  @override
  State<DigitalTasbihCounterScreen> createState() =>
      _DigitalTasbihCounterScreenState();
}

class _DigitalTasbihCounterScreenState extends State<DigitalTasbihCounterScreen>
    with TickerProviderStateMixin {
  // Counter state
  int _currentCount = 0;
  int _targetCount = 33;
  String _selectedDhikr = 'SubhanAllah';
  bool _isCustomDhikr = false;
  String _customDhikrText = '';

  // Animation controllers
  late AnimationController _scaleController;
  late AnimationController _progressController;
  late Animation<double> _scaleAnimation;

  // Session management
  List<Map<String, dynamic>> _sessionHistory = [];
  Map<String, dynamic> _currentSession = {};

  // Statistics
  Map<String, int> _dailyStats = {};
  Map<String, int> _weeklyStats = {};
  Map<String, int> _monthlyStats = {};

  // Preset dhikr options
  final List<Map<String, String>> _dhikrPresets = [
    {
      'name': 'Subhanallah',
      'arabic': 'سُبْحَانَ اللّٰهِ',
      'transliteration': 'Subhanallah'
    },
    {
      'name': 'Elhamdülillah',
      'arabic': 'الْحَمْدُ لِلّٰهِ',
      'transliteration': 'Elhamdülillah'
    },
    {
      'name': 'Allahuekber',
      'arabic': 'اللّٰهُ أَكْبَرُ',
      'transliteration': 'Allahuekber'
    },
    {
      'name': 'Lailaheillallah',
      'arabic': 'لَا إِلٰهَ إِلَّا اللّٰهُ',
      'transliteration': 'Lailaheillallah'
    },
  ];

  // Target count options
  final List<int> _targetOptions = [33, 99, 100, 1000];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSavedData();
    _initializeSession();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkForNavigationArguments();
  }

  void _checkForNavigationArguments() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        if (args['dhikrName'] != null) {
          _selectedDhikr = args['dhikrName'];
        }
        if (args['targetCount'] != null) {
          _targetCount = args['targetCount'];
        }
        if (args['customDhikr'] == true) {
          _isCustomDhikr = true;
          if (args['arabicText'] != null) {
            _customDhikrText = args['arabicText'];
          }
        }
        // Reset count when coming from Esmaul Husna
        _currentCount = 0;
        _currentSession['dhikr'] =
            _isCustomDhikr ? _customDhikrText : _selectedDhikr;
        _currentSession['target'] = _targetCount;
        _currentSession['count'] = _currentCount;
      });
      _updateProgress();
      _saveData();
    }
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  void _initializeSession() {
    _currentSession = {
      'dhikr': _selectedDhikr,
      'target': _targetCount,
      'count': _currentCount,
      'startTime': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load current count and settings
      setState(() {
        _currentCount = prefs.getInt('tasbih_current_count') ?? 0;
        _targetCount = prefs.getInt('tasbih_target_count') ?? 33;
        _selectedDhikr =
            prefs.getString('tasbih_selected_dhikr') ?? 'SubhanAllah';
        _isCustomDhikr = prefs.getBool('tasbih_is_custom') ?? false;
        _customDhikrText = prefs.getString('tasbih_custom_text') ?? '';

        // Load session history
        final historyJson = prefs.getString('tasbih_history');
        if (historyJson != null) {
          _sessionHistory =
              List<Map<String, dynamic>>.from(json.decode(historyJson));
        }

        // Load statistics
        final dailyJson = prefs.getString('tasbih_daily_stats');
        if (dailyJson != null) {
          _dailyStats = Map<String, int>.from(json.decode(dailyJson));
        }

        final weeklyJson = prefs.getString('tasbih_weekly_stats');
        if (weeklyJson != null) {
          _weeklyStats = Map<String, int>.from(json.decode(weeklyJson));
        }

        final monthlyJson = prefs.getString('tasbih_monthly_stats');
        if (monthlyJson != null) {
          _monthlyStats = Map<String, int>.from(json.decode(monthlyJson));
        }
      });

      _updateProgress();
    } catch (e) {
      debugPrint('Error loading tasbih data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tasbih_current_count', _currentCount);
      await prefs.setInt('tasbih_target_count', _targetCount);
      await prefs.setString('tasbih_selected_dhikr', _selectedDhikr);
      await prefs.setBool('tasbih_is_custom', _isCustomDhikr);
      await prefs.setString('tasbih_custom_text', _customDhikrText);
      await prefs.setString('tasbih_history', json.encode(_sessionHistory));
      await prefs.setString('tasbih_daily_stats', json.encode(_dailyStats));
      await prefs.setString('tasbih_weekly_stats', json.encode(_weeklyStats));
      await prefs.setString('tasbih_monthly_stats', json.encode(_monthlyStats));
    } catch (e) {
      debugPrint('Error saving tasbih data: $e');
    }
  }

  void _incrementCount() {
    if (_currentCount >= 9999) return;

    HapticFeedback.lightImpact();
    _scaleController.forward().then((_) => _scaleController.reverse());

    setState(() {
      _currentCount++;
      _currentSession['count'] = _currentCount;
    });

    _updateProgress();
    _updateStatistics();
    _saveData();

    if (_currentCount >= _targetCount) {
      _showCompletionDialog();
    }
  }

  void _decrementCount() {
    if (_currentCount <= 0) return;

    HapticFeedback.lightImpact();

    setState(() {
      _currentCount--;
      _currentSession['count'] = _currentCount;
    });

    _updateProgress();
    _saveData();
  }

  void _updateProgress() {
    final progress =
        _targetCount > 0 ? (_currentCount / _targetCount).clamp(0.0, 1.0) : 0.0;
    _progressController.animateTo(progress,
        duration: const Duration(milliseconds: 300));
  }

  void _updateStatistics() {
    final now = DateTime.now();
    final dateKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final weekKey = '${now.year}-W${_getWeekNumber(now)}';
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    setState(() {
      _dailyStats[dateKey] = (_dailyStats[dateKey] ?? 0) + 1;
      _weeklyStats[weekKey] = (_weeklyStats[weekKey] ?? 0) + 1;
      _monthlyStats[monthKey] = (_monthlyStats[monthKey] ?? 0) + 1;
    });
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday) / 7).ceil();
  }

  void _resetCounter() {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sayacı Sıfırla',
            style: Theme.of(context).textTheme.titleLarge),
        content: Text(
          'Sayacı sıfırlamak istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performReset();
            },
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }

  void _performReset() {
    setState(() {
      _currentCount = 0;
      _currentSession['count'] = 0;
    });
    _updateProgress();
    _saveData();
  }

  void _showCompletionDialog() {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CompletionDialogWidget(
        dhikr: _isCustomDhikr ? _customDhikrText : _selectedDhikr,
        count: _currentCount,
        onContinue: () {
          Navigator.pop(context);
        },
        onNewSession: () {
          Navigator.pop(context);
          _saveSession();
          _performReset();
        },
      ),
    );
  }

  void _saveSession() {
    final session = {
      'dhikr': _isCustomDhikr ? _customDhikrText : _selectedDhikr,
      'count': _currentCount,
      'target': _targetCount,
      'startTime': _currentSession['startTime'],
      'endTime': DateTime.now().toIso8601String(),
      'completed': _currentCount >= _targetCount,
    };

    setState(() {
      _sessionHistory.insert(0, session);
      if (_sessionHistory.length > 50) {
        _sessionHistory = _sessionHistory.sublist(0, 50);
      }
    });

    _saveData();
    
    // Oturum kaydedildikten sonra interstitial reklam göster
    AdService().showInterstitialAd();
  }

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HistoryBottomSheetWidget(
        sessions: _sessionHistory,
        onDeleteSession: (index) {
          setState(() {
            _sessionHistory.removeAt(index);
          });
          _saveData();
        },
      ),
    );
  }

  void _showStatisticsView() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatisticsViewWidget(
        dailyStats: _dailyStats,
        weeklyStats: _weeklyStats,
        monthlyStats: _monthlyStats,
      ),
    );
  }

  void _onDhikrSelected(String dhikr, bool isCustom, String customText) {
    setState(() {
      _selectedDhikr = dhikr;
      _isCustomDhikr = isCustom;
      _customDhikrText = customText;
      _currentSession['dhikr'] = isCustom ? customText : dhikr;
    });
    _saveData();
  }

  void _onTargetSelected(int target) {
    setState(() {
      _targetCount = target;
      _currentSession['target'] = target;
    });
    _updateProgress();
    _saveData();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! < -100) {
                _incrementCount();
              } else if (details.primaryVelocity! > 100) {
                _decrementCount();
              }
            }
          },
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dijital Tesbih',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: CustomIconWidget(
                        iconName: 'bar_chart',
                        size: 24,
                        color: theme.colorScheme.onSurface,
                      ),
                      onPressed: _showStatisticsView,
                      tooltip: 'İstatistikleri Görüntüle',
                    ),
                  ],
                ),
              ),

              // Dhikr Selector
              DhikrSelectorWidget(
                presets: _dhikrPresets,
                selectedDhikr: _selectedDhikr,
                isCustom: _isCustomDhikr,
                customText: _customDhikrText,
                onDhikrSelected: _onDhikrSelected,
              ),

              SizedBox(height: 3.h),

              // Counter Circle
              Expanded(
                child: Center(
                  child: CounterCircleWidget(
                    currentCount: _currentCount,
                    targetCount: _targetCount,
                    scaleAnimation: _scaleAnimation,
                    progressController: _progressController,
                    onTap: _incrementCount,
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              // Target Selector
              TargetSelectorWidget(
                targetOptions: _targetOptions,
                selectedTarget: _targetCount,
                onTargetSelected: _onTargetSelected,
              ),

              SizedBox(height: 3.h),

              // Action Buttons
              ActionButtonsWidget(
                onReset: _resetCounter,
                onHistory: _showHistorySheet,
              ),

              SizedBox(height: 2.h),
              
              // Banner Ad at bottom of tesbih screen
              const BannerAdWidget(),
              
              SizedBox(height: 1.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 2,
        onTap: (index) {},
      ),
    );
  }
}
