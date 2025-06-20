import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import 'auth/login_page.dart';
import 'auth/add_member_choice_dialog.dart';
import 'main/main_app.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const MainApp();
        } else if (state is AuthNewRegistration) {
          // Show the add member dialog for new registrations
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const AddMemberChoiceDialog(),
            );
          });
          return const MainApp();
        } else if (state is AuthLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F9FE),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
            ),
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
