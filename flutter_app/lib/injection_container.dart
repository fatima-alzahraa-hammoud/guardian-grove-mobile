import 'package:get_it/get_it.dart';
import 'core/network/api_client.dart';
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/home/home_bloc.dart';
import 'presentation/bloc/bottom_nav/bottom_nav_cubit.dart';

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
}

Future<void> _initBlocs() async {
  // Register Auth BLoC
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl<AuthRemoteDataSource>()),
  );
  
  // Register Home BLoC ⭐ ADDED
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(),
  );
  
  // Register Bottom Navigation Cubit ⭐ ADDED
  sl.registerFactory<BottomNavCubit>(
    () => BottomNavCubit(),
  );
}