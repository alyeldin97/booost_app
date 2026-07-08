import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/exceptions/lookup_delete_restricted_exception.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/fancy_confirm_dialog.dart';
import '../../../../core/widgets/fancy_prompt_dialog.dart';

class LookupItem {
  const LookupItem(this.key, this.title);
  final String key;
  final String title;
}

/// Generic rename/create/delete list editor for the dynamic lookup tables
/// (task types, platforms) — mirrors the inline column controls on the
/// Kanban/Content Creation boards, but as a standalone settings section
/// since these lists don't have their own board to host controls on.
class LookupListEditor extends StatefulWidget {
  const LookupListEditor({
    super.key,
    required this.title,
    required this.icon,
    required this.load,
    required this.rename,
    required this.create,
    required this.delete,
    this.color = AppColors.primary,
  });

  final String title;
  final IconData icon;
  final Color color;
  final Future<List<LookupItem>> Function() load;
  final Future<void> Function(String key, String title) rename;
  final Future<void> Function(String title, int nextPosition) create;
  final Future<void> Function(String key) delete;

  @override
  State<LookupListEditor> createState() => _LookupListEditorState();
}

class _LookupListEditorState extends State<LookupListEditor> {
  List<LookupItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final items = await widget.load();
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) AppToast.error(context, 'Could not load ${widget.title}: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.06), AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(widget.icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Text(widget.title, style: AppTextStyles.subtitle),
              const Spacer(),
              TextButton.icon(
                onPressed: _add,
                style: TextButton.styleFrom(foregroundColor: color),
                icon: const Icon(LucideIcons.plus, size: 15),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('None yet.', style: AppTextStyles.caption),
            )
          else
            for (final item in _items)
              _LookupRow(item: item, editor: this, color: color),
        ],
      ),
    );
  }

  Future<void> _add() async {
    final title = await showFancyPromptDialog(
      context,
      title: 'New ${widget.title.toLowerCase()}',
      label: 'Name',
      confirmLabel: 'Create',
      icon: LucideIcons.plus,
      color: widget.color,
    );
    if (title == null || title.trim().isEmpty) return;
    try {
      await widget.create(title.trim(), _items.length);
      await _refresh();
    } catch (e) {
      if (mounted) AppToast.error(context, 'Could not create: $e');
    }
  }

  Future<void> _rename(LookupItem item) async {
    final title = await showFancyPromptDialog(
      context,
      title: 'Rename',
      label: 'Name',
      initialValue: item.title,
      icon: LucideIcons.pencil,
      color: widget.color,
    );
    if (title == null || title.trim().isEmpty || title.trim() == item.title) return;
    try {
      await widget.rename(item.key, title.trim());
      await _refresh();
    } catch (e) {
      if (mounted) AppToast.error(context, 'Could not rename: $e');
    }
  }

  Future<void> _delete(LookupItem item) async {
    final confirmed = await showFancyConfirmDialog(
      context,
      title: 'Delete "${item.title}"?',
      message: 'This cannot be undone.',
    );
    if (!confirmed) return;
    try {
      await widget.delete(item.key);
      await _refresh();
    } on LookupDeleteRestrictedException {
      if (mounted) {
        AppToast.error(context, '"${item.title}" is still in use and can\'t be deleted.');
      }
    } catch (e) {
      if (mounted) AppToast.error(context, 'Could not delete: $e');
    }
  }
}

class _LookupRow extends StatelessWidget {
  const _LookupRow({required this.item, required this.editor, required this.color});
  final LookupItem item;
  final _LookupListEditorState editor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(item.title, style: AppTextStyles.body)),
          IconButton(
            icon: const Icon(LucideIcons.pencil, size: 15),
            tooltip: 'Rename',
            color: color,
            onPressed: () => editor._rename(item),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2, size: 15),
            tooltip: 'Delete',
            color: AppColors.danger,
            onPressed: () => editor._delete(item),
          ),
        ],
      ),
    );
  }
}
