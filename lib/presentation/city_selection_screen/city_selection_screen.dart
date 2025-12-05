import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/city_data.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/district_list_widget.dart';
import './widgets/province_card_widget.dart';
import './widgets/recent_selection_chip_widget.dart';

/// City Selection Screen for location-based prayer time configuration
/// Provides searchable Turkish province and district selection with offline data
class CitySelectionScreen extends StatefulWidget {
  final String? initialProvince;
  final String? initialDistrict;

  const CitySelectionScreen({super.key, this.initialProvince, this.initialDistrict});

  @override
  State<CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _expandedProvince;
  List<String> _recentSelections = [];
  Map<String, dynamic> _turkishProvincesData = {};

  @override
  void initState() {
    super.initState();
    _loadCityData();
    _loadRecentSelections();
    // If caller provided initial province/district, preselect after data loads
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Load city and district data from static hardcoded data
  Future<void> _loadCityData() async {
    try {
      debugPrint('🔄 Loading city data from static hardcoded source');

      // CRITICAL: Load from static const data - NO asset loading, NO file reading
      _turkishProvincesData = Map<String, dynamic>.from(turkishCityData);

      // Count total districts for verification
      int totalDistricts = 0;
      for (var districts in _turkishProvincesData.values) {
        totalDistricts += (districts as List).length;
      }

      debugPrint(
          '✅ Successfully loaded ${_turkishProvincesData.length} provinces with $totalDistricts districts');

      // Verify complete data
      if (_turkishProvincesData.length == 81 && totalDistricts == 923) {
        debugPrint(
            '✅ DATA VERIFICATION: All 81 provinces and 923 districts loaded correctly');
      } else {
        debugPrint(
            '⚠️ WARNING: Expected 81 provinces and 923 districts, got ${_turkishProvincesData.length} provinces and $totalDistricts districts');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Preselect initial province/district if provided by caller
        if (widget.initialProvince != null) {
          final prov = widget.initialProvince!;
          if (_turkishProvincesData.containsKey(prov)) {
            setState(() {
              _expandedProvince = prov;
              _selectedProvince = prov;
              // If an initial district was provided and exists, use it
              final districts = List<String>.from(_turkishProvincesData[prov]);
              if (widget.initialDistrict != null &&
                  districts.contains(widget.initialDistrict)) {
                _selectedDistrict = widget.initialDistrict;
              }
            });
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ HATA: Şehir yükleme hatası: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Şehir verileri yüklenirken bir hata oluştu'),
            duration: const Duration(seconds: 3),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _loadRecentSelections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recent = prefs.getStringList('recent_city_selections') ?? [];
      if (mounted) {
        setState(() {
          _recentSelections = recent;
        });
      }
    } catch (e) {
      // Silent fail - recent selections are optional
    }
  }

  Future<void> _saveRecentSelection(String province, String district) async {
    try {
      final selection = '$province - $district';
      final prefs = await SharedPreferences.getInstance();

      // Remove if already exists to avoid duplicates
      _recentSelections.remove(selection);

      // Add to beginning of list
      _recentSelections.insert(0, selection);

      // Keep only last 5 selections
      if (_recentSelections.length > 5) {
        _recentSelections = _recentSelections.sublist(0, 5);
      }

      await prefs.setStringList('recent_city_selections', _recentSelections);
    } catch (e) {
      // Silent fail - recent selections are optional
    }
  }

  List<MapEntry<String, dynamic>> _getFilteredProvinces() {
    if (_searchQuery.isEmpty) {
      return _turkishProvincesData.entries.toList()
        ..sort((a, b) => _turkishSort(a.key, b.key));
    }

    final query = _searchQuery.toLowerCase();
    return _turkishProvincesData.entries.where((entry) {
      final provinceName = entry.key.toLowerCase();
      final districts = entry.value as List<String>;

      // Check if province name matches
      if (provinceName.contains(query)) return true;

      // Check if any district matches
      return districts
          .any((district) => district.toLowerCase().contains(query));
    }).toList()
      ..sort((a, b) => _turkishSort(a.key, b.key));
  }

  int _turkishSort(String a, String b) {
    const turkishOrder =
        'AaBbCcÇçDdEeFfGgĞğHhIıİiJjKkLlMmNnOoÖöPpRrSsŞşTtUuÜüVvYyZz';

    for (int i = 0; i < a.length && i < b.length; i++) {
      final indexA = turkishOrder.indexOf(a[i]);
      final indexB = turkishOrder.indexOf(b[i]);

      if (indexA != indexB) {
        return indexA.compareTo(indexB);
      }
    }

    return a.length.compareTo(b.length);
  }

  void _handleProvinceExpand(String province) {
    HapticFeedback.lightImpact();
    setState(() {
      _expandedProvince = _expandedProvince == province ? null : province;
    });
  }

  void _handleDistrictSelect(String province, String district) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedProvince = province;
      _selectedDistrict = district;
    });
  }

  void _handleRecentSelectionTap(String selection) {
    HapticFeedback.lightImpact();
    final parts = selection.split(' - ');
    if (parts.length == 2) {
      setState(() {
        _selectedProvince = parts[0];
        _selectedDistrict = parts[1];
      });
    }
  }

  Future<void> _handleSaveLocation() async {
    if (_selectedProvince == null || _selectedDistrict == null) {
      return;
    }

    HapticFeedback.mediumImpact();

    // Save to recent selections
    await _saveRecentSelection(_selectedProvince!, _selectedDistrict!);

    // Save selected location
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_province', _selectedProvince!);
      await prefs.setString('selected_district', _selectedDistrict!);
      // Maintain backwards compatibility: also set `selectedCity` preferred by older screens
      await prefs.setString('selectedCity', _selectedProvince!);
    } catch (e) {
      // Silent fail
    }

    if (mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Konum kaydedildi: $_selectedProvince - $_selectedDistrict'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate back to home screen
      Navigator.pushReplacementNamed(context, '/home-screen-prayer-times');
    }
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredProvinces = _getFilteredProvinces();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Şehir Seçimi',
        automaticallyImplyLeading: true,
        centerTitle: true,
        showDivider: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              color: theme.colorScheme.surface,
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Şehir ara...',
                  prefixIcon: CustomIconWidget(
                    iconName: 'search',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: CustomIconWidget(
                            iconName: 'clear',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                            HapticFeedback.lightImpact();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                textInputAction: TextInputAction.search,
              ),
            ),

            // Recent selections
            if (_recentSelections.isNotEmpty && _searchQuery.isEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                color: theme.colorScheme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Son Seçimler',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children: _recentSelections.map((selection) {
                        return RecentSelectionChipWidget(
                          selection: selection,
                          isSelected: selection ==
                              '$_selectedProvince - $_selectedDistrict',
                          onTap: () => _handleRecentSelectionTap(selection),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            // Province list
            Expanded(
              child: _isLoading
                  ? _buildLoadingState(theme)
                  : filteredProvinces.isEmpty
                      ? _buildEmptyState(theme)
                      : RefreshIndicator(
                          onRefresh: _handleRefresh,
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 2.h),
                            itemCount: filteredProvinces.length,
                            itemBuilder: (context, index) {
                              final entry = filteredProvinces[index];
                              final province = entry.key;
                              final districts = entry.value as List<String>;
                              final isExpanded = _expandedProvince == province;

                              return Column(
                                children: [
                                  ProvinceCardWidget(
                                    province: province,
                                    districtCount: districts.length,
                                    isExpanded: isExpanded,
                                    onTap: () =>
                                        _handleProvinceExpand(province),
                                  ),
                                  if (isExpanded)
                                    DistrictListWidget(
                                      districts: districts,
                                      selectedDistrict:
                                          _selectedProvince == province
                                              ? _selectedDistrict
                                              : null,
                                      onDistrictSelect: (district) =>
                                          _handleDistrictSelect(
                                              province, district),
                                    ),
                                  SizedBox(height: 1.h),
                                ],
                              );
                            },
                          ),
                        ),
            ),

            // Save button
            if (_selectedProvince != null && _selectedDistrict != null)
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: _handleSaveLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Konumu Kaydet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 1.h),
          height: 8.h,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: SizedBox(
              width: 80.w,
              height: 2.h,
              child: LinearProgressIndicator(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            SizedBox(height: 2.h),
            Text(
              'Şehir Bulunamadı',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Farklı bir arama terimi deneyin',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
