import 'package:flutter/material.dart';
import '../presentation/premium_screen/premium_upgrade_screen.dart';

/// Shows a dialog when user tries to access a premium feature
/// Redirects to purchase screen if user wants to upgrade
void showPremiumDialog(BuildContext context, {String? featureName}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.workspace_premium,
              color: Colors.amber.shade700,
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Premium Özellik',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (featureName != null) ...[
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                children: [
                  TextSpan(
                    text: featureName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text: ' özelliğine erişmek için Premium üyelik gereklidir.',
                  ),
                ],
              ),
            ),
          ] else ...[
            const Text(
              'Bu özelliğe erişmek için Premium üyelik gereklidir.',
              style: TextStyle(fontSize: 16),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Tüm özelliklere erişim')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.block, color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Reklamsız deneyim')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Detaylı istatistikler')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PremiumUpgradeScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Premium\'a Geç'),
        ),
      ],
    ),
  );
}
