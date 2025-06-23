import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/home_model.dart';
import '../../../data/datasources/remote/home_remote_datasource.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/family_model.dart' show FamilyMember;

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

class NavigateToAIAssistant extends HomeEvent {}

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
  // coins and rank are not in the new FamilyStats model, so remove or mock as needed
  int get coins => 0;
  int get rank => 0;
  double get progressToNextLevel => 0.7; // Mock for now
  int get awards => 15; // Mock for now

  // Example: expose more family values for use in profile or elsewhere
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
    on<NavigateToAIAssistant>(_onNavigateToAIAssistant);
    // Data loading event
    on<HomeLoadedEvent>((event, emit) {
      emit(
        HomeLoaded(
          homeData: HomeData(
            id: 'family-1', // mock id for demo event
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

  void _onNavigateToAIAssistant(
    NavigateToAIAssistant event,
    Emitter<HomeState> emit,
  ) {
    emit(const NavigationRequested('/ai-assistant'));
  }

  // Data loading event handlers
  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      if (homeDataSource != null) {
        final homeData = await homeDataSource!.getHomeData();
        emit(HomeLoaded(homeData: homeData));
      } else {
        // Fallback to real user data if no data source
        final currentUser = StorageService.getUser();

        if (currentUser != null) {
          emit(
            HomeLoaded(
              homeData: HomeData(
                id: currentUser.id, // use user id as fallback for family id
                user: UserProfile(
                  id: currentUser.id,
                  name: currentUser.name,
                  email: currentUser.email,
                  avatar: currentUser.avatar,
                  createdAt: currentUser.memberSince,
                ),
                familyStats: FamilyStats(
                  totalStars: currentUser.stars,
                  tasks: 0,
                  stars: Stars(daily: 0, weekly: 0, monthly: 0, yearly: 0),
                  taskCounts: TaskCounts(
                    daily: 0,
                    weekly: 0,
                    monthly: 0,
                    yearly: 0,
                  ),
                ),
                quickActions: [],
                dailyMessage: DailyMessage(
                  id: 'msg-1',
                  message:
                      currentUser.dailyMessage.isNotEmpty
                          ? currentUser.dailyMessage
                          : 'Every day is a new adventure waiting to unfold with your family!',
                  category: 'Inspiration',
                  date: DateTime.now(),
                ),
                familyMembers: [
                  FamilyMember(
                    id: currentUser.id,
                    name: currentUser.name,
                    avatar: currentUser.avatar,
                    role: currentUser.role,
                    gender: currentUser.gender,
                  ),
                ],
                familyName: 'Your Family',
                email: currentUser.email,
                createdAt: currentUser.memberSince,
                familyAvatar: '',
                notifications: [],
                goals: [],
                achievements: [],
                sharedStories: [],
              ),
            ),
          );
        } else {
          // Ultimate fallback for guest users
          emit(
            HomeLoaded(
              homeData: HomeData(
                id: 'temp-user', // fallback id for guest
                user: UserProfile(
                  id: 'temp-user',
                  name: 'Guest User',
                  email: 'guest@example.com',
                  avatar: '',
                  createdAt: DateTime.now(),
                ),
                familyStats: FamilyStats(
                  totalStars: 0,
                  tasks: 0,
                  stars: Stars(daily: 0, weekly: 0, monthly: 0, yearly: 0),
                  taskCounts: TaskCounts(
                    daily: 0,
                    weekly: 0,
                    monthly: 0,
                    yearly: 0,
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
                familyName: 'Your Family',
                email: 'guest@example.com',
                createdAt: DateTime.now(),
                familyAvatar: '',
                notifications: [],
                goals: [],
                achievements: [],
                sharedStories: [],
              ),
            ),
          );
        }
      }
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    try {
      if (homeDataSource != null) {
        final homeData = await homeDataSource!.getHomeData();
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
            id: currentState.homeData.id, // preserve id
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
