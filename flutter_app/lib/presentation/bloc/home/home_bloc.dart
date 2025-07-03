import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/home_model.dart';
import '../../../data/datasources/remote/home_remote_datasource.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/family_model.dart' show FamilyMember;
import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

// Navigation Events
class NavigateToProfile extends HomeEvent {}

class NavigateToNotes extends HomeEvent {}

class NavigateToBondingActivities extends HomeEvent {}

class NavigateToExploreLearn extends HomeEvent {}

class NavigateToCalendar extends HomeEvent {}

class NavigateToFamilyTree extends HomeEvent {}

class NavigateToFamilyJournal extends HomeEvent {}

class NavigateToAchievements extends HomeEvent {}

class NavigateToStore extends HomeEvent {}

class NavigateToGoalsAdventures extends HomeEvent {}

class NavigateToFunZone extends HomeEvent {}

class NavigateToChildTracking extends HomeEvent {}

class NavigateToTasksProgress extends HomeEvent {}

class NavigateToAchievementsProgress extends HomeEvent {}

class NavigateToMagicGarden extends HomeEvent {}

class HomeLoadedEvent extends HomeEvent {}

// New data loading events
class LoadHomeData extends HomeEvent {}

class RefreshHomeData extends HomeEvent {}

class InviteFamilyMember extends HomeEvent {
  final String email;
  const InviteFamilyMember(this.email);
  @override
  List<Object> get props => [email];
}

class RefreshDailyMessage extends HomeEvent {}

// States
abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final HomeData homeData;

  const HomeLoaded({required this.homeData});

  // Convenience getters for backward compatibility
  String get userName => homeData.user.name;
  String get avatar => homeData.user.avatar;
  int get stars => homeData.familyStats.totalStars;
  int get coins => 0; // Will be updated with real data
  int get rank => 0; // Will be updated with real data
  double get progressToNextLevel => 0.7;
  int get awards => 15;

  // Family data getters
  String get familyName => homeData.familyName;
  String get familyAvatar => homeData.familyAvatar;
  String get familyEmail => homeData.email;
  DateTime get familyCreatedAt => homeData.createdAt;
  List<dynamic> get familyNotifications => homeData.notifications;
  List<dynamic> get familyGoals => homeData.goals;
  List<dynamic> get familyAchievements => homeData.achievements;
  List<dynamic> get familySharedStories => homeData.sharedStories;

  @override
  List<Object> get props => [homeData];
}

class NavigationRequested extends HomeState {
  final String routeName;
  const NavigationRequested(this.routeName);
  @override
  List<Object> get props => [routeName];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object> get props => [message];
}

class InvitationSent extends HomeState {
  final String message;
  const InvitationSent(this.message);
  @override
  List<Object> get props => [message];
}

// HomeBloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRemoteDataSource? homeDataSource;

  HomeBloc({this.homeDataSource}) : super(HomeInitial()) {
    // Data loading events
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<InviteFamilyMember>(_onInviteFamilyMember);
    on<RefreshDailyMessage>(_onRefreshDailyMessage);

    // Navigation events
    on<NavigateToProfile>(_onNavigateToProfile);
    on<NavigateToNotes>(_onNavigateToNotes);
    on<NavigateToBondingActivities>(_onNavigateToBondingActivities);
    on<NavigateToExploreLearn>(_onNavigateToExploreLearn);
    on<NavigateToCalendar>(_onNavigateToCalendar);
    on<NavigateToFamilyTree>(_onNavigateToFamilyTree);
    on<NavigateToFamilyJournal>(_onNavigateToFamilyJournal);
    on<NavigateToAchievements>(_onNavigateToAchievements);
    on<NavigateToStore>(_onNavigateToStore);
    on<NavigateToGoalsAdventures>(_onNavigateToGoalsAdventures);
    on<NavigateToFunZone>(_onNavigateToFunZone);
    on<NavigateToChildTracking>(_onNavigateToChildTracking);
    on<NavigateToTasksProgress>(_onNavigateToTasksProgress);
    on<NavigateToAchievementsProgress>(_onNavigateToAchievementsProgress);
    on<NavigateToMagicGarden>(_onNavigateToMagicGarden);

    // Mock data event
    on<HomeLoadedEvent>((event, emit) {
      emit(
        HomeLoaded(
          homeData: HomeData(
            id: 'family-1',
            user: UserProfile(
              id: 'user-1',
              name: 'Fatima A.',
              email: 'fatima@example.com',
              avatar: '',
              createdAt: DateTime.now(),
            ),
            familyStats: FamilyStats(
              totalStars: 250,
              tasks: 20,
              stars: Stars(daily: 10, weekly: 50, monthly: 100, yearly: 250),
              taskCounts: TaskCounts(
                daily: 2,
                weekly: 10,
                monthly: 18,
                yearly: 20,
              ),
            ),
            quickActions: [],
            dailyMessage: DailyMessage(
              id: 'msg-1',
              message:
                  'Every day is a new adventure waiting to unfold with your family!',
              category: 'Inspiration',
              date: DateTime.now(),
            ),
            familyMembers: [],
            familyName: 'Rmaity',
            email: 'fatima@example.com',
            createdAt: DateTime.now(),
            familyAvatar: 'assets/images/avatars/family/avatar1.png',
            notifications: [],
            goals: [],
            achievements: [],
            sharedStories: [],
          ),
        ),
      );
    });
  }

  // Navigation event handlers
  void _onNavigateToProfile(NavigateToProfile event, Emitter<HomeState> emit) {
    emit(const NavigationRequested('/profile'));
  }

  void _onNavigateToNotes(NavigateToNotes event, Emitter<HomeState> emit) {
    emit(const NavigationRequested('/notes'));
  }

  void _onNavigateToBondingActivities(
    NavigateToBondingActivities event,
    Emitter<HomeState> emit,
  ) {
    emit(const NavigationRequested('/bonding-activities'));
  }

  void _onNavigateToExploreLearn(
    NavigateToExploreLearn event,
    Emitter<HomeState> emit,
  ) {
    emit(const NavigationRequested('/explore-learn'));
  }

  void _onNavigateToCalendar(
    NavigateToCalendar event,
    Emitter<HomeState> emit,
  ) {
    emit(const NavigationRequested('/calendar'));
  }

  void _onNavigateToFamilyTree(
    NavigateToFamilyTree event,
    Emitter<HomeState> emit,
  ) {
    emit(const NavigationRequested('/family-tree'));
  }

  void _onNavigateToFamilyJournal(
    NavigateToFamilyJournal event,
    Emitter<HomeState> emit,
  ) {
    emit(const NavigationRequested('/family-journal'));
  }

  void _onNavigateToAchievements(
    NavigateToAchievements event,
    Emitter<HomeState> emit,
  ) {
    emit(const NavigationRequested('/achievements'));
  }

  void _onNavigateToStore(NavigateToStore event, Emitter<HomeState> emit) {
    emit(const NavigationRequested('/store'));
  }

  void _onNavigateToGoalsAdventures(
    NavigateToGoalsAdventures event,
    Emitter<HomeState> emit,
  ) {
    emit(const NavigationRequested('/goals-adventures'));
  }

  void _onNavigateToFunZone(NavigateToFunZone event, Emitter<HomeState> emit) {
    emit(const NavigationRequested('/fun-zone'));
  }

  void _onNavigateToChildTracking(
    NavigateToChildTracking event,
    Emitter<HomeState> emit,
  ) {
    emit(const NavigationRequested('/child-tracking'));
  }

  void _onNavigateToTasksProgress(
    NavigateToTasksProgress event,
    Emitter<HomeState> emit,
  ) {
    emit(const NavigationRequested('/tasks-progress'));
  }

  void _onNavigateToAchievementsProgress(
    NavigateToAchievementsProgress event,
    Emitter<HomeState> emit,
  ) {
    emit(const NavigationRequested('/achievements-progress'));
  }

  void _onNavigateToMagicGarden(
    NavigateToMagicGarden event,
    Emitter<HomeState> emit,
  ) {
    emit(const NavigationRequested('/magic-garden'));
  }

  // FIXED: Data loading using existing working API pattern
  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      // Use the same working API pattern from HomeScreen
      final homeData = await _loadFamilyDataDirect();
      debugPrint('🔍 HomeData loaded: ${homeData.familyName}');
      debugPrint('🔍 Family members: ${homeData.familyMembers.length}');
      debugPrint('🔍 Family stars: ${homeData.familyStats.totalStars}');
      emit(HomeLoaded(homeData: homeData));
    } catch (e) {
      debugPrint('❌ HomeBloc: Error loading home data: $e');
      emit(HomeError(e.toString()));
    }
  }

  // NEW: Direct API call method using working pattern from HomeScreen
  Future<HomeData> _loadFamilyDataDirect() async {
    final dio = Dio();
    final token = StorageService.getToken();
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
    dio.options.baseUrl = AppConstants.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    debugPrint('🔍 HomeBloc: Fetching family data...');

    // Step 1: Get user info
    final userResponse = await dio.get('/users/user');
    if (userResponse.statusCode != 200) {
      throw Exception('Failed to get user info');
    }

    final userData = userResponse.data['user'] ?? userResponse.data;
    final familyId = userData['familyId'];

    if (familyId == null) {
      throw Exception('No family ID found');
    }

    debugPrint('👨‍👩‍👧‍👦 HomeBloc: Family ID: $familyId');

    // Step 2: Get family info
    Response? familyResponse;
    try {
      familyResponse = await dio.post(
        '/family/getFamily',
        data: {'familyId': familyId},
      );
    } catch (e) {
      debugPrint('❌ HomeBloc: Failed to get family info: $e');
      throw Exception('Failed to get family info: $e');
    }

    if (familyResponse.statusCode != 200) {
      throw Exception('Failed to get family info');
    }

    final familyData = familyResponse.data['family'];
    if (familyData == null) {
      throw Exception('No family data found');
    }

    // Step 3: Get family members
    List<FamilyMember> familyMembers = [];
    try {
      debugPrint('🔄 HomeBloc: Fetching family members...');
      final membersResponse = await dio.post(
        '/family/FamilyMembers',
        data: {'familyId': familyId},
      );

      if (membersResponse.statusCode == 200) {
        final responseData = membersResponse.data;
        List<dynamic> membersData = [];

        // Handle different response structures
        if (responseData['familyWithMembers'] != null) {
          membersData = responseData['familyWithMembers']['members'] ?? [];
        } else if (responseData['members'] != null) {
          membersData = responseData['members'];
        } else if (responseData is List) {
          membersData = responseData;
        }

        familyMembers =
            membersData.map((memberData) {
              return FamilyMember(
                id:
                    memberData['_id']?.toString() ??
                    memberData['id']?.toString() ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                name: memberData['name']?.toString() ?? 'Unknown Member',
                role: memberData['role']?.toString() ?? 'member',
                gender: memberData['gender']?.toString() ?? '',
                avatar: memberData['avatar']?.toString() ?? '',
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
          '✅ HomeBloc: Successfully loaded ${familyMembers.length} family members',
        );
      }
    } catch (e) {
      debugPrint('⚠️ HomeBloc: Failed to load family members: $e');
      // Continue without family members rather than failing completely
    }

    // Step 4: Build HomeData with real data
    final currentUser = StorageService.getUser();

    // Debug family avatar data
    debugPrint(
      '🖼️ HomeBloc: Family avatar from API: ${familyData['familyAvatar']}',
    );
    debugPrint(
      '🖼️ HomeBloc: Family avatar type: ${familyData['familyAvatar']?.runtimeType}',
    );

    return HomeData(
      id: familyData['_id']?.toString() ?? 'unknown',
      user: UserProfile(
        id: userData['_id']?.toString() ?? 'unknown',
        name: userData['name']?.toString() ?? currentUser?.name ?? 'User',
        email: userData['email']?.toString() ?? currentUser?.email ?? '',
        avatar: userData['avatar']?.toString() ?? currentUser?.avatar ?? '',
        createdAt:
            userData['createdAt'] != null
                ? DateTime.tryParse(userData['createdAt'].toString()) ??
                    DateTime.now()
                : DateTime.now(),
      ),
      familyStats: FamilyStats(
        totalStars: familyData['totalStars']?.toInt() ?? 0,
        tasks: familyData['totalTasks']?.toInt() ?? 0,
        stars: Stars(
          daily: familyData['dailyStars']?.toInt() ?? 0,
          weekly: familyData['weeklyStars']?.toInt() ?? 0,
          monthly: familyData['monthlyStars']?.toInt() ?? 0,
          yearly: familyData['totalStars']?.toInt() ?? 0,
        ),
        taskCounts: TaskCounts(
          daily: familyData['dailyTasks']?.toInt() ?? 0,
          weekly: familyData['weeklyTasks']?.toInt() ?? 0,
          monthly: familyData['monthlyTasks']?.toInt() ?? 0,
          yearly: familyData['totalTasks']?.toInt() ?? 0,
        ),
      ),
      quickActions: [], // You can populate this with real data if available
      dailyMessage: DailyMessage(
        id: 'msg-1',
        message:
            familyData['dailyMessage']?.toString() ??
            'Every day is a new adventure waiting to unfold with your family!',
        category: 'Inspiration',
        date: DateTime.now(),
      ),
      familyMembers: familyMembers,
      familyName: familyData['familyName']?.toString() ?? 'Your Family',
      email:
          familyData['email']?.toString() ??
          userData['email']?.toString() ??
          '',
      createdAt:
          familyData['createdAt'] != null
              ? DateTime.tryParse(familyData['createdAt'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      familyAvatar: familyData['familyAvatar']?.toString() ?? '',
      notifications: familyData['notifications'] ?? [],
      goals: familyData['goals'] ?? [],
      achievements: familyData['achievements'] ?? [],
      sharedStories: familyData['sharedStories'] ?? [],
    );
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    try {
      if (homeDataSource != null) {
        final homeData = await homeDataSource!.getHomeData();
        emit(HomeLoaded(homeData: homeData));
      } else {
        // Fallback to direct API call
        final homeData = await _loadFamilyDataDirect();
        emit(HomeLoaded(homeData: homeData));
      }
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onInviteFamilyMember(
    InviteFamilyMember event,
    Emitter<HomeState> emit,
  ) async {
    try {
      if (homeDataSource != null) {
        await homeDataSource!.inviteFamilyMember(event.email);
        emit(InvitationSent('Invitation sent successfully!'));

        // Refresh home data to update family members
        final homeData = await homeDataSource!.getHomeData();
        emit(HomeLoaded(homeData: homeData));
      }
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onRefreshDailyMessage(
    RefreshDailyMessage event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      try {
        if (homeDataSource != null) {
          final dailyMessage = await homeDataSource!.refreshDailyMessage();
          final currentState = state as HomeLoaded;
          final updatedHomeData = HomeData(
            id: currentState.homeData.id,
            user: currentState.homeData.user,
            familyStats: currentState.homeData.familyStats,
            quickActions: currentState.homeData.quickActions,
            dailyMessage: dailyMessage,
            familyMembers: currentState.homeData.familyMembers,
            familyName: currentState.homeData.familyName,
            email: currentState.homeData.email,
            createdAt: currentState.homeData.createdAt,
            familyAvatar: currentState.homeData.familyAvatar,
            notifications: currentState.homeData.notifications,
            goals: currentState.homeData.goals,
            achievements: currentState.homeData.achievements,
            sharedStories: currentState.homeData.sharedStories,
          );
          emit(HomeLoaded(homeData: updatedHomeData));
        }
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    }
  }
}
