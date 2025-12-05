import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Statistics view showing daily, weekly, and monthly counting summaries
class StatisticsViewWidget extends StatefulWidget {
  final Map<String, int> dailyStats;
  final Map<String, int> weeklyStats;
  final Map<String, int> monthlyStats;

  const StatisticsViewWidget({
    super.key,
    required this.dailyStats,
    required this.weeklyStats,
    required this.monthlyStats,
  });

  @override
  State<StatisticsViewWidget> createState() => _StatisticsViewWidgetState();
}

class _StatisticsViewWidgetState extends State<StatisticsViewWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _getTotalCount(Map<String, int> stats) {
    return stats.values.fold(0, (sum, count) => sum + count);
  }

  List<BarChartGroupData> _getBarChartData(
      Map<String, int> stats, int maxEntries) {
    final sortedEntries = stats.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    final limitedEntries = sortedEntries.take(maxEntries).toList();

    return List.generate(limitedEntries.length, (index) {
      final entry = limitedEntries[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Theme.of(context).colorScheme.primary,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          SizedBox(height: 2.h),
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Statistics',
                  style: theme.textTheme.titleLarge,
                ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'close',
                    size: 24,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStatsView(widget.dailyStats, 'Daily', 7),
                _buildStatsView(widget.weeklyStats, 'Weekly', 4),
                _buildStatsView(widget.monthlyStats, 'Monthly', 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsView(
      Map<String, int> stats, String period, int maxEntries) {
    final theme = Theme.of(context);
    final totalCount = _getTotalCount(stats);

    return stats.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'bar_chart',
                  size: 64,
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                ),
                SizedBox(height: 2.h),
                Text(
                  'No $period data yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Count',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            totalCount.toString(),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      CustomIconWidget(
                        iconName: 'trending_up',
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  '$period Activity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
                  height: 30.h,
                  padding: EdgeInsets.all(2.w),
                  child: Semantics(
                    label: '$period Tasbih Count Bar Chart',
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: stats.values.isEmpty
                            ? 100
                            : stats.values
                                    .reduce((a, b) => a > b ? a : b)
                                    .toDouble() *
                                1.2,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final sortedEntries = stats.entries.toList()
                                  ..sort((a, b) => b.key.compareTo(a.key));
                                final limitedEntries =
                                    sortedEntries.take(maxEntries).toList();

                                if (value.toInt() >= 0 &&
                                    value.toInt() < limitedEntries.length) {
                                  final key = limitedEntries[value.toInt()].key;
                                  final label = key.split('-').last;
                                  return Text(
                                    label,
                                    style: theme.textTheme.bodySmall,
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: theme.textTheme.bodySmall,
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: stats.values.isEmpty ? 20 : null,
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: _getBarChartData(stats, maxEntries),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
