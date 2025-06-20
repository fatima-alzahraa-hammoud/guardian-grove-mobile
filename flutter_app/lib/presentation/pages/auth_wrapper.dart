import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/app_colors.dart';
import 'package:flutter_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter_app/presentation/bloc/auth/auth_event.dart';
import 'package:flutter_app/presentation/bloc/auth/auth_state.dart';
import 'package:flutter_app/presentation/pages/auth/login_page.dart';
import 'package:flutter_app/presentation/pages/home/home_page.dart';
import 'package:flutter_app/presentation/pages/splash/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Start splash timer
    _startSplashTimer();
    // Check auth status
    context.read<AuthBloc>().add(CheckAuthStatusEvent());
  }

  void _startSplashTimer() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print(
          '🎧 AuthWrapper Listener - State changed to: ${state.runtimeType}',
        );

        if (state is AuthError) {
          print('🎧 AuthWrapper Listener - Showing error: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          print('🏠 AuthWrapper - Current state: ${state.runtimeType}');
          print('🏠 AuthWrapper - Show splash: $_showSplash');

          // Show splash screen for first 2.5 seconds
          if (_showSplash) {
            print('🏠 AuthWrapper - Showing SplashScreen');
            return const SplashScreen();
          }

          // After splash, show appropriate page based on auth state
          if (state is AuthAuthenticated) {
            print('🏠 AuthWrapper - User is authenticated, showing HomePage');
            return const HomePage();
          } else {
            print('🏠 AuthWrapper - User not authenticated, showing LoginPage');
            return const LoginPage();
          }
        },
      ),
    );
  }
}
