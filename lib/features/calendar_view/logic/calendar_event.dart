import 'package:flutter/material.dart';
import '../../../core/styling/app_colors.dart';
import '../../content_calendar/data/model/content_item_model.dart';
import '../../content_creation/data/model/content_creation_item_model.dart';
import '../../tasks/data/model/task_model.dart';

/// Unifies tasks (by due date) and content items (by publish date) into
/// one renderable event for Month/Week/Day grids.
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.color,
    required this.isTask,
    this.task,
    this.contentItem,
    this.contentCreationItem,
  });

  final String id;
  final String title;
  final DateTime date;
  final Color color;
  final bool isTask;
  final TaskModel? task;
  final ContentItemModel? contentItem;
  final ContentCreationItemModel? contentCreationItem;

  factory CalendarEvent.fromTask(TaskModel task) => CalendarEvent(
        id: 'task-${task.id}',
        title: task.title,
        date: task.dueDate!,
        color: task.clientColor != null
            ? _hexToColor(task.clientColor!)
            : AppColors.clientColorFor(task.clientId),
        isTask: true,
        task: task,
      );

  factory CalendarEvent.fromContentItem(ContentItemModel item) => CalendarEvent(
        id: 'content-${item.id}',
        title: item.title,
        date: item.publishAt,
        color: item.clientColor != null
            ? _hexToColor(item.clientColor!)
            : AppColors.clientColorFor(item.clientId),
        isTask: false,
        contentItem: item,
      );

  factory CalendarEvent.fromContentCreationItem(ContentCreationItemModel item) =>
      CalendarEvent(
        id: 'content-creation-${item.id}',
        title: item.name,
        date: item.shouldBePublishedOn!,
        color: item.clientColor != null
            ? _hexToColor(item.clientColor!)
            : (item.clientId != null
                ? AppColors.clientColorFor(item.clientId!)
                : AppColors.primary),
        isTask: false,
        contentCreationItem: item,
      );

  static Color _hexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse('FF$cleaned', radix: 16);
    return value != null ? Color(value) : AppColors.primary;
  }
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
