import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';

class AuthTestScreen extends StatefulWidget {
  const AuthTestScreen({super.key});

  @override
  State<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  
  String _statusMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _signUp(BuildContext context) {
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _nameController.text.isEmpty) {
      setState(() => _statusMessage = 'Please fill all fields');
      return;
    }

    context.read<AuthBloc>().add(
      SignUpRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      ),
    );
  }

  void _signIn(BuildContext context) {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _statusMessage = 'Please enter email and password');
      return;
    }

    context.read<AuthBloc>().add(
      SignInRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _signOut(BuildContext context) {
    context.read<AuthBloc>().add(const SignOutRequested());
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
  }

  void _checkVerificationStatus(BuildContext context) {
    context.read<AuthBloc>().add(const CheckVerificationStatusRequested());
  }

  void _resendVerification(BuildContext context) {
    context.read<AuthBloc>().add(const ResendVerificationEmailRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Service Test - Bloc'),
        backgroundColor: Colors.blue,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            setState(() => _statusMessage = state.message);
          } else if (state is AuthError) {
            setState(() => _statusMessage = state.message);
          } else if (state is AuthLoading && state.message != null) {
            setState(() => _statusMessage = state.message!);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final user = state is AuthAuthenticated ? state.user : null;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current User Status
                Card(
                  color: user != null ? Colors.green[50] : Colors.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Current User',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(width: 8),
                            if (isLoading)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user != null 
                            ? 'Email: ${user.email}\nUID: ${user.uid}\nVerified: ${user.emailVerified}'
                            : state is AuthLoading
                              ? 'Loading...'
                              : 'Not signed in',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Input Fields
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  enabled: !isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Buttons
                if (user == null) ...[
                  ElevatedButton(
                    onPressed: isLoading ? null : () => _signUp(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Sign Up'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: isLoading ? null : () => _signIn(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Sign In'),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: isLoading ? null : () => _signOut(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Sign Out'),
                  ),
                  // Show resend verification button if email not verified
                  if (!user.emailVerified) ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : () => _resendVerification(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.email),
                      label: const Text('Resend Verification Email'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : () => _checkVerificationStatus(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Check Verification Status'),
                    ),
                  ],
                ],
                
                const SizedBox(height: 24),
                
                // Status Message
                if (_statusMessage.isNotEmpty)
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _statusMessage,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
