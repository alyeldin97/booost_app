import 'package:flutter/material.dart';
import '../../styling/app_colors.dart';
import '../../styling/app_text_styles.dart';
import '../../../features/calendar_view/logic/calendar_event.dart';

/// Shared hour-ruler + positioned-event-block timeline, used by both the
/// Calendar View (Week/Day) and Content Calendar (Week), so this layout
/// logic is written once.
class TimelineView extends StatelessWidget {
  const TimelineView({
    super.key,
    required this.days,
    required this.eventsByDay,
    required this.onEventTap,
    this.enableDragDrop = false,
    this.onReschedule,
  });

  final List<DateTime> days;
  final Map<DateTime, List<CalendarEvent>> eventsByDay;
  final void Function(CalendarEvent) onEventTap;

  /// When true, event tiles become draggable and each day column accepts
  /// drops — shared between Calendar View (disabled) and Content Calendar
  /// (enabled), so this drag-and-drop logic is written once.
  final bool enableDragDrop;
  final void Function(CalendarEvent event, DateTime newDay, int hour, int minute)?
      onReschedule;

  static const double hourHeight = 56;
  static const double hourLabelWidth = 52;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HourLabels(),
              for (final day in days)
                _DayColumn(
                  day: day,
                  events: eventsByDay[dateOnly(day)] ?? const [],
                  onEventTap: onEventTap,
                  enableDragDrop: enableDragDrop,
                  onReschedule: onReschedule,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HourLabels extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: TimelineView.hourLabelWidth,
      child: Column(
        children: [
          const SizedBox(height: 40),
          for (var h = 0; h < 24; h++)
            SizedBox(
              height: TimelineView.hourHeight,
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, top: 2),
                  child: Text(_label(h), style: AppTextStyles.label),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _label(int hour) {
    final period = hour < 12 ? 'AM' : 'PM';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return '$h $period';
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.day,
    required this.events,
    required this.onEventTap,
    required this.enableDragDrop,
    required this.onReschedule,
  });

  final DateTime day;
  final List<CalendarEvent> events;
  final void Function(CalendarEvent) onEventTap;
  final bool enableDragDrop;
  final void Function(CalendarEvent event, DateTime newDay, int hour, int minute)?
      onReschedule;

  @override
  Widget build(BuildContext context) {
    final isToday = dateOnly(day) == dateOnly(DateTime.now());
    final header = Container(
      height: 40,
      alignment: Alignment.center,
      color: isToday ? AppColors.primaryLight : null,
      child: Text(
        '${_weekday(day.weekday)} ${day.month}/${day.day}',
        style: AppTextStyles.subtitle.copyWith(
          color: isToday ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
    );

    final body = SizedBox(
      height: TimelineView.hourHeight * 24,
      child: Stack(
        children: [
          for (var h = 0; h < 24; h++)
            Positioned(
              top: h * TimelineView.hourHeight,
              left: 0,
              right: 0,
              child: Divider(height: 1, color: AppColors.border),
            ),
          for (final event in events)
            Positioned(
              top: (event.date.hour + event.date.minute / 60) *
                  TimelineView.hourHeight,
              left: 4,
              right: 4,
              child: _EventBlock(
                event: event,
                onTap: () => onEventTap(event),
                draggable: enableDragDrop,
              ),
            ),
        ],
      ),
    );

    final column = Container(
      width: 200,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [header, body],
      ),
    );

    if (!enableDragDrop || onReschedule == null) return column;

    return DragTarget<CalendarEvent>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final local = box.globalToLocal(details.offset);
        final hourOffset =
            ((local.dy - 40) / TimelineView.hourHeight).clamp(0, 23).floor();
        onReschedule!(details.data, day, hourOffset, 0);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Container(
          decoration: BoxDecoration(
            color: isHovering ? AppColors.primaryLight.withValues(alpha: 0.4) : null,
          ),
          child: column,
        );
      },
    );
  }

  String _weekday(int weekday) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
}

class _EventBlock extends StatelessWidget {
  const _EventBlock({required this.event, required this.onTap, required this.draggable});

  final CalendarEvent event;
  final VoidCallback onTap;
  final bool draggable;

  @override
  Widget build(BuildContext context) {
    final chip = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: event.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border(left: BorderSide(color: event.color, width: 3)),
        ),
        child: Text(
          event.title,
          style: AppTextStyles.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    if (!draggable) return chip;

    return Draggable<CalendarEvent>(
      data: event,
      feedback: Material(color: Colors.transparent, child: SizedBox(width: 180, child: chip)),
      childWhenDragging: Opacity(opacity: 0.3, child: chip),
      child: chip,
    );
  }
}
