import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../models/listing.dart';
import '../../utils/app_theme.dart';
import '../home/home_screen.dart';

class ListingDetailScreen extends StatefulWidget {
  final Listing listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final MapController _mapController = MapController();

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

  Future<void> _launchDirections() async {
    final lat = widget.listing.latitude;
    final lng = widget.listing.longitude;
    final name = Uri.encodeComponent(widget.listing.name);
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$name&travelmode=driving',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps. Please install Google Maps.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final position = LatLng(widget.listing.latitude, widget.listing.longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listing.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'View on Map tab',
            onPressed: () {
              // Switch to Map tab and pop back to HomeScreen
              HomeScreen.tabNotifier.value = 2;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Embedded map
            SizedBox(
              height: 260,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: position,
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.individual_assignment_2',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: position,
                        width: 48,
                        height: 48,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryDark,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primaryYellow, width: 2.5),
                            boxShadow: const [
                              BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Icon(
                            _getCategoryIcon(widget.listing.category),
                            color: AppTheme.primaryYellow,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Get Directions button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _launchDirections,
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    foregroundColor: AppTheme.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),

            // Detail info section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryYellow.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(widget.listing.category),
                          size: 16,
                          color: AppTheme.primaryYellow,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.listing.category,
                          style: const TextStyle(
                            color: AppTheme.primaryYellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Listing name
                  Text(
                    widget.listing.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  _InfoRow(
                    icon: Icons.location_on,
                    label: 'Address',
                    value: widget.listing.address,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.phone,
                    label: 'Contact',
                    value: widget.listing.contactNumber,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.info_outline,
                    label: 'Description',
                    value: widget.listing.description,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.my_location,
                    label: 'Coordinates',
                    value:
                        '${widget.listing.latitude.toStringAsFixed(6)}, ${widget.listing.longitude.toStringAsFixed(6)}',
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Added',
                    value: DateFormat('MMMM d, yyyy').format(widget.listing.timestamp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppTheme.primaryYellow),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              const SizedBox(height: 3),
              Text(value, style: const TextStyle(fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }
}
