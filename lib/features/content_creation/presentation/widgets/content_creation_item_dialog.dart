import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/fancy_confirm_dialog.dart';
import '../../../../core/widgets/fancy_dialog.dart';
import '../../../auth/data/model/profile_model.dart';
import '../../../clients/data/model/client_model.dart';
import '../../../kanban/data/model/board_column_model.dart';
import '../../../workspace/presentation/cubits/workspace_cubit.dart';
import '../../data/model/content_creation_item_model.dart';
import '../../data/repo/content_creation_items_repository.dart';

/// Handles both create (item == null) and edit. Opened with
/// useRootNavigator: false since it reads WorkspaceCubit, which is scoped
/// to the shell's nested navigator, not the root one.
Future<void> showContentCreationItemDialog(
  BuildContext context, {
  ContentCreationItemModel? item,
  required String defaultStatus,
  required List<ClientModel> clients,
  required List<ProfileModel> profiles,
  required List<BoardColumnModel> columns,
}) {
  return showDialog(
    context: context,
    useRootNavigator: false,
    builder: (_) => _ContentCreationItemDialog(
      item: item,
      defaultStatus: defaultStatus,
      clients: clients,
      profiles: profiles,
      columns: columns,
    ),
  );
}

class _ContentCreationItemDialog extends StatefulWidget {
  const _ContentCreationItemDialog({
    required this.item,
    required this.defaultStatus,
    required this.clients,
    required this.profiles,
    required this.columns,
  });

  final ContentCreationItemModel? item;
  final String defaultStatus;
  final List<ClientModel> clients;
  final List<ProfileModel> profiles;
  final List<BoardColumnModel> columns;

  @override
  State<_ContentCreationItemDialog> createState() =>
      _ContentCreationItemDialogState();
}

class _ContentCreationItemDialogState extends State<_ContentCreationItemDialog> {
  static const _accent1 = Color(0xFF6D28D9);
  static const _accent2 = Color(0xFFDB2777);

  late final _nameController =
      TextEditingController(text: widget.item?.name ?? '');
  late final _descriptionController =
      TextEditingController(text: widget.item?.description ?? '');
  late final _scriptController =
      TextEditingController(text: widget.item?.script ?? '');
  late final _copyController = TextEditingController(text: widget.item?.copy ?? '');
  late final _driveUrlController =
      TextEditingController(text: widget.item?.driveUrl ?? '');
  late String _status = widget.item?.status ?? widget.defaultStatus;
  late String? _clientId = widget.item?.clientId;
  late String? _assigneeId = widget.item?.assigneeId;
  late DateTime? _deadline = widget.item?.deadline;
  late DateTime? _shouldBePublishedOn = widget.item?.shouldBePublishedOn;
  bool _saving = false;

  bool get _isEditing => widget.item != null;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _scriptController.dispose();
    _copyController.dispose();
    _driveUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FancyDialog(
      title: _isEditing ? 'Edit content' : 'New content',
      icon: LucideIcons.clapperboard,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_accent1, _accent2],
      ),
      width: 480,
      maxHeight: 720,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            style: AppTextStyles.h3,
            decoration: fancyFieldDecoration('Name', color: _accent1),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _descriptionController,
            minLines: 2,
            maxLines: 4,
            decoration: fancyFieldDecoration('Description (idea)', color: _accent1),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: widget.columns.any((c) => c.status == _status) ? _status : null,
            decoration: fancyFieldDecoration('Status', color: _accent2),
            items: widget.columns
                .map((c) => DropdownMenuItem(value: c.status, child: Text(c.title)))
                .toList(),
            onChanged: (v) => setState(() => _status = v ?? _status),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _scriptController,
            minLines: 2,
            maxLines: 6,
            decoration: fancyFieldDecoration('Script', color: _accent1),
          ),
          const SizedBox(height: 14),
          _DateTimeTile(
            label: 'Deadline',
            value: _deadline,
            color: AppColors.warning,
            onTap: () => _pickDateTime(
                initial: _deadline, onPicked: (v) => setState(() => _deadline = v)),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _copyController,
            minLines: 2,
            maxLines: 4,
            decoration: fancyFieldDecoration('Copy', color: _accent2),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _driveUrlController,
            decoration: fancyFieldDecoration('Drive URL', color: AppColors.info),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _clientId,
            decoration: fancyFieldDecoration('Client', color: AppColors.success),
            items: widget.clients
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (v) => setState(() => _clientId = v),
          ),
          const SizedBox(height: 14),
          _DateTimeTile(
            label: 'Should be published on',
            value: _shouldBePublishedOn,
            color: AppColors.success,
            onTap: () => _pickDateTime(
                initial: _shouldBePublishedOn,
                onPicked: (v) => setState(() => _shouldBePublishedOn = v)),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _assigneeId,
            decoration: fancyFieldDecoration('Assignee', color: _accent1),
            items: widget.profiles
                .map((p) => DropdownMenuItem(value: p.id, child: Text(p.displayName)))
                .toList(),
            onChanged: (v) => setState(() => _assigneeId = v),
          ),
        ],
      ),
      actions: [
        if (_isEditing)
          FancyTextButton(
            label: 'Delete',
            color: AppColors.danger,
            onPressed: _saving ? null : _delete,
          ),
        if (_isEditing)
          FancyTextButton(
            label: 'Duplicate',
            color: _accent1,
            onPressed: _saving ? null : _duplicate,
          ),
        FancyTextButton(
          label: 'Cancel',
          onPressed: _saving ? null : () => Navigator.pop(context),
        ),
        FancyFilledButton(
          label: 'Save',
          icon: LucideIcons.check,
          color: _accent1,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }

  Future<void> _pickDateTime({
    required DateTime? initial,
    required void Function(DateTime) onPicked,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? DateTime.now()),
    );
    if (time == null) return;
    onPicked(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppToast.error(context, 'Name is required.');
      return;
    }
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final repo = context.read<ContentCreationItemsRepository>();
    try {
      if (_isEditing) {
        await repo.updateItem(widget.item!.id, {
          'name': name,
          'description': _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          'status': _status,
          'script':
              _scriptController.text.trim().isEmpty ? null : _scriptController.text.trim(),
          'deadline': _deadline?.toIso8601String(),
          'copy': _copyController.text.trim().isEmpty ? null : _copyController.text.trim(),
          'drive_url': _driveUrlController.text.trim().isEmpty
              ? null
              : _driveUrlController.text.trim(),
          'client_id': _clientId,
          'should_be_published_on': _shouldBePublishedOn?.toIso8601String(),
          'assignee_id': _assigneeId,
        });
      } else {
        await repo.createItem(ContentCreationItemModel(
          id: '',
          name: name,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          status: _status,
          script:
              _scriptController.text.trim().isEmpty ? null : _scriptController.text.trim(),
          deadline: _deadline,
          copy: _copyController.text.trim().isEmpty ? null : _copyController.text.trim(),
          driveUrl: _driveUrlController.text.trim().isEmpty
              ? null
              : _driveUrlController.text.trim(),
          clientId: _clientId,
          shouldBePublishedOn: _shouldBePublishedOn,
          assigneeId: _assigneeId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
      if (mounted) await context.read<WorkspaceCubit>().load();
      navigator.pop();
      if (mounted) AppToast.success(context, _isEditing ? 'Content updated' : 'Content created');
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        AppToast.error(context, 'Could not save content: $e');
      }
    }
  }

  Future<void> _duplicate() async {
    final item = widget.item;
    if (item == null) return;
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    try {
      await context.read<ContentCreationItemsRepository>().duplicateItem(item.id);
      if (mounted) await context.read<WorkspaceCubit>().load();
      navigator.pop();
      if (mounted) AppToast.success(context, 'Content duplicated');
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        AppToast.error(context, 'Could not duplicate content: $e');
      }
    }
  }

  Future<void> _delete() async {
    final item = widget.item;
    if (item == null) return;
    final confirmed = await showFancyConfirmDialog(
      context,
      title: 'Delete "${item.name}"?',
      message: 'This cannot be undone.',
      useRootNavigator: false,
    );
    if (!confirmed || !mounted) return;
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    try {
      await context.read<ContentCreationItemsRepository>().deleteItem(item.id);
      if (mounted) await context.read<WorkspaceCubit>().load();
      navigator.pop();
      if (mounted) AppToast.success(context, 'Content deleted');
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        AppToast.error(context, 'Could not delete content: $e');
      }
    }
  }
}

class _DateTimeTile extends StatelessWidget {
  const _DateTimeTile({
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.calendarClock, size: 16, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value == null
                      ? '$label: none'
                      : '$label: ${value.toString().substring(0, 16)}',
                  style: AppTextStyles.body,
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
