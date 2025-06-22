import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<void> forgotPassword(String name, String email);
  Future<AuthResponse> addFamilyMember(AddMemberRequest request);
  Future<UserModel> getCurrentUser();
  Future<void> changePassword(ChangePasswordRequest request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  AuthRemoteDataSourceImpl(this._apiClient);
  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      debugPrint(
        '📡 Sending login request to ${AppConstants.baseUrl}${AppConstants.loginEndpoint}',
      );
      debugPrint('📧 Email: ${request.email}');

      final response = await _apiClient.post(
        AppConstants.loginEndpoint,
        data: request.toJson(),
      );

      debugPrint('📨 Login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ Login successful, parsing response...');
        return AuthResponse.fromJson(response.data);
      } else {
        debugPrint('❌ Login failed with status: ${response.statusCode}');
        debugPrint(
          '📄 Response data: ${response.data}',
        ); // Handle non-200 status codes from server
        String errorMessage = 'Login failed';
        if (response.data != null) {
          errorMessage =
              response.data['error'] ??
              response.data['message'] ??
              response.data['detail'] ??
              'Login failed';
        } // Provide user-friendly error messages for common cases
        if (response.statusCode == 401 || response.statusCode == 403) {
          errorMessage = 'Your name, email or password is wrong';
        } else if (response.statusCode == 404) {
          errorMessage = 'Account not found. Please check your credentials';
        } else if (response.statusCode == 429) {
          errorMessage = 'Too many login attempts. Please try again later';
        } else if (response.statusCode == 500) {
          errorMessage =
              'Server is currently unavailable. Please try again later';
        }

        debugPrint(
          '🚨 Login error: $errorMessage (Status: ${response.statusCode})',
        );
        throw ServerException(errorMessage, statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      debugPrint('🔥 Dio exception during login: ${e.type}');
      debugPrint('📄 Error response: ${e.response?.data}');
      debugPrint('🔢 Status code: ${e.response?.statusCode}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException('No internet connection');
      } else if (e.response != null) {
        String errorMessage =
            'Server error'; // Handle authentication errors specifically
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          errorMessage = 'Your name, email or password is wrong';
        } else if (e.response?.statusCode == 404) {
          errorMessage = 'Account not found. Please check your credentials';
        } else if (e.response?.statusCode == 429) {
          errorMessage = 'Too many login attempts. Please try again later';
        } else if (e.response?.statusCode == 500) {
          errorMessage =
              'Server is currently unavailable. Please try again later';
        } else if (e.response?.data != null) {
          errorMessage =
              e.response?.data['message'] ??
              e.response?.data['error'] ??
              e.response?.data['detail'] ??
              'Server error';
        }

        debugPrint(
          '🚨 DioException login error: $errorMessage (Status: ${e.response?.statusCode})',
        );
        throw ServerException(errorMessage, statusCode: e.response?.statusCode);
      } else {
        throw const ServerException('Unknown error occurred');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error during login: $e');
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      debugPrint(
        '📡 Sending registration request to ${AppConstants.baseUrl}${AppConstants.registerEndpoint}',
      );

      final response = await _apiClient.post(
        AppConstants.registerEndpoint,
        data: request.toJson(),
      );

      debugPrint('📨 Registration response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Registration successful, parsing response...');
        return AuthResponse.fromJson(response.data);
      } else {
        debugPrint('❌ Registration failed with status: ${response.statusCode}');
        debugPrint('📄 Response data: ${response.data}');
        throw ServerException(
          response.data['message'] ?? 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('🔥 Dio exception during registration: ${e.type}');
      debugPrint('📄 Error response: ${e.response?.data}');
      debugPrint('🔢 Status code: ${e.response?.statusCode}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException('No internet connection');
      } else if (e.response != null) {
        String errorMessage = 'Server error';
        if (e.response?.data != null) {
          errorMessage =
              e.response?.data['message'] ??
              e.response?.data['error'] ??
              e.response?.data['detail'] ??
              'Server error';
        }
        throw ServerException(errorMessage, statusCode: e.response?.statusCode);
      } else {
        throw const ServerException('Unknown error occurred');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error during registration: $e');
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> forgotPassword(String name, String email) async {
    try {
      final response = await _apiClient.post(
        AppConstants.forgotPasswordEndpoint,
        data: {'name': name, 'email': email},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['message'] ?? 'Failed to send reset email',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException('No internet connection');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Server error',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw const ServerException('Unknown error occurred');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponse> addFamilyMember(AddMemberRequest request) async {
    try {
      debugPrint(
        '📡 Sending add family member request to ${AppConstants.baseUrl}/users',
      );
      debugPrint('👤 Member name: ${request.name}');

      final response = await _apiClient.post('/users', data: request.toJson());

      debugPrint('📨 Add member response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ Family member added successfully');
        // Return a success response - the backend sends email with temp password
        return AuthResponse(
          user: UserModel.fromJson(response.data['user']),
          token: '', // No token needed for this operation
          requiresPasswordChange: false,
          message:
              response.data['message'] ?? 'Family member added successfully',
        );
      } else {
        debugPrint('❌ Add member failed with status: ${response.statusCode}');
        throw ServerException(
          response.data['message'] ?? 'Failed to add family member',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('🔥 Dio exception during add member: ${e.type}');
      debugPrint('📄 Error response: ${e.response?.data}');
      debugPrint('🔢 Status code: ${e.response?.statusCode}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException('No internet connection');
      } else if (e.response != null) {
        String errorMessage = 'Server error';
        if (e.response?.data != null) {
          errorMessage =
              e.response?.data['message'] ??
              e.response?.data['error'] ??
              e.response?.data['detail'] ??
              'Server error';
        }
        throw ServerException(errorMessage, statusCode: e.response?.statusCode);
      } else {
        throw const ServerException('Unknown error occurred');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error during add member: $e');
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      debugPrint(
        '📡 Sending change password request to ${AppConstants.baseUrl}/users/updatePassword',
      );

      final response = await _apiClient.put(
        '/users/updatePassword',
        data: request.toJson(),
      );

      debugPrint('📨 Change password response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ Password changed successfully');
      } else {
        debugPrint(
          '❌ Password change failed with status: ${response.statusCode}',
        );
        throw ServerException(
          response.data['message'] ?? 'Failed to change password',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('🔥 Dio exception during password change: ${e.type}');
      debugPrint('📄 Error response: ${e.response?.data}');
      debugPrint('🔢 Status code: ${e.response?.statusCode}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException('No internet connection');
      } else if (e.response != null) {
        String errorMessage = 'Server error';
        if (e.response?.data != null) {
          errorMessage =
              e.response?.data['message'] ??
              e.response?.data['error'] ??
              e.response?.data['detail'] ??
              'Server error';
        }
        throw ServerException(errorMessage, statusCode: e.response?.statusCode);
      } else {
        throw const ServerException('Unknown error occurred');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error during password change: $e');
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  // ...existing code...

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/users/user');

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to get user data',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException('No internet connection');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Server error',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw const ServerException('Unknown error occurred');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}
