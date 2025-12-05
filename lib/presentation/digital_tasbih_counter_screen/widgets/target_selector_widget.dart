import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Target count selector with preset options and custom input
class TargetSelectorWidget extends StatelessWidget {
  final List<int> targetOptions;
  final int selectedTarget;
  final Function(int) onTargetSelected;

  const TargetSelectorWidget({
    super.key,
    required this.targetOptions,
    required this.selectedTarget,
    required this.onTargetSelected,
  });

  void _showCustomTargetDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text('Özel Hedef', style: Theme.of(context).textTheme.titleLarge),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Hedef sayı gir',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0 && value <= 9999) {
                onTargetSelected(value);
                Navigator.pop(context);
              }
            },
            child: const Text('Ayarla'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hedef Sayı',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: [
              ...targetOptions.map((target) => _buildTargetChip(
                    context,
                    target.toString(),
                    target == selectedTarget,
                    () => onTargetSelected(target),
                  )),
              _buildTargetChip(
                context,
                'Özel',
                !targetOptions.contains(selectedTarget),
                () => _showCustomTargetDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
