import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/time_based_leaderboard_model.dart';
import '../../../data/datasources/remote/time_based_leaderboard_remote.dart';
import '../../../core/services/storage_service.dart';

// Events
abstract class TimeBasedLeaderboardEvent extends Equatable {
  const TimeBasedLeaderboardEvent();

  @override
  List<Object> get props => [];
}

class LoadTimeBasedLeaderboard extends TimeBasedLeaderboardEvent {}

class RefreshTimeBasedLeaderboard extends TimeBasedLeaderboardEvent {}

class ChangeTimeFrame extends TimeBasedLeaderboardEvent {
  final LeaderboardTimeFrame timeFrame;

  const ChangeTimeFrame(this.timeFrame);

  @override
  List<Object> get props => [timeFrame];
}

// States
abstract class TimeBasedLeaderboardState extends Equatable {
  const TimeBasedLeaderboardState();

  @override
  List<Object?> get props => [];
}

class TimeBasedLeaderboardInitial extends TimeBasedLeaderboardState {}

class TimeBasedLeaderboardLoading extends TimeBasedLeaderboardState {}

class TimeBasedLeaderboardLoaded extends TimeBasedLeaderboardState {
  final TimeBasedLeaderboardResponse leaderboardData;
  final LeaderboardTimeFrame currentTimeFrame;
  final List<LeaderboardFamily> currentLeaderboard;
  final LeaderboardFamily? currentFamily;
  final FamilyProgressStats? progressStats;
  final String motivationalMessage;
  final String rankingUpMessage;

  const TimeBasedLeaderboardLoaded({
    required this.leaderboardData,
    required this.currentTimeFrame,
    required this.currentLeaderboard,
    this.currentFamily,
    this.progressStats,
    this.motivationalMessage = '',
    this.rankingUpMessage = '',
  });

  @override
  List<Object?> get props => [
    leaderboardData,
    currentTimeFrame,
    currentLeaderboard,
    currentFamily,
    progressStats,
    motivationalMessage,
    rankingUpMessage,
  ];

  TimeBasedLeaderboardLoaded copyWith({
    TimeBasedLeaderboardResponse? leaderboardData,
    LeaderboardTimeFrame? currentTimeFrame,
    List<LeaderboardFamily>? currentLeaderboard,
    LeaderboardFamily? currentFamily,
    FamilyProgressStats? progressStats,
    String? motivationalMessage,
    String? rankingUpMessage,
  }) {
    return TimeBasedLeaderboardLoaded(
      leaderboardData: leaderboardData ?? this.leaderboardData,
      currentTimeFrame: currentTimeFrame ?? this.currentTimeFrame,
      currentLeaderboard: currentLeaderboard ?? this.currentLeaderboard,
      currentFamily: currentFamily ?? this.currentFamily,
      progressStats: progressStats ?? this.progressStats,
      motivationalMessage: motivationalMessage ?? this.motivationalMessage,
      rankingUpMessage: rankingUpMessage ?? this.rankingUpMessage,
    );
  }
}

class TimeBasedLeaderboardError extends TimeBasedLeaderboardState {
  final String message;

  const TimeBasedLeaderboardError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class TimeBasedLeaderboardBloc
    extends Bloc<TimeBasedLeaderboardEvent, TimeBasedLeaderboardState> {
  final TimeBasedLeaderboardRemoteDataSource _dataSource;

  TimeBasedLeaderboardBloc({
    required TimeBasedLeaderboardRemoteDataSource dataSource,
  }) : _dataSource = dataSource,
       super(TimeBasedLeaderboardInitial()) {
    on<LoadTimeBasedLeaderboard>(_onLoadTimeBasedLeaderboard);
    on<RefreshTimeBasedLeaderboard>(_onRefreshTimeBasedLeaderboard);
    on<ChangeTimeFrame>(_onChangeTimeFrame);
  }

  Future<void> _onLoadTimeBasedLeaderboard(
    LoadTimeBasedLeaderboard event,
    Emitter<TimeBasedLeaderboardState> emit,
  ) async {
    debugPrint('🏆 Loading time-based leaderboard data...');
    emit(TimeBasedLeaderboardLoading());

    try {
      // Load all time-based leaderboard data
      final leaderboardData = await _dataSource.getTimeBasedLeaderboard();

      // Start with daily view
      const initialTimeFrame = LeaderboardTimeFrame.daily;
      final currentLeaderboard = await _dataSource.getLeaderboardByTimeFrame(
        initialTimeFrame,
      );

      // Get current family data
      final currentFamily = _getCurrentFamilyFromData(
        leaderboardData,
        initialTimeFrame,
      );

      // Get progress stats
      final progressStats = await _dataSource.getFamilyProgressStats(
        initialTimeFrame,
      );

      // Generate motivational messages
      final messages = _generateMotivationalMessages(
        currentFamily,
        currentLeaderboard,
      );

      debugPrint(
        '✅ Time-based leaderboard loaded successfully: ${currentLeaderboard.length} families',
      );

      emit(
        TimeBasedLeaderboardLoaded(
          leaderboardData: leaderboardData,
          currentTimeFrame: initialTimeFrame,
          currentLeaderboard: currentLeaderboard,
          currentFamily: currentFamily,
          progressStats: progressStats,
          motivationalMessage: messages['motivational'] ?? '',
          rankingUpMessage: messages['rankingUp'] ?? '',
        ),
      );
    } catch (e) {
      debugPrint('❌ Failed to load time-based leaderboard: $e');
      emit(
        TimeBasedLeaderboardError(
          'Failed to load leaderboard: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onRefreshTimeBasedLeaderboard(
    RefreshTimeBasedLeaderboard event,
    Emitter<TimeBasedLeaderboardState> emit,
  ) async {
    debugPrint('🔄 Refreshing time-based leaderboard data...');

    final currentState = state;
    if (currentState is! TimeBasedLeaderboardLoaded) return;

    try {
      // Refresh all data
      final leaderboardData = await _dataSource.getTimeBasedLeaderboard();
      final currentLeaderboard = await _dataSource.getLeaderboardByTimeFrame(
        currentState.currentTimeFrame,
      );
      final currentFamily = _getCurrentFamilyFromData(
        leaderboardData,
        currentState.currentTimeFrame,
      );
      final progressStats = await _dataSource.getFamilyProgressStats(
        currentState.currentTimeFrame,
      );
      final messages = _generateMotivationalMessages(
        currentFamily,
        currentLeaderboard,
      );

      debugPrint(
        '✅ Time-based leaderboard refreshed successfully: ${currentLeaderboard.length} families',
      );

      emit(
        currentState.copyWith(
          leaderboardData: leaderboardData,
          currentLeaderboard: currentLeaderboard,
          currentFamily: currentFamily,
          progressStats: progressStats,
          motivationalMessage: messages['motivational'] ?? '',
          rankingUpMessage: messages['rankingUp'] ?? '',
        ),
      );
    } catch (e) {
      debugPrint('❌ Failed to refresh time-based leaderboard: $e');
      emit(
        TimeBasedLeaderboardError(
          'Failed to refresh leaderboard: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onChangeTimeFrame(
    ChangeTimeFrame event,
    Emitter<TimeBasedLeaderboardState> emit,
  ) async {
    debugPrint('🔄 Changing time frame to: ${event.timeFrame.displayName}');

    final currentState = state;
    if (currentState is! TimeBasedLeaderboardLoaded) return;

    try {
      // Get leaderboard for new time frame
      final currentLeaderboard = await _dataSource.getLeaderboardByTimeFrame(
        event.timeFrame,
      );
      final currentFamily = _getCurrentFamilyFromData(
        currentState.leaderboardData,
        event.timeFrame,
      );
      final progressStats = await _dataSource.getFamilyProgressStats(
        event.timeFrame,
      );
      final messages = _generateMotivationalMessages(
        currentFamily,
        currentLeaderboard,
      );

      debugPrint(
        '✅ Time frame changed to ${event.timeFrame.displayName}: ${currentLeaderboard.length} families',
      );

      emit(
        currentState.copyWith(
          currentTimeFrame: event.timeFrame,
          currentLeaderboard: currentLeaderboard,
          currentFamily: currentFamily,
          progressStats: progressStats,
          motivationalMessage: messages['motivational'] ?? '',
          rankingUpMessage: messages['rankingUp'] ?? '',
        ),
      );
    } catch (e) {
      debugPrint('❌ Failed to change time frame: $e');
      emit(
        TimeBasedLeaderboardError(
          'Failed to change time frame: ${e.toString()}',
        ),
      );
    }
  }

  LeaderboardFamily? _getCurrentFamilyFromData(
    TimeBasedLeaderboardResponse data,
    LeaderboardTimeFrame timeFrame,
  ) {
    final user = StorageService.getUser();
    final familyId = user?.familyId;

    if (familyId == null) return null;

    switch (timeFrame) {
      case LeaderboardTimeFrame.daily:
        return data.dailyFamilyRank;
      case LeaderboardTimeFrame.weekly:
        return data.weeklyFamilyRank;
      case LeaderboardTimeFrame.monthly:
        return data.monthlyFamilyRank;
      case LeaderboardTimeFrame.yearly:
        return data.yearlyFamilyRank;
    }
  }

  Map<String, String> _generateMotivationalMessages(
    LeaderboardFamily? currentFamily,
    List<LeaderboardFamily> leaderboard,
  ) {
    if (currentFamily == null) {
      return {
        'motivational':
            'Complete tasks and earn stars to see your family rank! 🌟',
        'rankingUp': 'Start completing family tasks to join the leaderboard!',
      };
    }

    if (currentFamily.rank == 1) {
      return {
        'motivational':
            'Keep it up and stay on top! You can do it—keep completing your tasks and stay there! 🌟',
        'rankingUp': 'You\'ve reached Rank 1!',
      };
    }

    // Find the family above current rank
    LeaderboardFamily? targetFamily;
    String motivationalMessage =
        'You\'re doing great, but there\'s always room to grow! Keep going! 🚀';

    if (currentFamily.rank >= 10) {
      targetFamily =
          leaderboard.where((family) => family.rank == 10).firstOrNull;
      motivationalMessage =
          'You\'re doing great, but there\'s always room to grow! Keep going! 🚀';
    } else {
      targetFamily =
          leaderboard
              .where((family) => family.rank == currentFamily.rank - 1)
              .firstOrNull;
      motivationalMessage =
          'You\'re so close to the top! Keep up the great work! 💪';
    }

    String rankingUpMessage =
        'You\'re so close to the top! Keep up the great work! 💪';

    if (targetFamily != null) {
      final starsNeeded = targetFamily.stars - currentFamily.stars;
      final tasksNeeded = targetFamily.tasks - currentFamily.tasks;

      if (starsNeeded > 0 || tasksNeeded > 0) {
        final parts = <String>[];
        if (starsNeeded > 0) parts.add('$starsNeeded more stars');
        if (tasksNeeded > 0) parts.add('$tasksNeeded more tasks');

        rankingUpMessage =
            'You need ${parts.join(' and ')} to reach Rank ${currentFamily.rank - 1}. Keep pushing!';
      }
    }

    return {'motivational': motivationalMessage, 'rankingUp': rankingUpMessage};
  }
}
