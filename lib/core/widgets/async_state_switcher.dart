import 'package:flutter/material.dart';
import 'empty_state.dart';
import 'error_state.dart';
import 'loading_indicator.dart';

enum AsyncStatus { initial, loading, success, failure }

/// Standardizes loading/empty/error rendering across every cubit that
/// follows the `initial|loading|success|failure` status shape, so each
/// of the four workspace views doesn't reimplement this switch.
class AsyncStateSwitcher<T> extends StatelessWidget {
  const AsyncStateSwitcher({
    super.key,
    required this.status,
    required this.data,
    required this.isEmpty,
    required this.builder,
    required this.emptyIcon,
    required this.emptyTitle,
    this.emptyMessage,
    this.errorMessage,
    this.onRetry,
  });

  final AsyncStatus status;
  final T data;
  final bool isEmpty;
  final WidgetBuilder Function(T data) builder;
  final IconData emptyIcon;
  final String emptyTitle;
  final String? emptyMessage;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (status == AsyncStatus.loading && isEmpty) {
      return const LoadingIndicator();
    }
    if (status == AsyncStatus.failure && isEmpty) {
      return ErrorState(
        message: errorMessage ?? 'Please try again.',
        onRetry: onRetry,
      );
    }
    if (isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        message: emptyMessage,
      );
    }
    return builder(data)(context);
  }
}
