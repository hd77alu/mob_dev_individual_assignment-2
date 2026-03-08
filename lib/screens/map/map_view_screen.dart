import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../blocs/listing_management/listing_bloc.dart';
import '../../blocs/listing_management/listing_state.dart';
import '../../models/listing.dart';
import '../../utils/app_theme.dart';
import '../directory/listing_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  /// When set, the map will initially centre on these coordinates.
  final LatLng? focusPoint;

  const MapViewScreen({super.key, this.focusPoint});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen>
    with AutomaticKeepAliveClientMixin {
  // Default centre: Kigali, Rwanda
  static const LatLng _kigali = LatLng(-1.9441, 30.0619);

  @override
  bool get wantKeepAlive => true;

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Hospital':
        return Icons.local_hospital;
      case 'Police Station':
        return Icons.local_police;
      case 'Library':
        return Icons.local_library;
      case 'Restaurant':
        return Icons.restaurant;
      case 'Café':
        return Icons.local_cafe;
      case 'Park':
        return Icons.park;
      case 'Tourist Attraction':
        return Icons.attractions;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
      ),
      body: BlocBuilder<ListingBloc, ListingState>(
        builder: (context, state) {
          List<Listing> listings = [];

          if (state is ListingLoaded) {
            listings = state.listings;
          } else if (state is ListingOperationSuccess &&
              state.listings != null) {
            listings = state.listings!;
          }

          final initialCenter = widget.focusPoint ?? _kigali;

          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: widget.focusPoint != null ? 15 : 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                        'com.example.individual_assignment_2',
                  ),
                  MarkerLayer(
                    markers: listings.map((listing) {
                      final point =
                          LatLng(listing.latitude, listing.longitude);
                      final isFocused = widget.focusPoint != null &&
                          (listing.latitude - widget.focusPoint!.latitude)
                                  .abs() <
                              0.0001 &&
                          (listing.longitude - widget.focusPoint!.longitude)
                                  .abs() <
                              0.0001;

                      return Marker(
                        point: point,
                        width: isFocused ? 56 : 44,
                        height: isFocused ? 56 : 44,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ListingDetailScreen(listing: listing),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isFocused
                                  ? AppTheme.primaryYellow
                                  : AppTheme.primaryDark,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isFocused
                                    ? AppTheme.primaryDark
                                    : AppTheme.primaryYellow,
                                width: 2.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getCategoryIcon(listing.category),
                              color: isFocused
                                  ? AppTheme.primaryDark
                                  : AppTheme.primaryYellow,
                              size: isFocused ? 30 : 22,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Loading overlay
              if (state is ListingLoading)
                const Center(child: CircularProgressIndicator()),

              // Listing count badge
              if (listings.isNotEmpty)
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDark.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppTheme.primaryYellow, width: 1),
                    ),
                    child: Text(
                      '${listings.length} listing${listings.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: AppTheme.primaryYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
