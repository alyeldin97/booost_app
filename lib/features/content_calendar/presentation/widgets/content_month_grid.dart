import 'package:flutter/material.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_styles.dart';
import '../../../calendar_view/logic/calendar_event.dart';

/// Simple 7-column month grid (not table_calendar) so every day cell can
/// be an independent DragTarget for content-item rescheduling.
class ContentMonthGrid extends StatelessWidget {
  const ContentMonthGrid({
    super.key,
    required this.focusedDay,
    required this.eventsByDay,
    required this.onEventTap,
    this.onReschedule,
    this.readOnly = false,
  });

  final DateTime focusedDay;
  final Map<DateTime, List<CalendarEvent>> eventsByDay;
  final void Function(CalendarEvent) onEventTap;
  final void Function(CalendarEvent event, DateTime newDay)? onReschedule;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final leadingBlanks = firstOfMonth.weekday - 1;
    final gridStart = firstOfMonth.subtract(Duration(days: leadingBlanks));
    final totalCells = 42;

    return Column(
      children: [
        Row(
          children: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d, style: AppTextStyles.label),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        for (var week = 0; week < totalCells ~/ 7; week++)
          Expanded(
            child: Row(
              children: [
                for (var day = 0; day < 7; day++)
                  Expanded(
                    child: _DayCell(
                      day: gridStart.add(Duration(days: week * 7 + day)),
                      focusedMonth: focusedDay.month,
                      events: eventsByDay[dateOnly(
                              gridStart.add(Duration(days: week * 7 + day)))] ??
                          const [],
                      onEventTap: onEventTap,
                      onReschedule: onReschedule,
                      readOnly: readOnly,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.focusedMonth,
    required this.events,
    required this.onEventTap,
    required this.onReschedule,
    required this.readOnly,
  });

  final DateTime day;
  final int focusedMonth;
  final List<CalendarEvent> events;
  final void Function(CalendarEvent) onEventTap;
  final void Function(CalendarEvent event, DateTime newDay)? onReschedule;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final inMonth = day.month == focusedMonth;
    final isToday = dateOnly(day) == dateOnly(DateTime.now());

    final cell = _buildCell(context, isToday, inMonth);
    if (readOnly || onReschedule == null) return cell;

    return DragTarget<CalendarEvent>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onReschedule!(details.data, day),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return _buildCell(context, isToday, inMonth, isHovering: isHovering);
      },
    );
  }

  Widget _buildCell(BuildContext context, bool isToday, bool inMonth,
      {bool isHovering = false}) {
    return Container(
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isHovering
                ? AppColors.primaryLight
                : (inMonth ? AppColors.surface : AppColors.background),
            border: Border.all(
              color: isHovering ? AppColors.primary : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: isToday
                    ? BoxDecoration(
                        color: AppColors.primary, borderRadius: BorderRadius.circular(4))
                    : null,
                child: Text(
                  '${day.day}',
                  style: AppTextStyles.caption.copyWith(
                    color: isToday
                        ? Colors.white
                        : (inMonth ? AppColors.textPrimary : AppColors.textMuted),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: events.take(3).map((e) {
                      final chip = GestureDetector(
                        onTap: () => onEventTap(e),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: e.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            e.title,
                            style: AppTextStyles.label.copyWith(color: e.color),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                      if (readOnly) return chip;
                      return Draggable<CalendarEvent>(
                        data: e,
                        feedback: Material(
                          color: Colors.transparent,
                          child: SizedBox(width: 140, child: chip),
                        ),
                        childWhenDragging: Opacity(opacity: 0.3, child: chip),
                        child: chip,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
  }
}
