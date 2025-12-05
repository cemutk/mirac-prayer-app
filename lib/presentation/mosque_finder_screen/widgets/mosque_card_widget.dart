import 'package:flutter/material.dart';
import '../../../data/mosque_data.dart';
import '../../../theme/app_theme.dart';

class MosqueCardWidget extends StatelessWidget {
  final Mosque mosque;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onNavigate;
  final VoidCallback onWalk;

  const MosqueCardWidget({
    super.key,
    required this.mosque,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
    required this.onNavigate,
    required this.onWalk,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildAddress(),
              if (mosque.amenities.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildAmenities(),
              ],
              const SizedBox(height: 12),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.primaryDark.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.mosque,
            color: AppTheme.primaryDark,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mosque.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (mosque.isVerified)
                    Icon(Icons.verified, size: 16, color: Colors.green.shade600),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, size: 14, color: Colors.amber.shade600),
                  const SizedBox(width: 4),
                  Text(
                    mosque.averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' (${mosque.totalRatings})',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (mosque.distanceInKm != null) ...[
                    const Spacer(),
                    Icon(Icons.location_on, size: 14, color: AppTheme.accentGold),
                    const SizedBox(width: 2),
                    Text(
                      '${mosque.distanceInKm!.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: onFavorite,
        ),
      ],
    );
  }

  Widget _buildAddress() {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            mosque.address,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenities() {
    final displayAmenities = mosque.amenities.take(4).toList();
    final remaining = mosque.amenities.length - 4;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...displayAmenities.map((amenity) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryDark.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(amenity.icon, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    amenity.displayName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ],
              ),
            )),
        if (remaining > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+$remaining',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onWalk,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryDark,
              side: BorderSide(color: AppTheme.primaryDark.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.directions_walk, size: 18),
            label: const Text('Yürü', style: TextStyle(fontSize: 12)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onNavigate,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.navigation, size: 18),
            label: const Text('Yol Tarifi', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }
}
