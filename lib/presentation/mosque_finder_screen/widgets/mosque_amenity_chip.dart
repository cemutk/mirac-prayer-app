import 'package:flutter/material.dart';
import '../../../data/mosque_data.dart';
import '../../../theme/app_theme.dart';

class MosqueAmenityChip extends StatelessWidget {
  final MosqueAmenity amenity;
  final bool showIcon;
  final bool compact;

  const MosqueAmenityChip({
    super.key,
    required this.amenity,
    this.showIcon = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(compact ? 8 : 10),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Text(
              amenity.icon,
              style: TextStyle(fontSize: compact ? 12 : 14),
            ),
            SizedBox(width: compact ? 4 : 6),
          ],
          Text(
            amenity.displayName,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w500,
              color: _getTextColor(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (amenity) {
      case MosqueAmenity.womensSection:
      case MosqueAmenity.childrenArea:
        return Colors.pink.shade50;
      case MosqueAmenity.hotWater:
      case MosqueAmenity.heating:
        return Colors.orange.shade50;
      case MosqueAmenity.cleanToilet:
      case MosqueAmenity.wuduArea:
        return Colors.blue.shade50;
      case MosqueAmenity.disabledAccess:
        return Colors.purple.shade50;
      case MosqueAmenity.parking:
        return Colors.indigo.shade50;
      case MosqueAmenity.airConditioning:
        return Colors.cyan.shade50;
      case MosqueAmenity.freeWifi:
        return Colors.teal.shade50;
      default:
        return AppTheme.primaryDark.withValues(alpha: 0.08);
    }
  }

  Color _getBorderColor() {
    switch (amenity) {
      case MosqueAmenity.womensSection:
      case MosqueAmenity.childrenArea:
        return Colors.pink.shade200;
      case MosqueAmenity.hotWater:
      case MosqueAmenity.heating:
        return Colors.orange.shade200;
      case MosqueAmenity.cleanToilet:
      case MosqueAmenity.wuduArea:
        return Colors.blue.shade200;
      case MosqueAmenity.disabledAccess:
        return Colors.purple.shade200;
      case MosqueAmenity.parking:
        return Colors.indigo.shade200;
      case MosqueAmenity.airConditioning:
        return Colors.cyan.shade200;
      case MosqueAmenity.freeWifi:
        return Colors.teal.shade200;
      default:
        return AppTheme.primaryDark.withValues(alpha: 0.2);
    }
  }

  Color _getTextColor() {
    switch (amenity) {
      case MosqueAmenity.womensSection:
      case MosqueAmenity.childrenArea:
        return Colors.pink.shade700;
      case MosqueAmenity.hotWater:
      case MosqueAmenity.heating:
        return Colors.orange.shade700;
      case MosqueAmenity.cleanToilet:
      case MosqueAmenity.wuduArea:
        return Colors.blue.shade700;
      case MosqueAmenity.disabledAccess:
        return Colors.purple.shade700;
      case MosqueAmenity.parking:
        return Colors.indigo.shade700;
      case MosqueAmenity.airConditioning:
        return Colors.cyan.shade700;
      case MosqueAmenity.freeWifi:
        return Colors.teal.shade700;
      default:
        return AppTheme.primaryDark;
    }
  }
}
