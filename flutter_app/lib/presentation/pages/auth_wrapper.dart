import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import 'auth/login_page.dart';
import 'main/main_app.dart'; // ⭐ NEW IMPORT

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const MainApp(); // ⭐ UPDATED: Use MainApp instead of HomePage
        } else if (state is AuthLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F9FE),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0EA5E9),
              ),
            ),
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}