import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User Profile Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: user != null
                      ? StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            String userName = 'Loading...';
                            
                            if (snapshot.hasData && snapshot.data != null) {
                              final data = snapshot.data!.data() as Map<String, dynamic>?;
                              userName = data?['name'] ?? 'User';
                            }

                            return Column(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: AppTheme.primaryYellow,
                                  child: Icon(
                                    Icons.person,
                                    size: 40,
                                    color: AppTheme.primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  userName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user.email ?? 'No email',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: user.emailVerified
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        user.emailVerified
                                            ? Icons.verified
                                            : Icons.warning,
                                        size: 16,
                                        color: user.emailVerified
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        user.emailVerified
                                            ? 'Verified'
                                            : 'Not Verified',
                                        style: TextStyle(
                                          color: user.emailVerified
                                              ? Colors.green
                                              : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      : Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppTheme.primaryYellow,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: AppTheme.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Not signed in',
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Notifications Setting
              Card(
                child: SwitchListTile(
                  title: const Text('Location Notifications'),
                  subtitle: const Text('Receive notifications about nearby services'),
                  value: false, // TODO: Implement state management for this
                  onChanged: (value) {
                    // TODO: Implement notification preference
                  },
                  activeColor: AppTheme.primaryYellow,
                ),
              ),
              const SizedBox(height: 32),
              
              // Sign Out Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(const SignOutRequested());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
