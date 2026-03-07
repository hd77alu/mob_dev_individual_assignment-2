import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../blocs/listing_management/listing_bloc.dart';
import '../../blocs/listing_management/listing_event.dart';
import '../../blocs/listing_management/listing_state.dart';
import '../../models/listing.dart';
import '../../utils/app_theme.dart';
import '../../widgets/listing_card.dart';
import 'add_edit_listing_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  void _confirmDelete(BuildContext context, Listing listing) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Listing'),
        content: Text('Are you sure you want to delete "${listing.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ListingBloc>().add(DeleteListing(listing.id!));
              Navigator.pop(dialogContext);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Listings'),
        ),
        body: const Center(
          child: Text('Please log in to view your listings'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
      ),
      body: BlocConsumer<ListingBloc, ListingState>(
        listener: (context, state) {
          if (state is ListingOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ListingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // Handle ListingOperationSuccess by showing cached listings if available
          if (state is ListingOperationSuccess && state.listings != null) {
            if (state.listings!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.list_alt,
                      size: 80,
                      color: AppTheme.primaryYellow.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No listings yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first listing!',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ListingBloc>().add(ListenToUserListings(user.uid));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: state.listings!.length,
                itemBuilder: (context, index) {
                  final listing = state.listings![index];
                  return ListingCard(
                    listing: listing,
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditListingScreen(
                            listing: listing,
                          ),
                        ),
                      );
                    },
                    onDelete: () => _confirmDelete(context, listing),
                  );
                },
              ),
            );
          }

          if (state is ListingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ListingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading listings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ListingBloc>().add(ListenToUserListings(user.uid));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ListingLoaded) {
            if (state.listings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.list_alt,
                      size: 80,
                      color: AppTheme.primaryYellow.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No listings yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first listing!',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ListingBloc>().add(ListenToUserListings(user.uid));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: state.listings.length,
                itemBuilder: (context, index) {
                  final listing = state.listings[index];
                  return ListingCard(
                    listing: listing,
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditListingScreen(
                            listing: listing,
                          ),
                        ),
                      );
                    },
                    onDelete: () => _confirmDelete(context, listing),
                  );
                },
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.list_alt,
                  size: 80,
                  color: AppTheme.primaryYellow,
                ),
                const SizedBox(height: 16),
                Text(
                  'My Listings',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your listings',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditListingScreen(),
            ),
          );
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
