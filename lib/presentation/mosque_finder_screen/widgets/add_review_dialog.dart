import 'package:flutter/material.dart';
import '../../../data/mosque_data.dart';
import '../../../theme/app_theme.dart';

class AddReviewDialog extends StatefulWidget {
  final String mosqueId;

  const AddReviewDialog({
    super.key,
    required this.mosqueId,
  });

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  double _rating = 5;
  final List<MosqueAmenity> _confirmedAmenities = [];

  void _toggleAmenity(MosqueAmenity amenity) {
    setState(() {
      if (_confirmedAmenities.contains(amenity)) {
        _confirmedAmenities.remove(amenity);
      } else {
        _confirmedAmenities.add(amenity);
      }
    });
  }

  void _submitReview() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen adınızı girin')),
      );
      return;
    }

    final review = MosqueReview(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mosqueId: widget.mosqueId,
      userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
      userName: _nameController.text.trim(),
      rating: _rating,
      comment: _commentController.text.trim().isNotEmpty
          ? _commentController.text.trim()
          : null,
      confirmedAmenities: _confirmedAmenities,
      createdAt: DateTime.now(),
    );

    Navigator.pop(context, review);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.rate_review, color: AppTheme.primaryDark),
                  SizedBox(width: 8),
                  Text(
                    'Değerlendirme Yap',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Ad alanı
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Adınız',
                  hintText: 'İsminizi girin',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Puan
              const Text(
                'Puanınız',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  return IconButton(
                    onPressed: () => setState(() => _rating = starValue.toDouble()),
                    icon: Icon(
                      starValue <= _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber.shade600,
                      size: 36,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Yorum
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Yorumunuz (opsiyonel)',
                  hintText: 'Deneyiminizi paylaşın...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // İmkan onaylama
              const Text(
                'Hangi imkanları onaylıyorsunuz?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 150,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: MosqueAmenity.values.map((amenity) {
                      final isSelected = _confirmedAmenities.contains(amenity);
                      return FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(amenity.icon, style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              amenity.displayName,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (_) => _toggleAmenity(amenity),
                        selectedColor: Colors.green.shade100,
                        checkmarkColor: Colors.green.shade700,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Butonlar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Gönder'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
