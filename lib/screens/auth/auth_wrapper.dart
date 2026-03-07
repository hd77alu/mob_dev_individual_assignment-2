import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_management/auth_bloc.dart';
import '../../blocs/auth_management/auth_state.dart';
import 'login_screen.dart';
import 'email_verification_screen.dart';
import '../home/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Show loading indicator while checking auth state
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is authenticated
        if (state is AuthAuthenticated) {
          // Check if email is verified
          if (state.user.emailVerified) {
            // Email verified - show home screen
            return const HomeScreen();
          } else {
            // Email not verified - show verification screen
            return const EmailVerificationScreen();
          }
        }

        // User is not authenticated - show login screen
        return const LoginScreen();
      },
    );
  }
}
