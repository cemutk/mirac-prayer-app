import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Dropdown selector for preset dhikr options with custom input
class DhikrSelectorWidget extends StatefulWidget {
  final List<Map<String, String>> presets;
  final String selectedDhikr;
  final bool isCustom;
  final String customText;
  final Function(String dhikr, bool isCustom, String customText)
      onDhikrSelected;

  const DhikrSelectorWidget({
    super.key,
    required this.presets,
    required this.selectedDhikr,
    required this.isCustom,
    required this.customText,
    required this.onDhikrSelected,
  });

  @override
  State<DhikrSelectorWidget> createState() => _DhikrSelectorWidgetState();
}

class _DhikrSelectorWidgetState extends State<DhikrSelectorWidget> {
  late TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    _customController = TextEditingController(text: widget.customText);
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _showDhikrPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 2.h),
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 2.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Zikir Seçin',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.presets.length + 1,
                itemBuilder: (context, index) {
                  if (index < widget.presets.length) {
                    final preset = widget.presets[index];
                    final isSelected = !widget.isCustom &&
                        widget.selectedDhikr == preset['name'];

                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      leading: CustomIconWidget(
                        iconName: isSelected
                            ? 'check_circle'
                            : 'radio_button_unchecked',
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                      title: Text(
                        preset['arabic'] ?? '',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 18.sp,
                                ),
                      ),
                      subtitle: Text(
                        preset['transliteration'] ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () {
                        widget.onDhikrSelected(preset['name'] ?? '', false, '');
                        Navigator.pop(context);
                      },
                    );
                  } else {
                    return ListTile(
                      selected: widget.isCustom,
                      selectedTileColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      leading: CustomIconWidget(
                        iconName: widget.isCustom
                            ? 'check_circle'
                            : 'radio_button_unchecked',
                        color: widget.isCustom
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                      title: Text(
                        'Özel Zikir',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        'Kendi zikirini gir',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showCustomDhikrDialog();
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showCustomDhikrDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text('Özel Zikir', style: Theme.of(context).textTheme.titleLarge),
        content: TextField(
          controller: _customController,
          decoration: const InputDecoration(
            hintText: 'Zikirini gir',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_customController.text.trim().isNotEmpty) {
                widget.onDhikrSelected(
                    'Custom', true, _customController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentDhikr = widget.isCustom
        ? widget.customText
        : widget.presets.firstWhere(
            (p) => p['name'] == widget.selectedDhikr,
            orElse: () => widget.presets[0],
          );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: InkWell(
        onTap: _showDhikrPicker,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seçilen Zikir',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    widget.isCustom
                        ? Text(
                            widget.customText,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (currentDhikr
                                        as Map<String, String>)['arabic'] ??
                                    '',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: 18.sp,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                (currentDhikr)['transliteration'] ?? '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              CustomIconWidget(
                iconName: 'arrow_drop_down',
                size: 24,
                color: theme.colorScheme.onSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
