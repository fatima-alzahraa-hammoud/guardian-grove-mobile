import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/pages/auth_wrapper.dart';
import 'package:flutter_app/presentation/pages/home/home_subScreens/store.dart'; // Import the StoreScreen from the correct path
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_colors.dart';
import '../injection_container.dart' as di;
import '../presentation/bloc/auth/auth_bloc.dart';
import '../presentation/bloc/auth/auth_event.dart';

class GuardianGroveApp extends StatelessWidget {
  const GuardianGroveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) {
            final authBloc = di.sl<AuthBloc>();
            // Check authentication status on app startup
            authBloc.add(CheckAuthStatusEvent());
            return authBloc;
          },
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryTeal,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Comic Sans MS', // Child-friendly font
          // AppBar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primaryTeal,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),

          // Button themes
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),

          // Card theme
          cardTheme: CardThemeData(
            color: AppColors.cardBackground,
            elevation: 8,
            shadowColor: AppColors.cardShadow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          // Input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: AppColors.primaryTeal,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
        routes: {
          '/store': (context) => const StoreScreen(),
          // Add other routes here if needed
        },
        home: const AuthWrapper(),
      ),
    );
  }
}
