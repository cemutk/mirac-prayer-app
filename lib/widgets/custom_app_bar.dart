import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Custom app bar widget for Islamic prayer app
/// Implements clean and minimal design with Contemporary Islamic Minimalism
/// Provides consistent navigation and actions across screens
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text to display
  final String title;

  /// Optional subtitle text
  final String? subtitle;

  /// Leading widget (typically back button or menu icon)
  final Widget? leading;

  /// Action widgets displayed on the right
  final List<Widget>? actions;

  /// Whether to show back button automatically
  final bool automaticallyImplyLeading;

  /// Whether to center the title
  final bool centerTitle;

  /// Optional custom background color
  final Color? backgroundColor;

  /// Optional custom foreground color
  final Color? foregroundColor;

  /// Elevation of the app bar
  final double elevation;

  /// Optional bottom widget (like TabBar)
  final PreferredSizeWidget? bottom;

  /// Custom height for the app bar
  final double? toolbarHeight;

  /// Whether to show a divider at the bottom
  final bool showDivider;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.bottom,
    this.toolbarHeight,
    this.showDivider = false,
  });

  @override
  Size get preferredSize {
    final double height = toolbarHeight ?? kToolbarHeight;
    final double bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(height + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appBarTheme = theme.appBarTheme;

    final bgColor =
        backgroundColor ?? appBarTheme.backgroundColor ?? colorScheme.surface;

    final fgColor =
        foregroundColor ?? appBarTheme.foregroundColor ?? colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        // If user didn't provide a custom background, show a subtle green gradient
        gradient: backgroundColor == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primaryContainer,
                ],
                stops: const [0.0, 1.0],
              )
            : null,
        color: backgroundColor != null ? bgColor : null,
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              )
            : null,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: elevation,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: AppBar(
        title: _buildTitle(context, fgColor),
        leading: _buildLeading(context, fgColor),
        actions: actions,
        automaticallyImplyLeading: automaticallyImplyLeading,
        centerTitle: centerTitle,
        backgroundColor: Colors.transparent,
        foregroundColor: fgColor,
        elevation: 0,
        toolbarHeight: toolbarHeight,
        bottom: bottom,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme.brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
          statusBarBrightness: theme.brightness,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, Color foregroundColor) {
    if (subtitle != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                  color: foregroundColor,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: foregroundColor.withValues(alpha: 0.7),
                ),
          ),
        ],
      );
    }

    // Show a small logo mark to the left of the title for brand presence
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: centerTitle ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: SvgPicture.asset(
            'assets/images/img_app_logo.svg',
            fit: BoxFit.contain,
            // tint the logo to the foreground color for contrast
              colorFilter: ColorFilter.mode(foregroundColor, BlendMode.srcIn),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                color: foregroundColor,
              ),
        ),
      ],
    );
  }

  Widget? _buildLeading(BuildContext context, Color foregroundColor) {
    if (leading != null) {
      return leading;
    }

    if (automaticallyImplyLeading) {
      final canPop = Navigator.of(context).canPop();
      if (canPop) {
        return IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: foregroundColor,
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        );
      }
    }

    return null;
  }
}

/// Variant of CustomAppBar with search functionality
class CustomSearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// Hint text for search field
  final String hintText;

  /// Callback when search text changes
  final ValueChanged<String>? onSearchChanged;

  /// Callback when search is submitted
  final ValueChanged<String>? onSearchSubmitted;

  /// Optional leading widget
  final Widget? leading;

  /// Action widgets displayed on the right
  final List<Widget>? actions;

  /// Optional custom background color
  final Color? backgroundColor;

  /// Optional custom foreground color
  final Color? foregroundColor;

  /// Whether to autofocus the search field
  final bool autofocus;

  /// Initial search text
  final String? initialText;

  const CustomSearchAppBar({
    super.key,
    this.hintText = 'Search...',
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.autofocus = false,
    this.initialText,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomSearchAppBar> createState() => _CustomSearchAppBarState();
}

class _CustomSearchAppBarState extends State<CustomSearchAppBar> {
  late TextEditingController _searchController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bgColor = widget.backgroundColor ?? colorScheme.surface;
    final fgColor = widget.foregroundColor ?? colorScheme.onSurface;

    return AppBar(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: 0,
      leading: widget.leading,
      title: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        style: theme.textTheme.bodyLarge?.copyWith(color: fgColor),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: fgColor.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: fgColor.withValues(alpha: 0.7),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: fgColor.withValues(alpha: 0.7),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged?.call('');
                    HapticFeedback.lightImpact();
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {});
          widget.onSearchChanged?.call(value);
        },
        onSubmitted: widget.onSearchSubmitted,
        textInputAction: TextInputAction.search,
      ),
      actions: widget.actions,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: theme.brightness,
      ),
    );
  }
}
