import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_colors.dart';
import '../injection_container.dart' as di;
import '../presentation/bloc/auth/auth_bloc.dart';
import '../presentation/bloc/auth/auth_event.dart';
import '../presentation/bloc/auth/auth_state.dart';
import '../presentation/pages/splash/splash_screen.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/main/main_app.dart';

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
        home: const SplashScreenWrapper(),
      ),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // No navigation here; handled in BlocListener
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthAuthenticated ||
            state is AuthNewRegistration ||
            state is AuthUnauthenticated) {
          final navigator = Navigator.of(context);
          await Future.delayed(const Duration(seconds: 2)); // Splash duration
          if (!mounted) return;
          // Use captured navigator
          if (!_navigated) {
            _navigated = true;
            if (state is AuthAuthenticated || state is AuthNewRegistration) {
              navigator.pushReplacement(
                MaterialPageRoute(builder: (_) => const MainApp()),
              );
            } else if (state is AuthUnauthenticated) {
              navigator.pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }
          }
        }
      },
      child: const SplashScreen(),
    );
  }
}
