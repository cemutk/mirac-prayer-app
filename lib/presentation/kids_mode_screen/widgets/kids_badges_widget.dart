import 'package:flutter/material.dart';
import '../../../services/kids_mode_service.dart';

class KidsBadgesWidget extends StatelessWidget {
  final List<KidsBadge> allBadges;
  final List<String> earnedBadges;

  const KidsBadgesWidget({
    super.key,
    required this.allBadges,
    required this.earnedBadges,
  });

  @override
  Widget build(BuildContext context) {
    // Kazanılan rozetleri önce göster
    final sortedBadges = List<KidsBadge>.from(allBadges)
      ..sort((a, b) {
        final aEarned = earnedBadges.contains(a.id);
        final bEarned = earnedBadges.contains(b.id);
        if (aEarned && !bEarned) return -1;
        if (!aEarned && bEarned) return 1;
        return 0;
      });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kazanılan rozetler özeti
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade400, Colors.orange.shade500],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text(
                  '🏆',
                  style: TextStyle(fontSize: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rozet Koleksiyonum',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${earnedBadges.length} / ${allBadges.length} rozet kazandın!',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(earnedBadges.length / allBadges.length * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Rozet grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: sortedBadges.length,
            itemBuilder: (context, index) {
              final badge = sortedBadges[index];
              final isEarned = earnedBadges.contains(badge.id);
              return _buildBadgeCard(context, badge, isEarned);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(BuildContext context, KidsBadge badge, bool isEarned) {
    return GestureDetector(
      onTap: () => _showBadgeDetail(context, badge, isEarned),
      child: Container(
        decoration: BoxDecoration(
          color: isEarned ? badge.color.withValues(alpha: 0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEarned ? badge.color : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isEarned
              ? [
                  BoxShadow(
                    color: badge.color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isEarned
                    ? badge.color.withValues(alpha: 0.2)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: isEarned
                    ? Text(
                        badge.emoji,
                        style: const TextStyle(fontSize: 32),
                      )
                    : const Icon(
                        Icons.lock,
                        color: Colors.grey,
                        size: 28,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            // İsim
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                badge.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isEarned ? badge.color : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context, KidsBadge badge, bool isEarned) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji büyük
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isEarned
                    ? badge.color.withValues(alpha: 0.1)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: isEarned
                    ? Text(
                        badge.emoji,
                        style: const TextStyle(fontSize: 50),
                      )
                    : const Icon(
                        Icons.lock,
                        color: Colors.grey,
                        size: 50,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            // İsim
            Text(
              badge.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isEarned ? badge.color : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            // Açıklama
            Text(
              badge.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Durum
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isEarned ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isEarned ? Icons.check_circle : Icons.lock,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEarned ? 'Kazanıldı!' : 'Kilitli',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (!isEarned && badge.requiredPoints > 0) ...[
              const SizedBox(height: 12),
              Text(
                '${badge.requiredPoints} puana ulaşınca açılır',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
