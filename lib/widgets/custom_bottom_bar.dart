import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom bottom navigation bar widget for Islamic prayer app
/// Implements thumb-optimized bottom placement with five-tab structure
/// Provides instant access to all core worship functions
class CustomBottomBar extends StatefulWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when navigation item is tapped
  final Function(int) onTap;

  /// Optional custom background color
  final Color? backgroundColor;

  /// Optional custom selected item color
  final Color? selectedItemColor;

  /// Optional custom unselected item color
  final Color? unselectedItemColor;

  /// Whether to show labels
  final bool showLabels;

  /// Elevation of the bottom bar
  final double elevation;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.showLabels = true,
    this.elevation = 8.0,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _scaleAnimations;

  // Navigation items configuration - REFINED to 5 core tabs for clarity and usability
  final List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      icon: Icons.access_time_filled_rounded,
      label: 'Vakitler',
      route: '/home-screen-prayer-times',
    ),
    _NavigationItem(
      icon: Icons.explore_rounded,
      label: 'Kıble',
      route: '/qibla-direction-screen',
    ),
    _NavigationItem(
      icon: Icons.fingerprint_rounded, // More abstract 'tap' icon for tasbih
      label: 'Tesbih',
      route: '/digital-tasbih-counter-screen',
    ),
    _NavigationItem(
      icon: Icons.menu_book_rounded,
      label: 'Kuran',
      route: '/quran-i-kerim-screen',
    ),
    _NavigationItem(
      icon: Icons.settings_rounded,
      label: 'Ayarlar',
      route: '/settings-screen',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Create scale animations for each item
    _scaleAnimations = List.generate(
      _navigationItems.length,
      (index) => Tween<double>(begin: 1.0, end: 0.85).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (index == widget.currentIndex) return;

    // Haptic feedback for tab switching
    HapticFeedback.lightImpact();

    // Trigger scale animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Navigate to the selected route
    Navigator.pushReplacementNamed(context, _navigationItems[index].route);

    // Call the onTap callback
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomNavTheme = theme.bottomNavigationBarTheme;

    final backgroundColor = widget.backgroundColor ??
        bottomNavTheme.backgroundColor ??
        colorScheme.surface;

    final selectedColor = widget.selectedItemColor ??
        bottomNavTheme.selectedItemColor ??
        colorScheme.primary;

    final unselectedColor = widget.unselectedItemColor ??
        bottomNavTheme.unselectedItemColor ??
        colorScheme.onSurface.withValues(alpha: 0.6);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: widget.elevation,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navigationItems.length,
              (index) => _buildNavigationItem(
                context,
                index,
                _navigationItems[index],
                selectedColor,
                unselectedColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    int index,
    _NavigationItem item,
    Color selectedColor,
    Color unselectedColor,
  ) {
    final isSelected = index == widget.currentIndex;
    final theme = Theme.of(context);

    return Expanded(
      child: ScaleTransition(
        scale: _scaleAnimations[index],
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleTap(index),
            borderRadius: BorderRadius.circular(12),
            splashColor: selectedColor.withValues(alpha: 0.1),
            highlightColor: selectedColor.withValues(alpha: 0.05),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with animated transition (reduced padding/size to avoid overflow)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? selectedColor.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      item.icon,
                      size: 20,
                      color: isSelected ? selectedColor : unselectedColor,
                    ),
                  ),

                  // Label with fade animation
                  if (widget.showLabels) ...[
                    const SizedBox(height: 1),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      style: (isSelected
                              ? theme
                                  .bottomNavigationBarTheme.selectedLabelStyle
                              : theme.bottomNavigationBarTheme
                                  .unselectedLabelStyle) ??
                          TextStyle(
                            fontSize: 11,
                            height: 1.0,
                            fontWeight:
                                isSelected ? FontWeight.w500 : FontWeight.w400,
                            color: isSelected ? selectedColor : unselectedColor,
                          ),
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal class to represent navigation items
class _NavigationItem {
  final IconData icon;
  final String label;
  final String route;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
