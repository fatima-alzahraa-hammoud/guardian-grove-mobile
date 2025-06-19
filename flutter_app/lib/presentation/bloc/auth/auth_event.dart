import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final LoginRequest loginRequest;

  const LoginEvent(this.loginRequest);

  @override
  List<Object> get props => [loginRequest];
}

class RegisterEvent extends AuthEvent {
  final RegisterRequest registerRequest;

  const RegisterEvent(this.registerRequest);

  @override
  List<Object> get props => [registerRequest];
}

class ForgotPasswordEvent extends AuthEvent {
  final String name;
  final String email;

  const ForgotPasswordEvent({
    required this.name,
    required this.email,
  });

  @override
  List<Object> get props => [name, email];
}

class LogoutEvent extends AuthEvent {}