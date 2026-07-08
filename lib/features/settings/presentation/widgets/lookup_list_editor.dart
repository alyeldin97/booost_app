import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/exceptions/lookup_delete_restricted_exception.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';

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
  });

  final String title;
  final IconData icon;
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(widget.title, style: AppTextStyles.subtitle),
              const Spacer(),
              TextButton.icon(
                onPressed: _add,
                icon: const Icon(LucideIcons.plus, size: 15),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
            for (final item in _items) _LookupRow(item: item, editor: this),
        ],
      ),
    );
  }

  Future<void> _add() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('New ${widget.title.toLowerCase()}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Name'),
          onSubmitted: (v) => Navigator.pop(dialogContext, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
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
    final controller = TextEditingController(text: item.title);
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(dialogContext, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete "${item.title}"?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
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
  const _LookupRow({required this.item, required this.editor});
  final LookupItem item;
  final _LookupListEditorState editor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(item.title, style: AppTextStyles.body)),
          IconButton(
            icon: const Icon(LucideIcons.pencil, size: 15),
            tooltip: 'Rename',
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
