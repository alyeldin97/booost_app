import 'dart:async';
import 'package:flutter/foundation.dart';

/// Bridges an auth status stream into go_router's `refreshListenable`,
/// so the router's `redirect` re-evaluates whenever auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
