import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../../core/utils/app_logger.dart';
import '../../data/model/profile_model.dart';
import '../../data/repo/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthCubitState> {
  AuthCubit(this._repository) : super(const AuthCubitState()) {
    _subscription = _repository.onAuthStateChange.listen(_onAuthEvent);
    if (_repository.isAuthenticated) {
      _loadProfile();
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  final AuthRepository _repository;
  StreamSubscription<dynamic>? _subscription;

  void _onAuthEvent(dynamic event) {
    final eventType = event.event;
    if (eventType == AuthChangeEvent.signedIn ||
        eventType == AuthChangeEvent.tokenRefreshed) {
      _loadProfile();
    } else if (eventType == AuthChangeEvent.signedOut) {
      emit(const AuthCubitState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _repository.fetchCurrentProfile();
      emit(state.copyWith(status: AuthStatus.authenticated, profile: profile));
    } catch (e, st) {
      AppLogger.error('Failed to load profile', e, st);
      emit(state.copyWith(status: AuthStatus.authenticated));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _repository.signIn(email: email, password: password);
      // Profile load is driven by the onAuthStateChange listener.
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: _friendlyError(e),
      ));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _repository.signUp(email: email, password: password, fullName: fullName);
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: _friendlyError(e),
      ));
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }

  String _friendlyError(Object e) {
    if (e is AuthException) return e.message;
    return 'Something went wrong. Please try again.';
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
