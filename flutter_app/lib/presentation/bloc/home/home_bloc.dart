import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

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

// States
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String userName;
  final String avatar;
  final int stars;
  final int coins;
  final int rank;
  final double progressToNextLevel;
  final int awards;

  const HomeLoaded({
    required this.userName,
    required this.avatar,
    required this.stars,
    required this.coins,
    required this.rank,
    required this.progressToNextLevel,
    required this.awards,
  });

  @override
  List<Object> get props => [
    userName,
    avatar,
    stars,
    coins,
    rank,
    progressToNextLevel,
    awards,
  ];
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

// HomeBloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
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
        const HomeLoaded(
          userName: 'Fatima A.',
          avatar: '',
          stars: 250,
          coins: 120,
          rank: 2,
          progressToNextLevel: 0.7,
          awards: 15,
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

  void _onNavigateToBondingActivities(NavigateToBondingActivities event, Emitter<HomeState> emit) {
    emit(const NavigationRequested('/bonding-activities'));
  }

  void _onNavigateToExploreLearn(NavigateToExploreLearn event, Emitter<HomeState> emit) {
    emit(const NavigationRequested('/explore-learn'));
  }

  void _onNavigateToCalendar(NavigateToCalendar event, Emitter<HomeState> emit) {
    emit(const NavigationRequested('/calendar'));
  }

  void _onNavigateToFamilyTree(NavigateToFamilyTree event, Emitter<HomeState> emit) {
    emit(const NavigationRequested('/family-tree'));
  }

  void _onNavigateToFamilyJournal(NavigateToFamilyJournal event, Emitter<HomeState> emit) {
    emit(const NavigationRequested('/family-journal'));
  }

  void _onNavigateToAchievements(NavigateToAchievements event, Emitter<HomeState> emit) {
    emit(const NavigationRequested('/achievements'));
  }

  void _onNavigateToStore(NavigateToStore event, Emitter<HomeState> emit) {
    emit(const NavigationRequested('/store'));
  }

  void _onNavigateToGoalsAdventures(NavigateToGoalsAdventures event, Emitter<HomeState> emit) {
    emit(const NavigationRequested('/goals-adventures'));
  }

  void _onNavigateToFunZone(NavigateToFunZone event, Emitter<HomeState> emit) {
    emit(const NavigationRequested('/fun-zone'));
  }

  void _onNavigateToChildTracking(NavigateToChildTracking event, Emitter<HomeState> emit) {
    emit(const NavigationRequested('/child-tracking'));
  }

  void _onNavigateToTasksProgress(NavigateToTasksProgress event, Emitter<HomeState> emit) {
    emit(const NavigationRequested('/tasks-progress'));
  }

  void _onNavigateToAchievementsProgress(NavigateToAchievementsProgress event, Emitter<HomeState> emit) {
    emit(const NavigationRequested('/achievements-progress'));
  }

  void _onNavigateToMagicGarden(NavigateToMagicGarden event, Emitter<HomeState> emit) {
    emit(const NavigationRequested('/magic-garden'));
  }

  void _onNavigateToAIAssistant(NavigateToAIAssistant event, Emitter<HomeState> emit) {
    emit(const NavigationRequested('/ai-assistant'));
  }
}