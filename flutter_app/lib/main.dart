import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app.dart';
import 'core/network/api_client.dart';
import 'core/services/storage_service.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  await StorageService.init();

  // Initialize dependency injection
  await di.init();
  // Initialize API client
  ApiClient().init();

  // Test backend connectivity (optional - for debugging)
  try {
    final isConnected = await ApiClient().testConnection();
    print('Backend connection status: ${isConnected ? "Connected" : "Failed"}');
  } catch (e) {
    print('Backend connection test error: $e');
  }

  // Set up BLoC observer for debugging
  Bloc.observer = SimpleBlocObserver();

  runApp(const GuardianGroveApp());
}

// Simple BlocObserver for debugging
class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint('${bloc.runtimeType} $error $stackTrace');
  }
}
