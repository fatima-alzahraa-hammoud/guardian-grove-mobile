import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../../data/models/family_model.dart';
import '../../data/models/home_model.dart';

class FamilyApiService {
  static final FamilyApiService _instance = FamilyApiService._internal();
  factory FamilyApiService() => _instance;
  FamilyApiService._internal();

  late Dio _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = StorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  // MAIN METHOD: Get family members with comprehensive fallback
  Future<List<FamilyMember>> getFamilyMembers() async {
    try {
      debugPrint('🔍 FamilyApiService: Fetching family members...');

      // Step 1: Get user info to get familyId
      final userResponse = await _dio.get('/users/user');
      if (userResponse.statusCode != 200) {
        throw Exception('Failed to get user info');
      }

      final userData = userResponse.data['user'] ?? userResponse.data;
      final familyId = userData['familyId'];

      if (familyId == null) {
        debugPrint('❌ FamilyApiService: No family ID found');
        return [];
      }

      debugPrint('👨‍👩‍👧‍👦 FamilyApiService: Family ID: $familyId');

      List<dynamic> membersData = [];

      // Method 1: Try GET /family/FamilyMembers?familyId=... (what backend expects)
      try {
        debugPrint(
          '🔄 FamilyApiService: Trying GET /family/FamilyMembers?familyId=...',
        );
        final membersResponse = await _dio.get(
          '/family/FamilyMembers',
          queryParameters: {'familyId': familyId},
        );

        if (membersResponse.statusCode == 200) {
          final responseData = membersResponse.data;

          if (responseData['members'] != null) {
            membersData = responseData['members'];
          } else if (responseData is List) {
            membersData = responseData;
          }

          if (membersData.isNotEmpty) {
            debugPrint('✅ FamilyApiService: GET request successful');
            return _processMembersData(membersData);
          }
        }
      } catch (e) {
        debugPrint('❌ FamilyApiService: GET /family/FamilyMembers failed: $e');
      }

      // Method 2: POST to /family/FamilyMembers (fallback)
      try {
        debugPrint(
          '🔄 FamilyApiService: Trying POST /family/FamilyMembers as fallback...',
        );
        final membersResponse = await _dio.post(
          '/family/FamilyMembers',
          data: {'familyId': familyId},
        );

        if (membersResponse.statusCode == 200) {
          debugPrint('✅ FamilyApiService: POST request successful');
          final responseData = membersResponse.data;

          if (responseData['familyWithMembers'] != null) {
            membersData = responseData['familyWithMembers']['members'] ?? [];
          } else if (responseData['members'] != null) {
            membersData = responseData['members'];
          } else if (responseData is List) {
            membersData = responseData;
          }

          if (membersData.isNotEmpty) {
            return _processMembersData(membersData);
          }
        }
      } catch (e) {
        debugPrint('❌ FamilyApiService: POST /family/FamilyMembers failed: $e');
      }

      // Method 3: Fallback to /family/getFamily
      try {
        debugPrint('🔄 FamilyApiService: Trying getFamily fallback...');
        final familyResponse = await _dio.post(
          '/family/getFamily',
          data: {'familyId': familyId},
        );

        if (familyResponse.statusCode == 200) {
          final familyData = familyResponse.data['family'];
          if (familyData != null && familyData['members'] != null) {
            membersData = familyData['members'] as List;
            debugPrint('✅ FamilyApiService: getFamily fallback successful');
            return _processMembersData(membersData);
          }
        }
      } catch (e) {
        debugPrint('❌ FamilyApiService: getFamily fallback failed: $e');
      }

      return [];
    } catch (e) {
      debugPrint('❌ FamilyApiService: Unexpected error: $e');
      return [];
    }
  }

  // Process members data into FamilyMember objects
  List<FamilyMember> _processMembersData(List<dynamic> membersData) {
    debugPrint('🔄 FamilyApiService: Processing ${membersData.length} members');

    final members =
        membersData.map((memberData) {
          final name = memberData['name']?.toString() ?? 'Unknown Member';
          final avatar = memberData['avatar']?.toString() ?? '';
          final gender = memberData['gender']?.toString() ?? '';
          final role = memberData['role']?.toString() ?? 'member';

          debugPrint('👤 FamilyApiService: Processing $name');
          debugPrint('   Role: $role');
          debugPrint(
            '   Avatar: ${avatar.isEmpty ? '❌ MISSING' : '✅ $avatar'}',
          );
          debugPrint(
            '   Gender: ${gender.isEmpty ? '❌ MISSING' : '✅ $gender'}',
          );

          return FamilyMember(
            id:
                memberData['_id']?.toString() ??
                memberData['id']?.toString() ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            role: role,
            gender: gender,
            avatar: avatar,
            birthday:
                memberData['birthday'] != null
                    ? DateTime.tryParse(memberData['birthday'].toString())
                    : null,
            interests:
                memberData['interests'] != null &&
                        memberData['interests'] is List
                    ? List<String>.from(memberData['interests'])
                    : <String>[],
          );
        }).toList();

    debugPrint(
      '✅ FamilyApiService: Successfully processed ${members.length} members',
    );
    return members;
  }

  // Get family info
  Future<Map<String, dynamic>?> getFamilyInfo() async {
    try {
      debugPrint('🔍 FamilyApiService: Fetching family info...');

      // Get user info first
      final userResponse = await _dio.get('/users/user');
      final userData = userResponse.data['user'] ?? userResponse.data;
      final familyId = userData['familyId'];

      if (familyId == null) {
        debugPrint('❌ FamilyApiService: No family ID found for family info');
        return null;
      }

      // Get family details
      final familyResponse = await _dio.post(
        '/family/getFamily',
        data: {'familyId': familyId},
      );

      if (familyResponse.statusCode == 200) {
        debugPrint('✅ FamilyApiService: Family info retrieved');
        return familyResponse.data['family'];
      } else {
        debugPrint('❌ FamilyApiService: Failed to get family info');
        return null;
      }
    } catch (e) {
      debugPrint('❌ FamilyApiService: Error fetching family info: $e');
      return null;
    }
  }

  // Get family name and member count
  Future<Map<String, dynamic>> getFamilyStats() async {
    try {
      final familyInfo = await getFamilyInfo();
      final members = await getFamilyMembers();

      return {
        'familyName': familyInfo?['familyName'] ?? '',
        'familyAvatar': familyInfo?['familyAvatar'] ?? '',
        'memberCount': members.length,
        'members': members,
      };
    } catch (e) {
      debugPrint('❌ FamilyApiService: Error getting family stats: $e');
      return {
        'familyName': '',
        'familyAvatar': '',
        'memberCount': 0,
        'members': <FamilyMember>[],
      };
    }
  }

  /// Fetch family members and print debug output for each member (for troubleshooting)
  static Future<List<FamilyMember>> fetchFamilyMembersWithDebug() async {
    final service = FamilyApiService();
    service.init();
    final members = await service.getFamilyMembers();
    debugPrint(
      '🔎 [FamilyApiService.fetchFamilyMembersWithDebug] Members fetched: ${members.length}',
    );
    for (final member in members) {
      debugPrint(
        '   - ${member.name} (ID: ${member.id}) | Avatar: ${member.avatar.isNotEmpty ? member.avatar : '❌'} | Gender: ${member.gender.isNotEmpty ? member.gender : '❌'} | Role: ${member.role}',
      );
    }
    return members;
  }

  // Unified method: Fetch complete family data (user, family, members, stats)
  Future<HomeData> getFamilyCompleteData() async {
    try {
      debugPrint('🔍 [getFamilyCompleteData] Fetching user info...');
      final userResponse = await _dio.get('/users/user');
      final userData = userResponse.data['user'] ?? userResponse.data;
      final familyId = userData['familyId'];
      if (familyId == null) throw Exception('No familyId found');

      debugPrint('🔍 [getFamilyCompleteData] Fetching family info...');
      final familyResponse = await _dio.post(
        '/family/getFamily',
        data: {'familyId': familyId},
      );
      final familyData = familyResponse.data['family'];
      if (familyData == null) throw Exception('No family data found');

      debugPrint('🔍 [getFamilyCompleteData] Fetching family members...');
      final membersResponse = await _dio.post(
        '/family/FamilyMembers',
        data: {'familyId': familyId},
      );
      List<dynamic> membersData = [];
      if (membersResponse.statusCode == 200) {
        final responseData = membersResponse.data;
        if (responseData['familyWithMembers'] != null) {
          membersData = responseData['familyWithMembers']['members'] ?? [];
        } else if (responseData['members'] != null) {
          membersData = responseData['members'];
        } else if (responseData is List) {
          membersData = responseData;
        }
      }
      // Fallback to familyData['members'] if needed
      if (membersData.isEmpty && familyData['members'] != null) {
        membersData = familyData['members'] as List;
      }

      debugPrint('📦 [getFamilyCompleteData] Parsing HomeData...');
      return HomeData.fromJson({
        '_id': familyData['_id'],
        'user': userData,
        'family_stats': {
          'totalStars': familyData['totalStars'] ?? 0,
          'tasks': familyData['totalTasks'] ?? 0,
          'stars': familyData['stars'] ?? {},
          'taskCounts': familyData['taskCounts'] ?? {},
        },
        'familyName': familyData['familyName'] ?? '',
        'familyAvatar': familyData['familyAvatar'] ?? '',
        'members': membersData,
        'email': familyData['email'] ?? '',
        'createdAt': familyData['createdAt'] ?? '',
        'notifications': familyData['notifications'] ?? [],
        'goals': familyData['goals'] ?? [],
        'achievements': familyData['achievements'] ?? [],
        'sharedStories': familyData['sharedStories'] ?? [],
      });
    } catch (e) {
      debugPrint('❌ [getFamilyCompleteData] Failed: $e');
      rethrow;
    }
  }

  /// Update user profile - Enhanced to match backend API
  Future<bool> editUserProfile(Map<String, dynamic> userData) async {
    try {
      debugPrint('📝 FamilyApiService: Editing user profile...');
      debugPrint('📄 Data being sent: $userData');
      // Your backend expects PUT /users/editUserProfile
      final response = await _dio.put('/users/editUserProfile', data: userData);
      debugPrint('📄 Response status: \\${response.statusCode}');
      debugPrint('📄 Response data: \\${response.data}');
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['message'] != null || responseData['user'] != null) {
          debugPrint('✅ FamilyApiService: User profile updated successfully');
          return true;
        }
      }
      debugPrint(
        '❌ FamilyApiService: Unexpected response format: \\${response.data}',
      );
      return false;
    } catch (e) {
      debugPrint('❌ FamilyApiService: Error editing user profile: $e');
      if (e is DioException) {
        debugPrint('❌ DioException details: \\${e.response?.data}');
        debugPrint('❌ Status code: \\${e.response?.statusCode}');
        debugPrint('❌ Request data: \\${e.requestOptions.data}');
        debugPrint('❌ Request headers: \\${e.requestOptions.headers}');
        if (e.response?.statusCode == 401) {
          throw Exception('Unauthorized: Please log in again');
        } else if (e.response?.statusCode == 403) {
          throw Exception(
            'Forbidden: You don\'t have permission to update this profile',
          );
        } else if (e.response?.statusCode == 404) {
          throw Exception('User not found');
        } else if (e.response?.statusCode == 400) {
          final errorMsg =
              e.response?.data['message'] ?? 'Invalid data provided';
          throw Exception(errorMsg);
        } else {
          throw Exception('Network error: \\${e.message}');
        }
      }
      rethrow;
    }
  }

  /// Update family details (name, email, avatar) - Enhanced to match backend API
  Future<bool> updateFamilyDetails(Map<String, dynamic> familyData) async {
    try {
      debugPrint('📝 FamilyApiService: Updating family details...');
      debugPrint('📄 Data being sent: $familyData');

      // Your backend expects PUT /family/updateFamily
      final response = await _dio.put('/family/updateFamily', data: familyData);

      debugPrint('📄 Response status: \\${response.statusCode}');
      debugPrint('📄 Response data: \\${response.data}');

      if (response.statusCode == 200) {
        // Check for success message or family data in response
        final responseData = response.data;
        if (responseData['message'] != null || responseData['family'] != null) {
          debugPrint('✅ FamilyApiService: Family details updated successfully');
          return true;
        }
      }

      debugPrint(
        '❌ FamilyApiService: Unexpected response format: \\${response.data}',
      );
      return false;
    } catch (e) {
      debugPrint('❌ FamilyApiService: Error updating family details: $e');
      if (e is DioException) {
        debugPrint('❌ DioException details: \\${e.response?.data}');
        debugPrint('❌ Status code: \\${e.response?.statusCode}');
        debugPrint('❌ Request data: \\${e.requestOptions.data}');
        debugPrint('❌ Request headers: \\${e.requestOptions.headers}');

        // Provide more specific error messages based on status code
        if (e.response?.statusCode == 401) {
          throw Exception('Unauthorized: Please log in again');
        } else if (e.response?.statusCode == 403) {
          throw Exception(
            'Forbidden: You don\'t have permission to update family details',
          );
        } else if (e.response?.statusCode == 404) {
          throw Exception('Family not found');
        } else if (e.response?.statusCode == 400) {
          final errorMsg =
              e.response?.data['message'] ?? 'Invalid family data provided';
          throw Exception(errorMsg);
        } else {
          throw Exception('Network error: \\${e.message}');
        }
      }
      rethrow;
    }
  }

  /// Update family profile (e.g., name, avatar) - Alias for updateFamilyDetails
  Future<bool> updateFamilyProfile(Map<String, dynamic> familyData) async {
    return await updateFamilyDetails(familyData);
  }

  /// Delete user by userId (or current user if not provided)
  Future<bool> deleteUser({String? userId}) async {
    try {
      debugPrint('🗑️ FamilyApiService: Deleting user...');
      final response = await _dio.delete(
        '/users/deleteUser',
        data: userId != null ? {'userId': userId} : {},
      );
      if (response.statusCode == 200 &&
          (response.data['message'] != null || response.data['user'] != null)) {
        debugPrint('✅ FamilyApiService: User deleted');
        return true;
      } else {
        debugPrint(
          '❌ FamilyApiService: Failed to delete user: ${response.data}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ FamilyApiService: Error deleting user: $e');
      return false;
    }
  }

  /// Delete family by familyId
  Future<bool> deleteFamily({required String familyId}) async {
    try {
      debugPrint('🗑️ FamilyApiService: Deleting family...');
      final response = await _dio.delete(
        '/family/deleteFamily',
        data: {'familyId': familyId},
      );
      if (response.statusCode == 200 && (response.data['message'] != null)) {
        debugPrint('✅ FamilyApiService: Family deleted');
        return true;
      } else {
        debugPrint(
          '❌ FamilyApiService: Failed to delete family: ${response.data}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ FamilyApiService: Error deleting family: $e');
      return false;
    }
  }

  /// Get current user information
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      debugPrint('🔍 FamilyApiService: Getting current user...');
      final response = await _dio.get('/users/user');
      if (response.statusCode == 200) {
        final userData = response.data['user'] ?? response.data;
        debugPrint('✅ FamilyApiService: Current user retrieved');
        return userData;
      } else {
        debugPrint('❌ FamilyApiService: Failed to get current user');
        return null;
      }
    } catch (e) {
      debugPrint('❌ FamilyApiService: Error getting current user: $e');
      return null;
    }
  }

  /// Validate if user can edit family details (must be parent/admin)
  Future<bool> canEditFamilyDetails() async {
    try {
      final userData = await getCurrentUser();
      if (userData == null) return false;

      final role = userData['role']?.toString().toLowerCase() ?? '';
      return role == 'parent' || role == 'admin';
    } catch (e) {
      debugPrint(
        '❌ FamilyApiService: Error checking family edit permissions: $e',
      );
      return false;
    }
  }
}
