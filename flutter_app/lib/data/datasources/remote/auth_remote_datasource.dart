import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<void> forgotPassword(String name, String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        AppConstants.loginEndpoint,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        // Handle non-200 status codes from server
        String errorMessage = 'Login failed';
        if (response.data != null) {
          errorMessage =
              response.data['error'] ??
              response.data['message'] ??
              response.data['detail'] ??
              'Login failed';
        }
        throw ServerException(errorMessage, statusCode: response.statusCode);
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
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.post(
        AppConstants.registerEndpoint,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Registration failed',
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
}
