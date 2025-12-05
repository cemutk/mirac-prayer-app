import 'package:flutter/material.dart';
import '../../../data/mosque_data.dart';
import '../../../theme/app_theme.dart';

class MosqueFilterWidget extends StatefulWidget {
  final MosqueFilter currentFilter;
  final Function(MosqueFilter) onApply;
  final VoidCallback onClear;

  const MosqueFilterWidget({
    super.key,
    required this.currentFilter,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<MosqueFilterWidget> createState() => _MosqueFilterWidgetState();
}

class _MosqueFilterWidgetState extends State<MosqueFilterWidget> {
  late List<MosqueAmenity> _selectedAmenities;
  late double? _maxDistance;
  late double? _minRating;
  late bool _onlyVerified;

  @override
  void initState() {
    super.initState();
    _selectedAmenities = List.from(widget.currentFilter.requiredAmenities);
    _maxDistance = widget.currentFilter.maxDistance;
    _minRating = widget.currentFilter.minRating;
    _onlyVerified = widget.currentFilter.onlyVerified;
  }

  void _toggleAmenity(MosqueAmenity amenity) {
    setState(() {
      if (_selectedAmenities.contains(amenity)) {
        _selectedAmenities.remove(amenity);
      } else {
        _selectedAmenities.add(amenity);
      }
    });
  }

  void _applyFilter() {
    final filter = MosqueFilter(
      requiredAmenities: _selectedAmenities,
      maxDistance: _maxDistance,
      minRating: _minRating,
      onlyVerified: _onlyVerified,
    );
    widget.onApply(filter);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildDistanceFilter(),
                    const SizedBox(height: 20),
                    _buildRatingFilter(),
                    const SizedBox(height: 20),
                    _buildVerifiedFilter(),
                    const SizedBox(height: 20),
                    _buildAmenitiesSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              _buildBottomButtons(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtrele',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedAmenities.clear();
                    _maxDistance = null;
                    _minRating = null;
                    _onlyVerified = false;
                  });
                },
                child: const Text('Temizle'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.straighten, color: AppTheme.primaryDark),
            SizedBox(width: 8),
            Text(
              'Maksimum Mesafe',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [null, 1.0, 2.0, 5.0, 10.0, 20.0].map((distance) {
            final isSelected = _maxDistance == distance;
            return FilterChip(
              label: Text(distance == null ? 'Hepsi' : '${distance.toInt()} km'),
              selected: isSelected,
              onSelected: (_) => setState(() => _maxDistance = distance),
              selectedColor: AppTheme.primaryDark.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryDark,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.star, color: Colors.amber),
            SizedBox(width: 8),
            Text(
              'Minimum Puan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [null, 3.0, 3.5, 4.0, 4.5].map((rating) {
            final isSelected = _minRating == rating;
            final label = rating == null ? 'Hepsi' : '${rating.toString()} ⭐';
            return FilterChip(
              label: Text(label, style: const TextStyle(fontSize: 13)),
              selected: isSelected,
              onSelected: (_) => setState(() => _minRating = rating),
              selectedColor: Colors.amber.withValues(alpha: 0.2),
              checkmarkColor: Colors.amber.shade700,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVerifiedFilter() {
    return SwitchListTile(
      title: Row(
        children: [
          const Icon(Icons.verified, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Sadece Doğrulanmış Camiler',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      value: _onlyVerified,
      onChanged: (value) => setState(() => _onlyVerified = value),
      activeColor: AppTheme.primaryDark,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildAmenitiesSection() {
    // Grup halinde imkanları göster
    final groups = {
      'Temel İhtiyaçlar': [
        MosqueAmenity.cleanToilet,
        MosqueAmenity.hotWater,
        MosqueAmenity.wuduArea,
      ],
      'Erişim': [
        MosqueAmenity.disabledAccess,
        MosqueAmenity.parking,
      ],
      'Kadın & Aile': [
        MosqueAmenity.womensSection,
        MosqueAmenity.childrenArea,
      ],
      'Konfor': [
        MosqueAmenity.airConditioning,
        MosqueAmenity.heating,
        MosqueAmenity.freeWifi,
      ],
      'Diğer İmkanlar': [
        MosqueAmenity.library,
        MosqueAmenity.conferenceHall,
        MosqueAmenity.shoeStorage,
        MosqueAmenity.prayerRug,
        MosqueAmenity.quranAvailable,
        MosqueAmenity.fridayPrayer,
        MosqueAmenity.religiousCourses,
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.primaryDark),
            SizedBox(width: 8),
            Text(
              'İmkanlar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedAmenities.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${_selectedAmenities.length} imkan seçildi',
              style: TextStyle(
                color: AppTheme.primaryDark.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ...groups.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.value.map((amenity) {
                  final isSelected = _selectedAmenities.contains(amenity);
                  return FilterChip(
                    label: Text(
                      '${amenity.icon} ${amenity.displayName}',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    selected: isSelected,
                    onSelected: (_) => _toggleAmenity(amenity),
                    selectedColor: AppTheme.primaryDark.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.primaryDark,
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildBottomButtons() {
    final hasFilters = _selectedAmenities.isNotEmpty ||
        _maxDistance != null ||
        _minRating != null ||
        _onlyVerified;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (hasFilters)
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onClear,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryDark,
                    side: const BorderSide(color: AppTheme.primaryDark),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Temizle'),
                ),
              ),
            if (hasFilters) const SizedBox(width: 12),
            Expanded(
              flex: hasFilters ? 2 : 1,
              child: ElevatedButton(
                onPressed: _applyFilter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  hasFilters ? 'Filtrele (${_selectedAmenities.length})' : 'Kapat',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
