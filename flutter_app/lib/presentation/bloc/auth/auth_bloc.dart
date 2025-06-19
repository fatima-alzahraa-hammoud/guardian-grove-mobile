import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/datasources/remote/auth_remote_datasource.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRemoteDataSource _authRemoteDataSource;

  AuthBloc(this._authRemoteDataSource) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      
      // Check if user is logged in
      if (StorageService.isLoggedIn()) {
        final user = StorageService.getUser();
        if (user != null) {
          emit(AuthAuthenticated(
            user: user,
            requiresPasswordChange: user.isTempPassword,
          ));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Failed to check auth status: ${e.toString()}'));
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      final response = await _authRemoteDataSource.login(event.loginRequest);

      // Save token and user data
      await StorageService.saveToken(response.token);
      await StorageService.saveUser(response.user);

      emit(AuthAuthenticated(
        user: response.user,
        requiresPasswordChange: response.requiresPasswordChange,
      ));
    } on NetworkException catch (e) {
      emit(AuthError(e.message));
    } on ServerException catch (e) {
      emit(AuthError(e.message));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      final response = await _authRemoteDataSource.register(event.registerRequest);

      // Save token and user data
      await StorageService.saveToken(response.token);
      await StorageService.saveUser(response.user);

      emit(AuthAuthenticated(
        user: response.user,
        requiresPasswordChange: response.requiresPasswordChange,
      ));
    } on NetworkException catch (e) {
      emit(AuthError(e.message));
    } on ServerException catch (e) {
      emit(AuthError(e.message));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      await _authRemoteDataSource.forgotPassword(event.name, event.email);

      emit(const ForgotPasswordSuccess('Password reset email sent successfully'));
    } on NetworkException catch (e) {
      emit(AuthError(e.message));
    } on ServerException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Failed to send reset email: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      // Clear all stored data
      await StorageService.clearAll();

      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Failed to logout: ${e.toString()}'));
    }
  }
}