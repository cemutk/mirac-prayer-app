import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Prayer card widget displaying Arabic text, transliteration, and Turkish translation
/// Supports expandable format with smooth height animation
class PrayerCardWidget extends StatefulWidget {
  final Map<String, dynamic> prayer;
  final bool isFavorite;
  final bool isReadingMode;
  final double textSize;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onLongPress;

  const PrayerCardWidget({
    super.key,
    required this.prayer,
    required this.isFavorite,
    required this.isReadingMode,
    required this.textSize,
    required this.onFavoriteToggle,
    required this.onLongPress,
  });

  @override
  State<PrayerCardWidget> createState() => _PrayerCardWidgetState();
}

class _PrayerCardWidgetState extends State<PrayerCardWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // Use the controller directly for expansion timing; CurvedAnimation not required here

    if (widget.isReadingMode) {
      _isExpanded = true;
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PrayerCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isReadingMode != oldWidget.isReadingMode) {
      if (widget.isReadingMode) {
        _isExpanded = true;
        _animationController.forward();
      } else {
        _isExpanded = false;
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if (widget.isReadingMode) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded
          ? _animationController.forward()
          : _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _toggleExpanded,
      onLongPress: () {
        HapticFeedback.mediumImpact();
        widget.onLongPress();
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 2.h),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and favorite button
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.prayer['title'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.prayer['category'] as String,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: CustomIconWidget(
                      iconName:
                          widget.isFavorite ? 'favorite' : 'favorite_border',
                      color: widget.isFavorite
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    onPressed: widget.onFavoriteToggle,
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Preview or full content
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isExpanded
                    ? _buildFullContent(theme)
                    : _buildPreview(theme),
              ),

              // Expand indicator
              if (!widget.isReadingMode) ...[
                SizedBox(height: 1.h),
                Center(
                  child: AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.6),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(ThemeData theme) {
    return Text(
      widget.prayer['preview'] as String,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: widget.textSize,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFullContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Arabic text (RTL)
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            widget.prayer['arabic'] as String,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: widget.textSize + 4,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.primary,
              height: 1.8,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        SizedBox(height: 2.h),

        // Transliteration
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.prayer['transliteration'] as String,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: widget.textSize,
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ),
        SizedBox(height: 2.h),

        // Turkish translation
        Text(
          widget.prayer['translation'] as String,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: widget.textSize,
            color: theme.colorScheme.onSurface,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
