import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directory'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore,
              size: 80,
              color: AppTheme.primaryYellow,
            ),
            const SizedBox(height: 16),
            Text(
              'Directory Screen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Browse all services and places',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add listing screen
        },
        backgroundColor: AppTheme.primaryYellow,
        child: const Icon(
          Icons.add,
          color: AppTheme.primaryDark,
        ),
      ),
    );
  }
}
