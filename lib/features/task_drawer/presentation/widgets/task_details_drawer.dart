import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../../core/utils/app_enums.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/fancy_confirm_dialog.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../kanban/data/model/board_column_model.dart';
import '../../../tasks/data/model/task_type_model.dart';
import '../../../workspace/presentation/cubits/workspace_cubit.dart';
import '../cubits/task_drawer_cubit.dart';

class TaskDetailsDrawer extends StatelessWidget {
  const TaskDetailsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 440,
      child: BlocConsumer<TaskDrawerCubit, TaskDrawerCubitState>(
        listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            AppToast.error(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          if (state.isLoading || state.task == null) {
            return const SafeArea(child: LoadingIndicator());
          }
          return _DrawerBody(state: state);
        },
      ),
    );
  }
}

class _DrawerBody extends StatefulWidget {
  const _DrawerBody({required this.state});
  final TaskDrawerCubitState state;

  @override
  State<_DrawerBody> createState() => _DrawerBodyState();
}

class _DrawerBodyState extends State<_DrawerBody> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final _checklistController = TextEditingController();
  final _labelController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.state.task!.title);
    _descriptionController =
        TextEditingController(text: widget.state.task!.description ?? '');
  }

  @override
  void didUpdateWidget(covariant _DrawerBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.task?.id != widget.state.task?.id) {
      _titleController.text = widget.state.task!.title;
      _descriptionController.text = widget.state.task!.description ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _checklistController.dispose();
    _labelController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.state.task!;
    final cubit = context.read<TaskDrawerCubit>();
    final workspace = context.watch<WorkspaceCubit>().state;
    final linkedContent = workspace.contentItems
        .firstWhereOrNull((c) => c.id == task.linkedContentItemId);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    style: AppTextStyles.h3,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Task title',
                      isDense: true,
                    ),
                    onSubmitted: cubit.updateTitle,
                    onEditingComplete: () => cubit.updateTitle(_titleController.text),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    cubit.updateTitle(_titleController.text.trim().isEmpty
                        ? task.title
                        : _titleController.text.trim());
                    cubit.updateDescription(_descriptionController.text);
                    AppToast.success(context, 'Task saved');
                    cubit.closeDrawer();
                  },
                  icon: const Icon(LucideIcons.check, size: 16),
                  label: const Text('Save'),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 18),
                  tooltip: 'Delete task',
                  onPressed: () => _confirmDelete(context, cubit),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: cubit.closeDrawer,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('Client'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: task.clientId,
                    isExpanded: true,
                    decoration: _fieldDecoration(),
                    items: workspace.clients
                        .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (id) {
                      if (id != null) cubit.updateClient(id);
                    },
                  ),
                  const SizedBox(height: 16),
                  _SectionLabel('Description'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    style: AppTextStyles.body,
                    decoration: _fieldDecoration(hint: 'Add a description...'),
                    onEditingComplete: () =>
                        cubit.updateDescription(_descriptionController.text),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatusDropdown(
                          value: task.status,
                          columns: workspace.boardColumns,
                          onChanged: cubit.updateStatus,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PriorityDropdown(
                          value: task.priority,
                          onChanged: cubit.updatePriority,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _TaskTypeDropdown(
                          value: task.taskType,
                          types: workspace.taskTypes,
                          onChanged: cubit.updateTaskType,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DueDateField(
                          value: task.dueDate,
                          onChanged: cubit.updateDueDate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('Assigned team members'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: workspace.profiles.map((p) {
                      final isAssigned = task.assignees.any((a) => a.id == p.id);
                      return FilterChip(
                        label: Text(p.displayName),
                        selected: isAssigned,
                        onSelected: (_) => cubit.toggleAssignee(p.id),
                        selectedColor: AppColors.primaryLight,
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('Platforms'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: workspace.platforms.map((p) {
                      final selected = task.platforms.contains(p.platform);
                      final (icon, color) = platformStyle(p.platform);
                      return FilterChip(
                        avatar: Icon(icon, size: 14, color: selected ? color : AppColors.textMuted),
                        label: Text(p.title),
                        selected: selected,
                        onSelected: (_) => cubit.togglePlatform(p.platform),
                        selectedColor: color.withValues(alpha: 0.14),
                        checkmarkColor: color,
                        side: BorderSide(
                          color: selected ? color.withValues(alpha: 0.5) : AppColors.border,
                        ),
                        labelStyle: TextStyle(
                          color: selected ? color : AppColors.textPrimary,
                          fontWeight: selected ? FontWeight.w600 : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('Labels'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final label in task.labels)
                        Chip(label: Text(label)),
                      SizedBox(
                        width: 140,
                        child: TextField(
                          controller: _labelController,
                          decoration: _fieldDecoration(hint: 'Add label...'),
                          onSubmitted: (v) {
                            if (v.trim().isNotEmpty) {
                              cubit.addLabel(v.trim());
                              _labelController.clear();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('Checklist'),
                  const SizedBox(height: 8),
                  for (final item in task.checklistItems)
                    Row(
                      children: [
                        Checkbox(
                          value: item.isCompleted,
                          onChanged: (v) =>
                              cubit.toggleChecklistItem(item.id, v ?? false),
                        ),
                        Expanded(
                          child: Text(
                            item.title,
                            style: item.isCompleted
                                ? AppTextStyles.body.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: AppColors.textMuted)
                                : AppTextStyles.body,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.x, size: 14),
                          onPressed: () => cubit.deleteChecklistItem(item.id),
                        ),
                      ],
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _checklistController,
                          decoration: _fieldDecoration(hint: 'Add checklist item...'),
                          onSubmitted: (v) {
                            if (v.trim().isNotEmpty) {
                              cubit.addChecklistItem(v.trim());
                              _checklistController.clear();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('Attachments'),
                  const SizedBox(height: 8),
                  for (final a in task.attachments)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(LucideIcons.paperclip, size: 16),
                      title: Text(a.fileName, style: AppTextStyles.body),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.download, size: 16),
                            onPressed: () async {
                              final url = await cubit.signedAttachmentUrl(a.fileUrl);
                              await launchUrlString(url);
                            },
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.trash2, size: 16),
                            onPressed: () => cubit.deleteAttachment(a),
                          ),
                        ],
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.pickFiles(withData: true);
                      if (result != null && result.files.isNotEmpty) {
                        await cubit.addAttachment(result.files.first);
                      }
                    },
                    icon: const Icon(LucideIcons.upload, size: 15),
                    label: const Text('Upload file'),
                  ),
                  const SizedBox(height: 20),
                  if (linkedContent != null) ...[
                    _SectionLabel('Linked content item'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(platformStyle(linkedContent.platform).$1,
                              size: 16, color: platformStyle(linkedContent.platform).$2),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(linkedContent.title, style: AppTextStyles.body),
                          ),
                          Text(linkedContent.approvalStatus.label,
                              style: AppTextStyles.caption
                                  .copyWith(color: linkedContent.approvalStatus.color)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  _SectionLabel('Comments'),
                  const SizedBox(height: 8),
                  for (final c in task.comments)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.authorName ?? 'Someone', style: AppTextStyles.subtitle),
                          Text(c.content, style: AppTextStyles.body),
                          Text(DateFormatters.dateTime(c.createdAt),
                              style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: _fieldDecoration(hint: 'Write a comment...'),
                          onSubmitted: (v) {
                            if (v.trim().isNotEmpty) {
                              cubit.addComment(v.trim());
                              _commentController.clear();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('Activity'),
                  const SizedBox(height: 8),
                  for (final log in widget.state.activity)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '${log.actorName ?? 'Someone'} ${log.action.replaceAll('_', ' ')} — ${DateFormatters.dateTime(log.createdAt)}',
                        style: AppTextStyles.caption,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, TaskDrawerCubit cubit) async {
    final confirmed = await showFancyConfirmDialog(
      context,
      title: 'Delete task?',
      message: 'This cannot be undone.',
    );
    if (confirmed) cubit.deleteTask();
  }

  InputDecoration _fieldDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: AppTextStyles.subtitle);
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.value, required this.columns, required this.onChanged});
  final String value;
  final List<BoardColumnModel> columns;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final options = {value, ...columns.map((c) => c.status)}.toList();
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: 'Status',
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      items: options
          .map((s) => DropdownMenuItem(
                value: s,
                child: Text(columns
                    .firstWhere((c) => c.status == s, orElse: () => BoardColumnModel(status: s, title: s, position: 0))
                    .title),
              ))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _PriorityDropdown extends StatelessWidget {
  const _PriorityDropdown({required this.value, required this.onChanged});
  final TaskPriority value;
  final void Function(TaskPriority) onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<TaskPriority>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Priority',
        isDense: true,
        border: OutlineInputBorder(),
      ),
      items: TaskPriority.values
          .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _TaskTypeDropdown extends StatelessWidget {
  const _TaskTypeDropdown({
    required this.value,
    required this.types,
    required this.onChanged,
  });
  final String value;
  final List<TaskTypeModel> types;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final options = {value, ...types.map((t) => t.taskType)}.toList();
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Type',
        isDense: true,
        border: OutlineInputBorder(),
      ),
      items: options
          .map((t) => DropdownMenuItem(
                value: t,
                child: Text(
                    types.firstWhereOrNull((x) => x.taskType == t)?.title ?? t),
              ))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _DueDateField extends StatelessWidget {
  const _DueDateField({required this.value, required this.onChanged});
  final DateTime? value;
  final void Function(DateTime?) onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (pickedDate == null || !context.mounted) return;
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(value ?? DateTime.now()),
        );
        if (pickedTime == null) {
          onChanged(pickedDate);
          return;
        }
        onChanged(DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
            pickedTime.hour, pickedTime.minute));
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Due date',
          isDense: true,
          border: OutlineInputBorder(),
        ),
        child: Text(
          value != null ? DateFormatters.dateTime(value!) : 'None',
          style: AppTextStyles.body,
        ),
      ),
    );
  }
}
