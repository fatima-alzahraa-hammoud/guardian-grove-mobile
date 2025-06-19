import 'package:equatable/equatable.dart';

// Base exception class
abstract class AppException extends Equatable implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

// Server exception for API errors
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

// Network exception for connection issues
class NetworkException extends AppException {
  const NetworkException(super.message);
}

// Cache exception for local storage issues
class CacheException extends AppException {
  const CacheException(super.message);
}

// Auth exception for authentication issues
class AuthException extends AppException {
  const AuthException(super.message, {super.statusCode});
}

// Validation exception for input validation
class ValidationException extends AppException {
  const ValidationException(super.message);
}