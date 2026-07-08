part of 'auth_cubit.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, failure }

class AuthCubitState extends Equatable {
  const AuthCubitState({
    this.status = AuthStatus.initial,
    this.profile,
    this.errorMessage,
  });

  final AuthStatus status;
  final ProfileModel? profile;
  final String? errorMessage;

  AuthCubitState copyWith({
    AuthStatus? status,
    ProfileModel? profile,
    String? errorMessage,
    bool clearError = false,
  }) =>
      AuthCubitState(
        status: status ?? this.status,
        profile: profile ?? this.profile,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
