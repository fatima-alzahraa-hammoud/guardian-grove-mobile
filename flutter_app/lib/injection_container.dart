import 'package:get_it/get_it.dart';
import 'core/network/api_client.dart';
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/datasources/remote/leaderboard_remote.dart';
import 'data/datasources/remote/home_remote_datasource.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/home/home_bloc.dart';
import 'presentation/bloc/bottom_nav/bottom_nav_cubit.dart';
import 'presentation/bloc/leaderboard/leaderboard_bloc.dart';

// Service locator instance
final sl = GetIt.instance;

Future<void> init() async {
  // Initialize core services first
  await _initCore();

  // Initialize data sources
  await _initDataSources();

  // Initialize BLoCs
  await _initBlocs();
}

Future<void> _initCore() async {
  // Register API Client as singleton
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
}

Future<void> _initDataSources() async {
  // Register Auth Remote Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );
  // Register Enhanced Leaderboard Remote Data Source with real family name fetching
  sl.registerLazySingleton<LeaderboardRemoteDataSource>(
    () => LeaderboardRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Register Home Remote Data Source
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(sl<ApiClient>()),
  );
}

Future<void> _initBlocs() async {
  // Register Auth BLoC
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl<AuthRemoteDataSource>()));

  // Register Home BLoC ⭐ ADDED
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(homeDataSource: sl<HomeRemoteDataSource>()),
  );

  // Register Bottom Navigation Cubit ⭐ ADDED
  sl.registerFactory<BottomNavCubit>(() => BottomNavCubit());

  // Register Leaderboard BLoC
  sl.registerFactory<LeaderboardBloc>(
    () => LeaderboardBloc(
      leaderboardDataSource: sl<LeaderboardRemoteDataSource>(),
    ),
  );
}
