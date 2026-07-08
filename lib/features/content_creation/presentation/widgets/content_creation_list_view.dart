import 'package:flutter/material.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../data/model/content_creation_item_model.dart';
import 'content_creation_card.dart';

class ContentCreationListView extends StatelessWidget {
  const ContentCreationListView({super.key, required this.items, required this.onItemTap});

  final List<ContentCreationItemModel> items;
  final void Function(ContentCreationItemModel) onItemTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text('No content scheduled.', style: AppTextStyles.caption),
      );
    }
    final sorted = [...items]
      ..sort((a, b) => a.shouldBePublishedOn!.compareTo(b.shouldBePublishedOn!));
    final grouped = <DateTime, List<ContentCreationItemModel>>{};
    for (final item in sorted) {
      final d = item.shouldBePublishedOn!;
      final day = DateTime(d.year, d.month, d.day);
      grouped.putIfAbsent(day, () => []).add(item);
    }

    return ListView(
      children: [
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              DateFormatters.dueDate(entry.key),
              style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
            ),
          ),
          for (final item in entry.value)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ContentCreationCard(
                item: item,
                onTap: () => onItemTap(item),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
