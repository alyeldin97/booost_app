import 'package:intl/intl.dart';

class DateFormatters {
  DateFormatters._();

  static final _dueDate = DateFormat('MMM d');
  static final _dueDateWithYear = DateFormat('MMM d, yyyy');
  static final _time = DateFormat('h:mm a');
  static final _dateTime = DateFormat('MMM d, h:mm a');
  static final _monthYear = DateFormat('MMMM yyyy');
  static final _weekday = DateFormat('EEE');
  static final _iso = DateFormat('yyyy-MM-dd');

  static String dueDate(DateTime date) {
    final now = DateTime.now();
    final formatter = date.year == now.year ? _dueDate : _dueDateWithYear;
    return formatter.format(date);
  }

  static String time(DateTime date) => _time.format(date);
  static String dateTime(DateTime date) => _dateTime.format(date);
  static String monthYear(DateTime date) => _monthYear.format(date);
  static String weekday(DateTime date) => _weekday.format(date);
  static String iso(DateTime date) => _iso.format(date);

  static bool isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return dueDate.isBefore(startOfToday);
  }

  static bool isDueThisWeek(DateTime? dueDate) {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfWeek = startOfToday.add(const Duration(days: 7));
    return !dueDate.isBefore(startOfToday) && dueDate.isBefore(endOfWeek);
  }
}
