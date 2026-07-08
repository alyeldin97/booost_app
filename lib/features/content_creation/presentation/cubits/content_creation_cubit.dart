import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../workspace/presentation/cubits/workspace_cubit.dart';
import '../../data/model/content_creation_item_model.dart';
import '../../data/repo/content_creation_items_repository.dart';

class ContentCreationUiState extends Equatable {
  const ContentCreationUiState({
    this.pendingItemIds = const {},
    this.errorTick = 0,
    this.errorMessage,
  });

  final Set<String> pendingItemIds;
  final int errorTick;
  final String? errorMessage;

  ContentCreationUiState copyWith({
    Set<String>? pendingItemIds,
    int? errorTick,
    String? errorMessage,
  }) =>
      ContentCreationUiState(
        pendingItemIds: pendingItemIds ?? this.pendingItemIds,
        errorTick: errorTick ?? this.errorTick,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [pendingItemIds, errorTick, errorMessage];
}

/// Tab-local: mirrors KanbanCubit's optimistic-move-then-rollback pattern
/// for dragging content-creation cards between status columns.
class ContentCreationCubit extends Cubit<ContentCreationUiState> {
  ContentCreationCubit(this._repository, this._workspaceCubit)
      : super(const ContentCreationUiState());

  final ContentCreationItemsRepository _repository;
  final WorkspaceCubit _workspaceCubit;

  Future<void> moveItem(ContentCreationItemModel item, String newStatus) async {
    if (item.status == newStatus) return;
    if (state.pendingItemIds.contains(item.id)) return;

    final previousStatus = item.status;
    emit(state.copyWith(pendingItemIds: {...state.pendingItemIds, item.id}));
    _workspaceCubit.patchContentCreationItemLocally(
        item.id, (c) => c.copyWith(status: newStatus));

    try {
      await _repository.updateStatus(item.id, newStatus);
    } catch (e) {
      _workspaceCubit.patchContentCreationItemLocally(
          item.id, (c) => c.copyWith(status: previousStatus));
      emit(state.copyWith(
        errorTick: state.errorTick + 1,
        errorMessage: 'Could not move "${item.name}". Please try again.',
      ));
    } finally {
      final next = Set<String>.from(state.pendingItemIds)..remove(item.id);
      emit(state.copyWith(pendingItemIds: next));
    }
  }
}
