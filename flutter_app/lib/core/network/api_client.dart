import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectionTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeout,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ),
    );

    // Add auth interceptor (we'll implement this later)
    _dio.interceptors.add(AuthInterceptor());
  }

  Dio get dio => _dio;

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Health check method to test backend connectivity
  Future<bool> testConnection() async {
    try {
      debugPrint('🔍 Testing backend connection to ${AppConstants.baseUrl}');
      final response = await _dio.get(
        '/health',
        options: Options(
          sendTimeout: const Duration(milliseconds: 5000),
          receiveTimeout: const Duration(milliseconds: 5000),
        ),
      );
      debugPrint('✅ Backend connection successful: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Backend connection failed: $e');
      // Connection test failed silently
      return false;
    }
  }

  // Test alternative URLs for connection
  Future<String?> findWorkingBaseUrl() async {
    final testUrls = [
      AppConstants.baseUrl,
      AppConstants.fallbackBaseUrl,
      AppConstants.localBaseUrl,
    ];

    for (final url in testUrls) {
      try {
        debugPrint('🔍 Testing connection to: $url');
        final tempDio = Dio(
          BaseOptions(
            baseUrl: url,
            connectTimeout: const Duration(milliseconds: 5000),
            receiveTimeout: const Duration(milliseconds: 5000),
          ),
        );

        final response = await tempDio.get('/health');
        if (response.statusCode == 200) {
          debugPrint('✅ Found working URL: $url');
          return url;
        }
      } catch (e) {
        debugPrint('❌ Failed to connect to: $url');
        continue;
      }
    }

    debugPrint('❌ No working backend URL found');
    return null;
  }

  // FIXED: Fetch family members with proper POST request
  Future<List<dynamic>> fetchFamilyMembersWithFallback() async {
    try {
      debugPrint('🔍 Fetching family members...');
      // Step 1: Get user info first to get familyId
      final userResponse = await _dio.get('/users/user');
      if (userResponse.statusCode != 200) {
        throw Exception('Failed to get user info');
      }
      final userData = userResponse.data['user'] ?? userResponse.data;
      final familyId = userData['familyId'];
      if (familyId == null) {
        throw Exception('No family ID found');
      }
      debugPrint('👨‍👩‍👧‍👦 Family ID: $familyId');
      // Step 2: Make POST request to /family/FamilyMembers with familyId (as your backend expects)
      Response? membersResponse;
      try {
        debugPrint('🔄 Making POST request to /family/FamilyMembers...');
        membersResponse = await _dio.post(
          '/family/FamilyMembers',
          data: {'familyId': familyId},
        );
        debugPrint('✅ POST request successful');
      } catch (e) {
        debugPrint('❌ POST /family/FamilyMembers failed: $e');
        // Fallback: Try getFamily endpoint
        try {
          debugPrint('🔄 Trying getFamily fallback...');
          final familyResponse = await _dio.post(
            '/family/getFamily',
            data: {'familyId': familyId},
          );
          if (familyResponse.statusCode == 200) {
            final familyData = familyResponse.data['family'];
            if (familyData != null && familyData['members'] != null) {
              final members = familyData['members'] as List;
              debugPrint('👥 Found ${members.length} members in fallback');
              // Debug each member
              for (final member in members) {
                _debugMemberData(member);
              }
              return members;
            }
          }
          throw Exception('Fallback also failed');
        } catch (e2) {
          debugPrint('❌ Fallback also failed: $e2');
          throw Exception('All methods failed to fetch family members: $e2');
        }
      }
      // Process successful response
      if (membersResponse.statusCode == 200) {
        final responseData = membersResponse.data;
        debugPrint('📄 Members response: ${responseData.toString()}');
        List<dynamic> membersData = [];
        // Handle different response structures
        if (responseData['familyWithMembers'] != null) {
          membersData = responseData['familyWithMembers']['members'] ?? [];
        } else if (responseData['members'] != null) {
          membersData = responseData['members'];
        } else if (responseData is List) {
          membersData = responseData;
        } else {
          throw Exception(
            'Unexpected response structure: ${responseData.keys}',
          );
        }
        debugPrint('👥 Found ${membersData.length} members in response');
        // Debug each member
        for (final member in membersData) {
          _debugMemberData(member);
        }
        return membersData;
      } else {
        throw Exception(
          'Failed to fetch family members: ${membersResponse.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error fetching family members: $e');
      rethrow;
    }
  }

  // Helper method to debug member data
  void _debugMemberData(Map<String, dynamic> member) {
    final name = member['name']?.toString() ?? 'Unknown Member';
    final avatar = member['avatar']?.toString() ?? '';
    final gender = member['gender']?.toString() ?? '';
    final role = member['role']?.toString() ?? '';
    debugPrint('👤 Member: $name');
    debugPrint('   Role: $role');
    debugPrint(
      '   Avatar: [1m${avatar.isEmpty ? '[274c MISSING' : '[2705 $avatar'}[0m',
    );
    debugPrint(
      '   Gender: [1m${gender.isEmpty ? '[274c MISSING' : '[2705 $gender'}[0m',
    );
    debugPrint('   ---');
  }

  // Additional method to get family info
  Future<Map<String, dynamic>> getFamilyInfo() async {
    try {
      debugPrint('🔍 Fetching family info...');
      // Get user info first
      final userResponse = await _dio.get('/users/user');
      final userData = userResponse.data['user'] ?? userResponse.data;
      final familyId = userData['familyId'];
      if (familyId == null) {
        throw Exception('No family ID found');
      }
      // Get family details
      final familyResponse = await _dio.post(
        '/family/getFamily',
        data: {'familyId': familyId},
      );
      if (familyResponse.statusCode == 200) {
        return familyResponse.data['family'] ?? {};
      } else {
        throw Exception('Failed to get family info');
      }
    } catch (e) {
      debugPrint('❌ Error fetching family info: $e');
      rethrow;
    }
  }
}

// Auth Interceptor to add token to requests
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add token to headers if available
    final token = StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle auth errors (401) - but don't automatically clear storage
    // The AuthBloc should handle logout logic to maintain state consistency
    if (err.response?.statusCode == 401) {
      // Just log the error, don't clear storage automatically
      debugPrint('401 Unauthorized - token may be expired');
    }
    handler.next(err);
  }
}
