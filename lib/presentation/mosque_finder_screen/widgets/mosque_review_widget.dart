import 'package:flutter/material.dart';
import '../../../data/mosque_data.dart';
import '../../../theme/app_theme.dart';

class MosqueReviewWidget extends StatelessWidget {
  final MosqueReview review;

  const MosqueReviewWidget({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!,
              style: const TextStyle(fontSize: 14),
            ),
          ],
          if (review.confirmedAmenities.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildConfirmedAmenities(),
          ],
          const SizedBox(height: 8),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppTheme.primaryDark.withValues(alpha: 0.1),
          child: Text(
            review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?',
            style: const TextStyle(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    review.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (review.isVerified) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.verified, size: 14, color: Colors.green.shade600),
                  ],
                ],
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    size: 14,
                    color: Colors.amber.shade600,
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmedAmenities() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        const Text(
          'Onayladığı imkanlar:',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        ...review.confirmedAmenities.map((amenity) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, size: 12, color: Colors.green.shade700),
                const SizedBox(width: 4),
                Text(
                  amenity.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFooter() {
    final timeAgo = _getTimeAgo(review.createdAt);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          timeAgo,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        Row(
          children: [
            Icon(Icons.thumb_up_outlined, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              '${review.helpfulCount}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()} yıl önce';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} ay önce';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} gün önce';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} saat önce';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
}
