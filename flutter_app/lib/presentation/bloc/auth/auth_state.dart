import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  final bool requiresPasswordChange;

  const AuthAuthenticated({
    required this.user,
    this.requiresPasswordChange = false,
  });

  @override
  List<Object> get props => [user, requiresPasswordChange];
}

class AuthNewRegistration extends AuthState {
  final UserModel user;
  final bool requiresPasswordChange;

  const AuthNewRegistration({
    required this.user,
    this.requiresPasswordChange = false,
  });

  @override
  List<Object> get props => [user, requiresPasswordChange];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class ForgotPasswordSuccess extends AuthState {
  final String message;

  const ForgotPasswordSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class PasswordChangeSuccess extends AuthState {
  final UserModel user;
  const PasswordChangeSuccess({required this.user});
  @override
  List<Object> get props => [user];
}
