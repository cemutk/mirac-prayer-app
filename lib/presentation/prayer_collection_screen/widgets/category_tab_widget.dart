import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Category tab widget for prayer collection
/// Displays horizontal scrollable category tabs with smooth indicator animation
class CategoryTabWidget extends StatelessWidget {
  final List<String> categories;
  final TabController tabController;
  final VoidCallback onTabChanged;

  const CategoryTabWidget({
    super.key,
    required this.categories,
    required this.tabController,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        onTap: (index) => onTabChanged(),
        tabs: categories.map((category) {
          final categoryIndex = categories.indexOf(category);
          final prayerCount = _getCategoryPrayerCount(category);

          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(category),
                SizedBox(width: 1.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
                  decoration: BoxDecoration(
                    color: tabController.index == categoryIndex
                        ? theme.colorScheme.primary.withValues(alpha: 0.12)
                        : theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    prayerCount.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: tabController.index == categoryIndex
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  int _getCategoryPrayerCount(String category) {
    // Mock prayer counts per category
    final Map<String, int> categoryCounts = {
      'Genel': 2,
      'Şükür': 2,
      'İstekler': 2,
      'Sabır': 2,
      'Huzur': 2,
      'Bağışlanma': 2,
    };
    return categoryCounts[category] ?? 0;
  }
}
