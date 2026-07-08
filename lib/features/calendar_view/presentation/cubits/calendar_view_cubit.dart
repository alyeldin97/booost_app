import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum CalendarDisplayMode { month, week, day }

enum ItemToggle { all, tasksOnly, contentOnly }

class CalendarViewState extends Equatable {
  const CalendarViewState({
    this.mode = CalendarDisplayMode.month,
    this.toggle = ItemToggle.all,
    required this.focusedDay,
  });

  final CalendarDisplayMode mode;
  final ItemToggle toggle;
  final DateTime focusedDay;

  CalendarViewState copyWith({
    CalendarDisplayMode? mode,
    ItemToggle? toggle,
    DateTime? focusedDay,
  }) =>
      CalendarViewState(
        mode: mode ?? this.mode,
        toggle: toggle ?? this.toggle,
        focusedDay: focusedDay ?? this.focusedDay,
      );

  @override
  List<Object?> get props => [mode, toggle, focusedDay];
}

class CalendarViewCubit extends Cubit<CalendarViewState> {
  CalendarViewCubit() : super(CalendarViewState(focusedDay: DateTime.now()));

  void setMode(CalendarDisplayMode mode) => emit(state.copyWith(mode: mode));
  void setToggle(ItemToggle toggle) => emit(state.copyWith(toggle: toggle));
  void setFocusedDay(DateTime day) => emit(state.copyWith(focusedDay: day));

  void goToday() => emit(state.copyWith(focusedDay: DateTime.now()));

  void goNext() {
    final d = state.focusedDay;
    emit(state.copyWith(
      focusedDay: switch (state.mode) {
        CalendarDisplayMode.month => DateTime(d.year, d.month + 1, 1),
        CalendarDisplayMode.week => d.add(const Duration(days: 7)),
        CalendarDisplayMode.day => d.add(const Duration(days: 1)),
      },
    ));
  }

  void goPrevious() {
    final d = state.focusedDay;
    emit(state.copyWith(
      focusedDay: switch (state.mode) {
        CalendarDisplayMode.month => DateTime(d.year, d.month - 1, 1),
        CalendarDisplayMode.week => d.subtract(const Duration(days: 7)),
        CalendarDisplayMode.day => d.subtract(const Duration(days: 1)),
      },
    ));
  }
}
