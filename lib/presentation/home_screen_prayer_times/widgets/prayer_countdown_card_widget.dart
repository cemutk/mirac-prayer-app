import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';

/// Widget displaying countdown to next prayer time
/// Updates every second with remaining time
class PrayerCountdownCardWidget extends StatefulWidget {
  final Map<String, dynamic>? nextPrayer;

  const PrayerCountdownCardWidget({
    super.key,
    required this.nextPrayer,
  });

  @override
  State<PrayerCountdownCardWidget> createState() =>
      _PrayerCountdownCardWidgetState();
}

class _PrayerCountdownCardWidgetState extends State<PrayerCountdownCardWidget> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _calculateRemainingTime();
        });
      }
    });
  }

  void _calculateRemainingTime() {
    if (widget.nextPrayer == null) {
      _remainingTime = Duration.zero;
      return;
    }

    final now = DateTime.now();
    final prayerTimeStr = widget.nextPrayer!["time"] as String;
    final timeParts = prayerTimeStr.split(':');
    final prayerTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    if (prayerTime.isBefore(now)) {
      _remainingTime = prayerTime.add(const Duration(days: 1)).difference(now);
    } else {
      _remainingTime = prayerTime.difference(now);
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.nextPrayer == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Sonraki Vakit',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            widget.nextPrayer!["name"] as String,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 6.w,
              vertical: 2.h,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  _formatDuration(_remainingTime),
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'kaldı',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
              SizedBox(width: 1.w),
              Text(
                widget.nextPrayer!["time"] as String,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
