import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
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
    on<CompleteRegistrationFlowEvent>(_onCompleteRegistrationFlow);
  }
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      // Check if user is logged in and has valid data
      if (StorageService.isLoggedIn()) {
        final user = StorageService.getUser();
        final token = StorageService.getToken();

        if (user != null && token != null && token.isNotEmpty) {
          emit(
            AuthAuthenticated(
              user: user,
              requiresPasswordChange: user.isTempPassword,
            ),
          );
        } else {
          // Invalid user data, clear storage and logout
          await StorageService.clearAll();
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      // If there's any error reading auth data, clear it and logout
      await StorageService.clearAll();
      emit(AuthError('Failed to check auth status: ${e.toString()}'));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());

      debugPrint('🚀 Starting login process...');
      debugPrint('📧 Email: ${event.loginRequest.email}');

      final response = await _authRemoteDataSource.login(event.loginRequest);

      debugPrint('✅ Login successful!');
      debugPrint('🔑 Token received: ${response.token.substring(0, 10)}...');

      // Save token and user data
      await StorageService.saveToken(response.token);
      await StorageService.saveUser(response.user);

      debugPrint('💾 User data saved to storage');

      emit(
        AuthAuthenticated(
          user: response.user,
          requiresPasswordChange: response.requiresPasswordChange,
        ),
      );
    } on NetworkException catch (e) {
      debugPrint('🌐 Network error during login: ${e.message}');
      emit(AuthError(e.message));
    } on ServerException catch (e) {
      debugPrint('🔥 Server error during login: ${e.message}');
      emit(AuthError(e.message));
    } on AuthException catch (e) {
      debugPrint('🔐 Auth error during login: ${e.message}');
      emit(AuthError(e.message));
    } catch (e) {
      debugPrint('❌ Unexpected error during login: ${e.toString()}');
      emit(AuthError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());

      debugPrint('🚀 Starting registration process...');
      debugPrint('📧 Email: ${event.registerRequest.email}');
      debugPrint('👤 Name: ${event.registerRequest.name}');

      final response = await _authRemoteDataSource.register(
        event.registerRequest,
      );

      debugPrint('✅ Registration successful!');
      debugPrint('🔑 Token received: ${response.token.substring(0, 10)}...');

      // Save token and user data
      await StorageService.saveToken(response.token);
      await StorageService.saveUser(response.user);

      debugPrint('💾 User data saved to storage');

      emit(
        AuthNewRegistration(
          user: response.user,
          requiresPasswordChange: response.requiresPasswordChange,
        ),
      );
    } on NetworkException catch (e) {
      debugPrint('🌐 Network error during registration: ${e.message}');
      emit(AuthError(e.message));
    } on ServerException catch (e) {
      debugPrint('🔥 Server error during registration: ${e.message}');
      emit(AuthError(e.message));
    } on AuthException catch (e) {
      debugPrint('🔐 Auth error during registration: ${e.message}');
      emit(AuthError(e.message));
    } catch (e) {
      debugPrint('❌ Unexpected error during registration: ${e.toString()}');
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

      emit(
        const ForgotPasswordSuccess('Password reset email sent successfully'),
      );
    } on NetworkException catch (e) {
      emit(AuthError(e.message));
    } on ServerException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Failed to send reset email: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());

      // Clear all stored data
      await StorageService.clearAll();

      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Failed to logout: ${e.toString()}'));
    }
  }

  Future<void> _onCompleteRegistrationFlow(
    CompleteRegistrationFlowEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = StorageService.getUser();
      if (user != null) {
        emit(
          AuthAuthenticated(
            user: user,
            requiresPasswordChange: user.isTempPassword,
          ),
        );
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Failed to complete registration flow: ${e.toString()}'));
    }
  }
}
