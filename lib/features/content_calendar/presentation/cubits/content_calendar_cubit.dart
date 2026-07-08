import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ContentDisplayMode { month, week, list }

class ContentCalendarState extends Equatable {
  const ContentCalendarState({this.mode = ContentDisplayMode.month, required this.focusedDay});

  final ContentDisplayMode mode;
  final DateTime focusedDay;

  ContentCalendarState copyWith({ContentDisplayMode? mode, DateTime? focusedDay}) =>
      ContentCalendarState(
        mode: mode ?? this.mode,
        focusedDay: focusedDay ?? this.focusedDay,
      );

  @override
  List<Object?> get props => [mode, focusedDay];
}

class ContentCalendarCubit extends Cubit<ContentCalendarState> {
  ContentCalendarCubit() : super(ContentCalendarState(focusedDay: DateTime.now()));

  void setMode(ContentDisplayMode mode) => emit(state.copyWith(mode: mode));
  void setFocusedDay(DateTime day) => emit(state.copyWith(focusedDay: day));
  void goToday() => emit(state.copyWith(focusedDay: DateTime.now()));

  void goNext() {
    final d = state.focusedDay;
    emit(state.copyWith(
      focusedDay: switch (state.mode) {
        ContentDisplayMode.month => DateTime(d.year, d.month + 1, 1),
        ContentDisplayMode.week => d.add(const Duration(days: 7)),
        ContentDisplayMode.list => d.add(const Duration(days: 30)),
      },
    ));
  }

  void goPrevious() {
    final d = state.focusedDay;
    emit(state.copyWith(
      focusedDay: switch (state.mode) {
        ContentDisplayMode.month => DateTime(d.year, d.month - 1, 1),
        ContentDisplayMode.week => d.subtract(const Duration(days: 7)),
        ContentDisplayMode.list => d.subtract(const Duration(days: 30)),
      },
    ));
  }
}
