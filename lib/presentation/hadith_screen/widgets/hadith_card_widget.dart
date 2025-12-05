import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../data/hadith_data.dart';

/// Widget for displaying a single hadith card
class HadithCardWidget extends StatelessWidget {
  final Hadith hadith;
  final bool isExpanded;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onShareTap;

  const HadithCardWidget({
    super.key,
    required this.hadith,
    required this.isExpanded,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
    required this.onShareTap,
  });

  Color _getCategoryColor() {
    switch (hadith.category) {
      case 'İman':
        return Colors.blue;
      case 'Namaz':
        return Colors.green;
      case 'Ahlak':
        return Colors.purple;
      case 'İlim':
        return Colors.orange;
      case 'Aile':
        return Colors.pink;
      case 'Ticaret':
        return Colors.teal;
      case 'Sabır':
        return Colors.indigo;
      case 'Dua':
        return Colors.amber;
      case 'Zikir':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _getCategoryColor();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded
                ? categoryColor.withValues(alpha: 0.5)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isExpanded ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with category badge
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and Actions Row
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hadith.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: categoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Favorite button
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          size: 22,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onFavoriteTap();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      SizedBox(width: 2.w),
                      // Share button
                      IconButton(
                        icon: Icon(
                          Icons.share_outlined,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          size: 20,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onShareTap();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  
                  // Arabic Text
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hadith.arabic,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        height: 2,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  
                  // Turkish Translation
                  Text(
                    hadith.turkish,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Expanded Content - Source and Narrator
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      icon: Icons.person_outline,
                      label: 'Ravi',
                      value: hadith.narrator,
                      color: categoryColor,
                    ),
                    SizedBox(height: 1.h),
                    _buildInfoRow(
                      context,
                      icon: Icons.book_outlined,
                      label: 'Kaynak',
                      value: hadith.source,
                      color: categoryColor,
                    ),
                  ],
                ),
              ),
            ),
            
            // Expand indicator
            Container(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Center(
                child: Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        SizedBox(width: 2.w),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
