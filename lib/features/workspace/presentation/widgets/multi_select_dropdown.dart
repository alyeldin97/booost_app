import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';

class MultiSelectOption<T> {
  const MultiSelectOption(this.value, this.label, {this.color});
  final T value;
  final String label;
  final Color? color;
}

/// Compact toolbar multi-select: a chip button that opens a checklist
/// overlay. Generic over T so the same widget drives client/assignee/
/// status/priority/task-type/platform filters.
class MultiSelectDropdown<T> extends StatelessWidget {
  const MultiSelectDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final String label;
  final IconData icon;
  final List<MultiSelectOption<T>> options;
  final Set<T> selected;
  final void Function(T value) onToggle;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selected.isNotEmpty;
    return MenuAnchor(
      builder: (context, controller, child) {
        return OutlinedButton.icon(
          onPressed: () {
            controller.isOpen ? controller.close() : controller.open();
          },
          icon: Icon(icon, size: 15),
          label: Text(
            hasSelection ? '$label (${selected.length})' : label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: hasSelection ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: hasSelection ? AppColors.primary : AppColors.border,
            ),
            backgroundColor: hasSelection ? AppColors.primaryLight : null,
            foregroundColor: hasSelection ? AppColors.primary : AppColors.textPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        );
      },
      menuChildren: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320, minWidth: 220),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((option) {
                final isSelected = selected.contains(option.value);
                return InkWell(
                  onTap: () => onToggle(option.value),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? LucideIcons.squareCheck : LucideIcons.square,
                          size: 16,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 8),
                        if (option.color != null) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: option.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(option.label, style: AppTextStyles.body),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
