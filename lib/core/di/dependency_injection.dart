/// Minimal singleton-map service locator, matching the pattern used across
/// sibling Flutter projects on this machine.
class DependencyInjector {
  DependencyInjector._();

  static final _instances = <Type, dynamic>{};

  static void register<T>(T instance) {
    _instances[T] = instance;
  }

  static T get<T>() {
    final instance = _instances[T];
    if (instance == null) {
      throw StateError('No instance registered for type $T');
    }
    return instance as T;
  }
}
