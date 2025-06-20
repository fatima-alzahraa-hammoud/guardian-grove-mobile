import 'package:flutter/foundation.dart';
import 'package:flutter_app/data/datasources/remote/leaderboard_remote.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/leaderboard_model.dart';
import '../../../core/services/storage_service.dart';

// Events
abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object> get props => [];
}

class LoadLeaderboard extends LeaderboardEvent {}

class RefreshLeaderboard extends LeaderboardEvent {}

// States
abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardFamily> families;
  final LeaderboardFamily? currentFamily;
  final bool isCurrentFamilyInTop20;

  const LeaderboardLoaded({
    required this.families,
    this.currentFamily,
    required this.isCurrentFamilyInTop20,
  });

  @override
  List<Object?> get props => [families, currentFamily, isCurrentFamilyInTop20];
}

class LeaderboardError extends LeaderboardState {
  final String message;

  const LeaderboardError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final LeaderboardRemoteDataSource leaderboardDataSource;

  LeaderboardBloc({required this.leaderboardDataSource})
    : super(LeaderboardInitial()) {
    on<LoadLeaderboard>(_onLoadLeaderboard);
    on<RefreshLeaderboard>(_onRefreshLeaderboard);
  }

  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    debugPrint('🏆 Loading leaderboard data...');
    emit(LeaderboardLoading());

    try {
      // Get leaderboard data from the backend
      final families = await leaderboardDataSource.getLeaderboard();

      // Find current user's family
      final currentUser = StorageService.getUser();
      final currentUserFamilyId = currentUser?.familyId;

      LeaderboardFamily? currentFamily;
      bool isCurrentFamilyInTop20 = false;

      if (currentUserFamilyId != null) {
        // Look for current family in the list
        try {
          currentFamily = families.firstWhere(
            (family) => family.familyId == currentUserFamilyId,
          );
          isCurrentFamilyInTop20 = currentFamily.rank <= 20;
          debugPrint(
            '✅ Current family found: ${currentFamily.familyName} (rank ${currentFamily.rank})',
          );
        } catch (e) {
          debugPrint('⚠️ Current family not found in leaderboard');
          isCurrentFamilyInTop20 = false;
        }
      }

      // Take only top 20 families for the main leaderboard
      final top20Families = families.take(20).toList();

      debugPrint(
        '✅ Leaderboard loaded successfully: ${top20Families.length} families',
      );
      debugPrint('📊 Current family in top 20: $isCurrentFamilyInTop20');

      emit(
        LeaderboardLoaded(
          families: top20Families,
          currentFamily: currentFamily,
          isCurrentFamilyInTop20: isCurrentFamilyInTop20,
        ),
      );
    } catch (e) {
      debugPrint('❌ Failed to load leaderboard: $e');
      emit(LeaderboardError('Failed to load leaderboard: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshLeaderboard(
    RefreshLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    debugPrint('🔄 Refreshing leaderboard data...');

    // Don't show loading state on refresh to avoid UI flicker
    try {
      // Get leaderboard data from the backend
      final families = await leaderboardDataSource.getLeaderboard();

      // Find current user's family
      final currentUser = StorageService.getUser();
      final currentUserFamilyId = currentUser?.familyId;

      LeaderboardFamily? currentFamily;
      bool isCurrentFamilyInTop20 = false;

      if (currentUserFamilyId != null) {
        // Look for current family in the list
        try {
          currentFamily = families.firstWhere(
            (family) => family.familyId == currentUserFamilyId,
          );
          isCurrentFamilyInTop20 = currentFamily.rank <= 20;
          debugPrint(
            '✅ Current family found: ${currentFamily.familyName} (rank ${currentFamily.rank})',
          );
        } catch (e) {
          debugPrint('⚠️ Current family not found in leaderboard');
          isCurrentFamilyInTop20 = false;
        }
      }

      // Take only top 20 families for the main leaderboard
      final top20Families = families.take(20).toList();

      debugPrint(
        '✅ Leaderboard refreshed successfully: ${top20Families.length} families',
      );
      debugPrint('📊 Current family in top 20: $isCurrentFamilyInTop20');

      emit(
        LeaderboardLoaded(
          families: top20Families,
          currentFamily: currentFamily,
          isCurrentFamilyInTop20: isCurrentFamilyInTop20,
        ),
      );
    } catch (e) {
      debugPrint('❌ Failed to refresh leaderboard: $e');
      emit(LeaderboardError('Failed to refresh leaderboard: ${e.toString()}'));
    }
  }
}
