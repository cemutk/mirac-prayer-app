import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../data/prayer_tracking_data.dart';

/// Widget for displaying weekly statistics chart
class WeeklyStatsWidget extends StatelessWidget {
  final List<PrayerRecord> weeklyRecords;

  const WeeklyStatsWidget({
    super.key,
    required this.weeklyRecords,
  });

  String _getDayName(int index) {
    final date = DateTime.now().subtract(Duration(days: 6 - index));
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                Icons.bar_chart,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Haftalık Özet',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          
          // Bar Chart
          SizedBox(
            height: 15.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final record = weeklyRecords[index];
                final isToday = index == 6;
                final completedCount = record.completedCount;
                final percentage = completedCount / 5.0;
                
                return _buildDayBar(
                  context: context,
                  dayName: _getDayName(index),
                  percentage: percentage,
                  completedCount: completedCount,
                  isToday: isToday,
                  isPerfect: record.isComplete,
                );
              }),
            ),
          ),
          
          SizedBox(height: 2.h),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(context, '5/5', Colors.green, 'Tam'),
              SizedBox(width: 4.w),
              _buildLegendItem(context, '3-4', Colors.orange, 'İyi'),
              SizedBox(width: 4.w),
              _buildLegendItem(context, '1-2', Colors.red.shade300, 'Az'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayBar({
    required BuildContext context,
    required String dayName,
    required double percentage,
    required int completedCount,
    required bool isToday,
    required bool isPerfect,
  }) {
    final theme = Theme.of(context);
    
    Color barColor;
    if (completedCount == 5) {
      barColor = Colors.green;
    } else if (completedCount >= 3) {
      barColor = Colors.orange;
    } else if (completedCount >= 1) {
      barColor = Colors.red.shade300;
    } else {
      barColor = theme.colorScheme.outline.withValues(alpha: 0.3);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Count
        Text(
          completedCount.toString(),
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: barColor,
          ),
        ),
        SizedBox(height: 0.5.h),
        
        // Bar
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          width: 8.w,
          height: percentage > 0 ? (percentage * 10.h) : 0.5.h,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isPerfect
                ? [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: isPerfect
              ? Center(
                  child: Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 14,
                  ),
                )
              : null,
        ),
        SizedBox(height: 0.5.h),
        
        // Day name
        Container(
          padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
          decoration: isToday
              ? BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(6),
                )
              : null,
          child: Text(
            dayName,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color, String text) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
