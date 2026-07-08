import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void info(String message) {
    if (kDebugMode) debugPrint('[Booost] $message');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[Booost][ERROR] $message${error != null ? ' — $error' : ''}');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
  }
}
