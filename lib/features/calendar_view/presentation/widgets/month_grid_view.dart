import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../logic/calendar_event.dart';
import 'calendar_item_tile.dart';

class MonthGridView extends StatelessWidget {
  const MonthGridView({
    super.key,
    required this.focusedDay,
    required this.eventsByDay,
    required this.onDaySelected,
    required this.selectedDay,
    required this.onEventTap,
  });

  final DateTime focusedDay;
  final Map<DateTime, List<CalendarEvent>> eventsByDay;
  final void Function(DateTime) onDaySelected;
  final DateTime selectedDay;
  final void Function(CalendarEvent) onEventTap;

  List<CalendarEvent> _eventsFor(DateTime day) =>
      eventsByDay[dateOnly(day)] ?? const [];

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _eventsFor(selectedDay);
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TableCalendar<CalendarEvent>(
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2100, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, selectedDay),
            eventLoader: _eventsFor,
            onDaySelected: (selected, focused) => onDaySelected(selected),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(color: AppColors.primary),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return null;
                final colors = events.map((e) => e.color).toSet().take(4).toList();
                return Positioned(
                  bottom: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: colors
                        .map((c) => Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                            ))
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '${selectedEvents.length} item${selectedEvents.length == 1 ? '' : 's'} on selected day',
            style: AppTextStyles.subtitle,
          ),
        ),
        const SizedBox(height: 8),
        if (selectedEvents.isEmpty)
          Text('Nothing scheduled.', style: AppTextStyles.caption)
        else
          ...selectedEvents.map(
            (e) => CalendarItemTile(event: e, onTap: () => onEventTap(e)),
          ),
      ],
    );
  }
}
