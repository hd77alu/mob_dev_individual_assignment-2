import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../directory/directory_screen.dart';
import '../listings/my_listings_screen.dart';
import '../map/map_view_screen.dart';
import '../settings/settings_screen.dart';
import '../../blocs/listing_management/listing_bloc.dart';
import '../../blocs/listing_management/listing_event.dart';
import '../../utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DirectoryScreen(),
    MyListingsScreen(),
    MapViewScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with the first tab (Directory - all listings)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleTabChange(0);
    });
  }

  void _handleTabChange(int index) {
    // Switch to the appropriate listings stream based on tab
    if (index == 0) {
      // Directory tab - show all listings
      context.read<ListingBloc>().add(const ListenToAllListings());
    } else if (index == 1) {
      // My Listings tab - show user's listings
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.read<ListingBloc>().add(ListenToUserListings(user.uid));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Switch to appropriate stream based on selected tab
          _handleTabChange(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.primaryDark,
        selectedItemColor: AppTheme.primaryYellow,
        unselectedItemColor: AppTheme.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Directory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'My Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
