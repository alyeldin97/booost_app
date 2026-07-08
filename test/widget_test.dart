import 'package:flutter_test/flutter_test.dart';
import 'package:booost_app/core/utils/date_formatters.dart';

void main() {
  test('DateFormatters.isOverdue flags past due dates', () {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    expect(DateFormatters.isOverdue(yesterday), isTrue);
    expect(DateFormatters.isOverdue(tomorrow), isFalse);
    expect(DateFormatters.isOverdue(null), isFalse);
  });
}
