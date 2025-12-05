import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../data/religious_days_data.dart';
import './widgets/religious_event_card_widget.dart';

/// Religious Days Screen displaying Islamic calendar events and significant dates
/// Accessible via calendar icon in Home screen AppBar
/// Features smart filtering to show only current and future events
class ReligiousDaysScreen extends StatefulWidget {
  const ReligiousDaysScreen({super.key});

  @override
  State<ReligiousDaysScreen> createState() => _ReligiousDaysScreenState();
}

class _ReligiousDaysScreenState extends State<ReligiousDaysScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _favoriteEvents = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Get filtered events showing only current and future events
  List<ReligiousDayData> _getFilteredEvents() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    // Filter by date (show today and future)
    List<ReligiousDayData> filtered = religiousDaysList
        .where((event) => event.date.isAfter(yesterday))
        .toList();

    // Apply search filter if query exists
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((event) =>
              event.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              event.description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Sort by date
    filtered.sort((a, b) => a.date.compareTo(b.date));

    return filtered;
  }

  /// Group events by year for section headers
  Map<int, List<ReligiousDayData>> _groupEventsByYear(
      List<ReligiousDayData> events) {
    final Map<int, List<ReligiousDayData>> grouped = {};

    for (var event in events) {
      if (!grouped.containsKey(event.year)) {
        grouped[event.year] = [];
      }
      grouped[event.year]!.add(event);
    }

    return grouped;
  }

  void _toggleFavorite(String eventName) {
    setState(() {
      if (_favoriteEvents.contains(eventName)) {
        _favoriteEvents.remove(eventName);
      } else {
        _favoriteEvents.add(eventName);
      }
    });
    HapticFeedback.lightImpact();
  }

  String _getCurrentIslamicDate() {
    // Mock Islamic date - in production, use proper Islamic calendar package
    return "15 Cemâziyelâhir 1446";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredEvents = _getFilteredEvents();
    final groupedEvents = _groupEventsByYear(filteredEvents);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Dini Günler',
        subtitle: _getCurrentIslamicDate(),
        centerTitle: true,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'share',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Share functionality
            },
            tooltip: 'Paylaş',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Dini gün ara...',
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.primary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.5.h,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Events List grouped by year
          Expanded(
            child: filteredEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'search_off',
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.3),
                          size: 64,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Sonuç bulunamadı',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    itemCount: groupedEvents.length,
                    itemBuilder: (context, yearIndex) {
                      final year = groupedEvents.keys.elementAt(yearIndex);
                      final yearEvents = groupedEvents[year]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Year Header
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    theme.colorScheme.primary
                                        .withValues(alpha: 0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'calendar_today',
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    year.toString(),
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 3.w,
                                      vertical: 0.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${yearEvents.length} Etkinlik',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Events for this year
                          ...yearEvents.map((event) {
                            // Convert ReligiousDayData to Map format for card widget
                            final eventMap = {
                              'hijriDate': event.hijriDate,
                              'gregorianDate':
                                  '${event.date.day} ${_getMonthName(event.date.month)} ${event.date.year}',
                              'name': event.name,
                              'description': event.description,
                              'practices': event.practices,
                            };

                            return Padding(
                              padding: EdgeInsets.only(bottom: 2.h),
                              child: ReligiousEventCardWidget(
                                event: eventMap,
                                isFavorite:
                                    _favoriteEvents.contains(event.name),
                                onFavoriteToggle: () =>
                                    _toggleFavorite(event.name),
                              ),
                            );
                          }),

                          SizedBox(height: 2.h),
                        ],
                      );
                    },
                  ),
          ),
          // Banner Reklam
          const BannerAdWidget(),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return monthNames[month - 1];
  }
}
