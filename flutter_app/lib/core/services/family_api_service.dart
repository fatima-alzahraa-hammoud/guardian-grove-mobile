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
}
