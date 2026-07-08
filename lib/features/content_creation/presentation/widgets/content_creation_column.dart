import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../kanban/data/model/board_column_model.dart';
import '../../data/model/content_creation_item_model.dart';
import 'content_creation_card.dart';

class ContentCreationColumn extends StatelessWidget {
  const ContentCreationColumn({
    super.key,
    required this.status,
    required this.title,
    required this.color,
    required this.allColumns,
    required this.items,
    required this.onCardTap,
    required this.onDropItem,
    required this.onRenameColumn,
    required this.onAddItem,
    required this.onDeleteColumn,
    this.onDuplicateItem,
    this.onDeleteItem,
  });

  final String status;
  final String title;
  final Color color;
  final List<BoardColumnModel> allColumns;
  final List<ContentCreationItemModel> items;
  final void Function(ContentCreationItemModel) onCardTap;
  final void Function(ContentCreationItemModel item, String newStatus) onDropItem;
  final void Function(String newTitle) onRenameColumn;
  final VoidCallback onAddItem;
  final VoidCallback onDeleteColumn;
  final void Function(ContentCreationItemModel)? onDuplicateItem;
  final void Function(ContentCreationItemModel)? onDeleteItem;

  @override
  Widget build(BuildContext context) {
    return DragTarget<ContentCreationItemModel>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) => onDropItem(details.data, status),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Container(
          width: 300,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: isHovering ? color.withValues(alpha: 0.12) : AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovering ? color : AppColors.border,
              width: isHovering ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.25))),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _EditableTitle(title: title, onSubmit: onRenameColumn),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('${items.length}',
                          style: AppTextStyles.label.copyWith(color: color)),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(LucideIcons.moreVertical, size: 16),
                      tooltip: 'Column options',
                      onSelected: (v) {
                        if (v == 'add') onAddItem();
                        if (v == 'delete') onDeleteColumn();
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'add', child: Text('Add card')),
                        PopupMenuItem(value: 'delete', child: Text('Delete column')),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text('No cards', style: AppTextStyles.caption),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final card = ContentCreationCard(
                            item: item,
                            onTap: () => onCardTap(item),
                            onDuplicate: onDuplicateItem == null
                                ? null
                                : () => onDuplicateItem!(item),
                            onDelete:
                                onDeleteItem == null ? null : () => onDeleteItem!(item),
                          );
                          return Draggable<ContentCreationItemModel>(
                            data: item,
                            feedback: Material(
                              color: Colors.transparent,
                              child: Opacity(opacity: 0.9, child: card),
                            ),
                            childWhenDragging: Opacity(opacity: 0.3, child: card),
                            child: card,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EditableTitle extends StatefulWidget {
  const _EditableTitle({required this.title, required this.onSubmit});
  final String title;
  final void Function(String) onSubmit;

  @override
  State<_EditableTitle> createState() => _EditableTitleState();
}

class _EditableTitleState extends State<_EditableTitle> {
  bool _editing = false;
  late final _controller = TextEditingController(text: widget.title);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commit() {
    setState(() => _editing = false);
    final value = _controller.text.trim();
    if (value.isNotEmpty && value != widget.title) widget.onSubmit(value);
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return TextField(
        controller: _controller,
        autofocus: true,
        style: AppTextStyles.subtitle,
        decoration: const InputDecoration(isDense: true, border: InputBorder.none),
        onSubmitted: (_) => _commit(),
        onTapOutside: (_) => _commit(),
      );
    }
    return GestureDetector(
      onDoubleTap: () => setState(() => _editing = true),
      child: Text(widget.title,
          style: AppTextStyles.subtitle, overflow: TextOverflow.ellipsis),
    );
  }
}
