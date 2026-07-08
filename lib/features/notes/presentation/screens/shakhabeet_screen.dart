import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../workspace/presentation/cubits/workspace_cubit.dart';
import '../../data/model/note_model.dart';
import '../../data/repo/notes_repository.dart';

/// A place to jot down ideas/notes for future reference, separate from
/// the task-tracking Kanban board.
class ShakhabeetScreen extends StatelessWidget {
  const ShakhabeetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceCubit, WorkspaceCubitState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              try {
                final note = await context.read<NotesRepository>().createNote();
                if (context.mounted) {
                  await context.read<WorkspaceCubit>().load();
                  if (context.mounted) _openNoteEditor(context, note);
                }
              } catch (e) {
                if (context.mounted) AppToast.error(context, 'Could not create note: $e');
              }
            },
            icon: const Icon(LucideIcons.plus),
            label: const Text('New note'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shakhabeet', style: AppTextStyles.h2),
                const SizedBox(height: 4),
                Text('Ideas and notes for future reference.',
                    style: AppTextStyles.caption),
                const SizedBox(height: 16),
                Expanded(
                  child: state.notes.isEmpty
                      ? const EmptyState(
                          icon: LucideIcons.notebookPen,
                          title: 'No notes yet',
                          message: 'Tap "New note" to jot something down.',
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: state.notes.length,
                          itemBuilder: (context, i) {
                            final note = state.notes[i];
                            return _NoteCard(
                              note: note,
                              onTap: () => _openNoteEditor(context, note),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openNoteEditor(BuildContext context, NoteModel note) {
    showDialog(
      context: context,
      // Keeps the dialog within the Workspace shell's nested navigator so
      // context.read<WorkspaceCubit>() inside it still resolves — see
      // create_content_item_dialog.dart for the full explanation.
      useRootNavigator: false,
      builder: (dialogContext) => _NoteEditorDialog(note: note),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note, required this.onTap});
  final NoteModel note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFEF9C3),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(note.title,
                  style: AppTextStyles.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  note.content ?? '',
                  style: AppTextStyles.body,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(DateFormatters.dueDate(note.updatedAt), style: AppTextStyles.label),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteEditorDialog extends StatefulWidget {
  const _NoteEditorDialog({required this.note});
  final NoteModel note;

  @override
  State<_NoteEditorDialog> createState() => _NoteEditorDialogState();
}

class _NoteEditorDialogState extends State<_NoteEditorDialog> {
  late final _titleController = TextEditingController(text: widget.note.title);
  late final _contentController = TextEditingController(text: widget.note.content ?? '');

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      await context.read<NotesRepository>().updateNote(widget.note.id, {
        'title': _titleController.text.trim().isEmpty
            ? 'Untitled'
            : _titleController.text.trim(),
        'content': _contentController.text,
      });
      if (mounted) await context.read<WorkspaceCubit>().load();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) AppToast.error(context, 'Could not save note: $e');
    }
  }

  Future<void> _delete() async {
    try {
      await context.read<NotesRepository>().deleteNote(widget.note.id);
      if (mounted) await context.read<WorkspaceCubit>().load();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) AppToast.error(context, 'Could not delete note: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                style: AppTextStyles.h3,
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Title'),
              ),
              const Divider(),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: AppTextStyles.body,
                  decoration:
                      const InputDecoration(border: InputBorder.none, hintText: 'Write here...'),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _delete,
                    icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.danger),
                    label: const Text('Delete', style: TextStyle(color: AppColors.danger)),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _save, child: const Text('Save')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
