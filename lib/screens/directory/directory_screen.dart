import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/listing/listing_bloc.dart';
import '../../blocs/listing/listing_event.dart';
import '../../blocs/listing/listing_state.dart';
import '../../models/listing.dart';
import '../../utils/app_theme.dart';
import '../listings/add_edit_listing_screen.dart';
import 'widgets/listing_card.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> with AutomaticKeepAliveClientMixin {
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Listing> _filterListings(List<Listing> listings) {
    var filtered = listings;

    // Filter by category
    if (_selectedCategory != null) {
      filtered = filtered.where((listing) => listing.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((listing) {
        return listing.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               listing.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               listing.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directory'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (category) {
              setState(() {
                _selectedCategory = category == 'All' ? null : category;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'All',
                child: Text('All Categories'),
              ),
              ...Listing.categories.map((category) {
                return PopupMenuItem(
                  value: category,
                  child: Text(category),
                );
              }),
            ],
          ),
        ],
      ),
      body: BlocConsumer<ListingBloc, ListingState>(
        listener: (context, state) {
          if (state is ListingOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          // Handle ListingOperationSuccess by showing cached listings if available
          if (state is ListingOperationSuccess && state.listings != null) {
            // Show cached listings during operation
            final filteredListings = _filterListings(state.listings!);

            return Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, address, or description...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                // Results
                Expanded(
                  child: filteredListings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.explore,
                                size: 80,
                                color: AppTheme.primaryYellow.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No results found'
                                    : _selectedCategory != null
                                        ? 'No listings in this category'
                                        : 'No listings yet',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Try a different search term'
                                    : 'Be the first to add one!',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<ListingBloc>().add(const ListenToAllListings());
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: filteredListings.length,
                            itemBuilder: (context, index) {
                              return ListingCard(listing: filteredListings[index]);
                            },
                          ),
                        ),
                ),
              ],
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
                      context.read<ListingBloc>().add(const ListenToAllListings());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ListingLoaded) {
            // Filter listings by category and search query
            final filteredListings = _filterListings(state.listings);

            return Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, address, or description...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                // Results
                Expanded(
                  child: filteredListings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.explore,
                                size: 80,
                                color: AppTheme.primaryYellow.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No results found'
                                    : _selectedCategory != null
                                        ? 'No listings in this category'
                                        : 'No listings yet',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Try a different search term'
                                    : 'Be the first to add one!',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<ListingBloc>().add(const ListenToAllListings());
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: filteredListings.length,
                            itemBuilder: (context, index) {
                              return ListingCard(listing: filteredListings[index]);
                            },
                          ),
                        ),
                ),
              ],
            );
          }

          // Initial state
          return Center(
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
                  'Directory',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Browse all services and places',
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
