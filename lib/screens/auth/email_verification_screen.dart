import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../utils/app_theme.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        automaticallyImplyLeading: false,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Icon(
                    Icons.mark_email_unread_outlined,
                    size: 100,
                    color: AppTheme.primaryYellow,
                  ),
                  const SizedBox(height: 32),
                  
                  // Title
                  Text(
                    'Verify Your Email',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final user = state is AuthAuthenticated ? state.user : null;
                      return Text(
                        'We sent a verification email to:\n${user?.email ?? ""}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please check your inbox and click the verification link.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // Check Verification Status Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<AuthBloc>().add(
                                        const CheckVerificationStatusRequested(),
                                      );
                                },
                          icon: const Icon(Icons.refresh),
                          label: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.primaryDark,
                                  ),
                                )
                              : const Text('I\'ve Verified My Email'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Resend Email Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return TextButton.icon(
                        onPressed: isLoading
                            ? null
                            : () {
                                context.read<AuthBloc>().add(
                                      const ResendVerificationEmailRequested(),
                                    );
                              },
                        icon: const Icon(Icons.email_outlined),
                        label: const Text('Resend Verification Email'),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Sign Out Link
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(const SignOutRequested());
                    },
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
