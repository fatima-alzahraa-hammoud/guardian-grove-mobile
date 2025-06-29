import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/data/models/time_based_leaderboard_model.dart';
import 'package:flutter_app/presentation/bloc/leaderboard/time_based_leaderboard_bloc.dart';

void main() {
  group('Time-Based Leaderboard Integration Tests', () {
    test('LeaderboardTimeFrame enum has correct values', () {
      expect(LeaderboardTimeFrame.daily.displayName, 'Daily Stars');
      expect(LeaderboardTimeFrame.weekly.displayName, 'Weekly Champions');
      expect(LeaderboardTimeFrame.monthly.displayName, 'Monthly Achievers');
      expect(LeaderboardTimeFrame.yearly.displayName, 'Yearly Legends');
    });

    test('FamilyProgressStats calculates progress correctly', () {
      final stats = FamilyProgressStats(
        totalTasks: 10,
        completedTasks: 8,
        totalGoals: 5,
        completedGoals: 3,
        totalAchievements: 20,
        unlockedAchievements: 15,
      );

      expect(stats.taskProgress, 0.8);
      expect(stats.goalProgress, 0.6);
      expect(stats.achievementProgress, 0.75);
    });

    test('TimeBasedLeaderboardResponse can be created from JSON', () {
      final json = {
        'dailyTop10': [],
        'weeklyTop10': [],
        'monthlyTop10': [],
        'yearlyTop10': [],
      };

      final response = TimeBasedLeaderboardResponse.fromJson(json);

      expect(response.dailyTop10, isEmpty);
      expect(response.weeklyTop10, isEmpty);
      expect(response.monthlyTop10, isEmpty);
      expect(response.yearlyTop10, isEmpty);
    });

    test('ChangeTimeFrame event is created correctly', () {
      const event = ChangeTimeFrame(LeaderboardTimeFrame.weekly);
      expect(event.timeFrame, LeaderboardTimeFrame.weekly);
      expect(event.props, [LeaderboardTimeFrame.weekly]);
    });
  });
}
