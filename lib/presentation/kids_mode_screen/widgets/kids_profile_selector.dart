import 'package:flutter/material.dart';
import '../../../services/kids_mode_service.dart';

class KidsProfileSelector extends StatelessWidget {
  final List<KidsProfile> profiles;
  final KidsProfile? activeProfile;
  final Function(String) onProfileSelect;
  final VoidCallback onAddProfile;

  const KidsProfileSelector({
    super.key,
    required this.profiles,
    required this.activeProfile,
    required this.onProfileSelect,
    required this.onAddProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Profiller
          ...profiles.map((profile) {
            final isActive = profile.id == activeProfile?.id;
            return GestureDetector(
              onTap: () => onProfileSelect(profile.id),
              child: Container(
                width: 70,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? Colors.orange : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive ? Colors.orange : Colors.grey.shade300,
                    width: 2,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      profile.avatarEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : Colors.grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
          // Yeni profil ekle butonu
          GestureDetector(
            onTap: onAddProfile,
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.grey[600], size: 28),
                  Text(
                    'Ekle',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
