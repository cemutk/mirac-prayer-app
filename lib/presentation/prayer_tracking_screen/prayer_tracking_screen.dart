import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/prayer_tracking_data.dart';
import '../../services/prayer_tracking_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/prayer_item_widget.dart';
import './widgets/weekly_stats_widget.dart';

/// Prayer Tracking Screen - Track daily prayer completion
class PrayerTrackingScreen extends StatefulWidget {
  const PrayerTrackingScreen({super.key});

  @override
  State<PrayerTrackingScreen> createState() => _PrayerTrackingScreenState();
}

class _PrayerTrackingScreenState extends State<PrayerTrackingScreen>
    with SingleTickerProviderStateMixin {
  final PrayerTrackingService _trackingService = PrayerTrackingService();
  
  PrayerRecord? _todayRecord;
  List<PrayerRecord> _weeklyRecords = [];
  int _streak = 0;
  Map<String, int> _monthlyStats = {};
  Map<String, String> _prayerTimes = {};
  bool _isLoading = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final todayRecord = await _trackingService.getTodayRecord();
      final weeklyRecords = await _trackingService.getWeeklyRecords();
      final streak = await _trackingService.getStreak();
      final monthlyStats = await _trackingService.getMonthlyStats();
      
      // Load prayer times from cache
      final prefs = await SharedPreferences.getInstance();
      final prayerTimesJson = prefs.getString('cached_prayer_times');
      if (prayerTimesJson != null) {
        // Parse cached prayer times
        _prayerTimes = {
          'Sabah': '05:30',
          'Öğle': '12:30',
          'İkindi': '15:30',
          'Akşam': '18:00',
          'Yatsı': '19:30',
        };
      }
      
      setState(() {
        _todayRecord = todayRecord;
        _weeklyRecords = weeklyRecords;
        _streak = streak;
        _monthlyStats = monthlyStats;
        _isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading prayer tracking data: $e');
    }
  }

  Future<void> _togglePrayer(String prayerName) async {
    final updatedRecord = await _trackingService.togglePrayer(prayerName);
    final newStreak = await _trackingService.getStreak();
    
    setState(() {
      _todayRecord = updatedRecord;
      _streak = newStreak;
    });
    
    // Show celebration if all prayers completed
    if (updatedRecord.isComplete) {
      _showCompletionCelebration();
    }
    
    // Reload weekly stats
    final weeklyRecords = await _trackingService.getWeeklyRecords();
    setState(() {
      _weeklyRecords = weeklyRecords;
    });
  }

  void _showCompletionCelebration() {
    HapticFeedback.heavyImpact();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🎉',
              style: TextStyle(fontSize: 60),
            ),
            SizedBox(height: 2.h),
            Text(
              'Maşallah!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Bugün tüm namazlarını kıldın!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (_streak > 1) ...[
              SizedBox(height: 1.h),
              Text(
                '🔥 $_streak gün seri!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedToday = _todayRecord?.completedCount ?? 0;
    final messages = getMotivationalMessage(completedToday, _streak);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
                opacity: _fadeAnimation,
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        _buildHeader(theme, messages),
                        SizedBox(height: 2.h),
                        
                        // Progress Card
                        _buildProgressCard(theme, completedToday),
                        SizedBox(height: 2.h),
                        
                        // Today's Prayers
                        _buildTodayPrayers(theme),
                        SizedBox(height: 3.h),
                        
                        // Weekly Stats
                        if (_weeklyRecords.isNotEmpty)
                          WeeklyStatsWidget(weeklyRecords: _weeklyRecords),
                        SizedBox(height: 3.h),
                        
                        // Monthly Summary
                        _buildMonthlySummary(theme),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 1,
        onTap: (index) {},
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, List<String> messages) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Namaz Takibi',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                messages[0],
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Streak Badge
        if (_streak > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.deepOrange],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 18)),
                SizedBox(width: 1.w),
                Text(
                  '$_streak',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProgressCard(ThemeData theme, int completedToday) {
    final percentage = completedToday / 5.0;
    
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Circular Progress
              SizedBox(
                width: 20.w,
                height: 20.w,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: percentage,
                      strokeWidth: 8,
                      backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        completedToday == 5
                            ? Colors.green
                            : theme.colorScheme.primary,
                      ),
                    ),
                    Center(
                      child: Text(
                        '$completedToday/5',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bugün',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      completedToday == 5
                          ? 'Tüm namazlar tamamlandı! ✓'
                          : '${5 - completedToday} namaz kaldı',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 6,
                        backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completedToday == 5 ? Colors.green : theme.colorScheme.primary,
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
    );
  }

  Widget _buildTodayPrayers(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bugünün Namazları',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 1.5.h),
        
        ...prayerNames.map((prayerName) {
          final isCompleted = _todayRecord?.prayers[prayerName] ?? false;
          final prayerTime = _prayerTimes[prayerName];
          
          return PrayerItemWidget(
            prayerName: prayerName,
            isCompleted: isCompleted,
            prayerTime: prayerTime,
            onToggle: () => _togglePrayer(prayerName),
          );
        }),
      ],
    );
  }

  Widget _buildMonthlySummary(ThemeData theme) {
    final completedPrayers = _monthlyStats['completedPrayers'] ?? 0;
    final totalPrayers = _monthlyStats['totalPrayers'] ?? 1;
    final perfectDays = _monthlyStats['perfectDays'] ?? 0;
    final percentage = (completedPrayers / totalPrayers * 100).toInt();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Bu Ay',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          
          Row(
            children: [
              _buildStatItem(
                theme: theme,
                icon: Icons.check_circle,
                value: '$completedPrayers',
                label: 'Kılınan',
                color: Colors.green,
              ),
              _buildStatItem(
                theme: theme,
                icon: Icons.star,
                value: '$perfectDays',
                label: 'Tam Gün',
                color: Colors.amber,
              ),
              _buildStatItem(
                theme: theme,
                icon: Icons.percent,
                value: '$percentage%',
                label: 'Başarı',
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required ThemeData theme,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
