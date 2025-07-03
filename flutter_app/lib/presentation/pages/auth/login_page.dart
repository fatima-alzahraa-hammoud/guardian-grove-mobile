import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/password_change_dialog.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    debugPrint('🔘 Login button pressed');
    if (_formKey.currentState!.validate()) {
      debugPrint('✅ Form validation passed');
      final loginRequest = LoginRequest(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      debugPrint('📤 Sending login request for: ${loginRequest.email}');
      context.read<AuthBloc>().add(LoginEvent(loginRequest));
    } else {
      debugPrint('❌ Form validation failed');
    }
  }

  void _socialLogin(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider login coming soon!'),
        backgroundColor: const Color(0xFF4285F4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  String _getLoginErrorMessage(String originalError) {
    // Convert backend error messages to user-friendly messages
    final lowerError = originalError.toLowerCase();

    if (lowerError.contains('user not found') ||
        lowerError.contains('user does not exist') ||
        lowerError.contains('invalid email')) {
      return 'This email is not registered. Check your email or create a new account.';
    }

    if (lowerError.contains('wrong password') ||
        lowerError.contains('incorrect password') ||
        lowerError.contains('invalid password') ||
        lowerError.contains('password mismatch')) {
      return 'Wrong password. Try again or reset your password.';
    }

    if (lowerError.contains('invalid credentials') ||
        lowerError.contains('authentication failed') ||
        lowerError.contains('login failed')) {
      return 'Email or password is wrong. Double-check and try again.';
    }

    if (lowerError.contains('account disabled') ||
        lowerError.contains('account suspended')) {
      return 'Your account is disabled. Contact our support team for help.';
    }

    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout')) {
      return 'Connection problem. Check your internet and try again.';
    }

    if (lowerError.contains('server') ||
        lowerError.contains('internal error')) {
      return 'Something went wrong on our end. Try again in a moment.';
    }

    if (lowerError.contains('email not verified') ||
        lowerError.contains('verify your email')) {
      return 'Check your email and verify your account first.';
    }

    if (lowerError.contains('too many attempts') ||
        lowerError.contains('rate limit')) {
      return 'Too many tries. Wait a few minutes before trying again.';
    }

    // Default user-friendly message for unknown errors
    return 'Something went wrong. Check your email and password, then try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            debugPrint('📱 Login page received state: ${state.runtimeType}');
            if (state is AuthError) {
              debugPrint('🔴 Showing error snackbar: ${state.message}');

              // Clear any existing snackbars first
              ScaffoldMessenger.of(context).clearSnackBars();

              // Show user-friendly error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getLoginErrorMessage(state.message),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 4),
                  margin: const EdgeInsets.all(16),
                  elevation: 6,
                ),
              );
            } else if (state is AuthAuthenticated) {
              debugPrint('✅ Login successful, checking password requirements');

              // Check if password change is required (based on isTempPassword)
              if (state.requiresPasswordChange || state.user.isTempPassword) {
                debugPrint(
                  '🔑 Temporary password detected, showing change dialog',
                );

                // Show password change dialog - user MUST change password
                showDialog(
                  context: context,
                  barrierDismissible:
                      false, // Cannot dismiss - must change password
                  builder:
                      (context) => PasswordChangeDialog(
                        user: state.user,
                        isRequired: true, // Mark as required
                      ),
                );
              } else {
                // Normal login flow - navigation will happen automatically via AuthWrapper
                debugPrint(
                  '✅ Normal login, navigation will happen automatically',
                );

                // Show brief success message - AuthWrapper will handle navigation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Login successful! Redirecting... 🎉',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(milliseconds: 1000),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            } else if (state is AuthLoading) {
              debugPrint('⏳ Authentication in progress');
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 80),

                // Logo Section - No box around it
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.eco_rounded,
                        color: Color(0xFF4CAF50),
                        size: 120,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),

                // Title - Clear dark text
                const Text(
                  'Sign in to ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A202C), // Dark gray-black
                    letterSpacing: 0.3,
                  ),
                ),
                const Text(
                  'Guardian Grove',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0EA5E9), // Clear blue
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 40),

                // Social Login Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google Button
                    _buildSocialButton(
                      onTap: () => _socialLogin('Google'),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Facebook Button
                    _buildSocialButton(
                      onTap: () => _socialLogin('Facebook'),
                      color: const Color(0xFF1877F2),
                      child: const Icon(
                        Icons.facebook,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Apple Button
                    _buildSocialButton(
                      onTap: () => _socialLogin('Apple'),
                      color: const Color(0xFF000000),
                      child: const Icon(
                        Icons.apple,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50), // Form Section
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name Field
                      _buildInputField(
                        controller: _nameController,
                        hintText: 'Name',
                        icon: Icons.person_rounded,
                        iconColor: const Color(0xFF0EA5E9),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Email Field
                      _buildInputField(
                        controller: _emailController,
                        hintText: 'Email',
                        icon: Icons.email_rounded,
                        iconColor: const Color(0xFF0EA5E9),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Password Field
                      _buildInputField(
                        controller: _passwordController,
                        hintText: 'Password',
                        icon: Icons.lock_rounded,
                        iconColor: const Color(0xFF0EA5E9),
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: const Color(0xFF0EA5E9),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 40),

                      // Login Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient:
                                  state is AuthLoading
                                      ? null
                                      : const LinearGradient(
                                        colors: [
                                          Color(0xFF0EA5E9),
                                          Color(0xFF0284C7),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                              color:
                                  state is AuthLoading
                                      ? const Color(0xFFE2E8F0)
                                      : null,
                              borderRadius: BorderRadius.circular(26),
                              boxShadow:
                                  state is AuthLoading
                                      ? null
                                      : [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF0EA5E9,
                                          ).withValues(alpha: 0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(26),
                                onTap: state is AuthLoading ? null : _login,
                                child: Center(
                                  child:
                                      state is AuthLoading
                                          ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                          : const Text(
                                            'Login',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: Color(0xFF64748B), // Clear gray
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                color: Color(0xFF0EA5E9),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF0EA5E9),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required Widget child,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color iconColor,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF1A202C), // Dark text
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: hintText,
        labelStyle: const TextStyle(
          color: Color(0xFF94A3B8), // Clear gray placeholder
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF0EA5E9), // Blue when focused
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: iconColor, size: 20),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        errorStyle: const TextStyle(color: Color(0xFFE53E3E), fontSize: 13),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }
}
