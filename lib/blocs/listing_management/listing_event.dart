import 'package:equatable/equatable.dart';
import '../../models/listing.dart';

abstract class ListingEvent extends Equatable {
  const ListingEvent();

  @override
  List<Object?> get props => [];
}

// Load all listings
class LoadAllListings extends ListingEvent {
  const LoadAllListings();
}

// Load user's listings
class LoadUserListings extends ListingEvent {
  final String userId;

  const LoadUserListings(this.userId);

  @override
  List<Object> get props => [userId];
}

// Create a new listing
class CreateListing extends ListingEvent {
  final Listing listing;

  const CreateListing(this.listing);

  @override
  List<Object> get props => [listing];
}

// Update an existing listing
class UpdateListing extends ListingEvent {
  final String listingId;
  final Listing listing;

  const UpdateListing(this.listingId, this.listing);

  @override
  List<Object> get props => [listingId, listing];
}

// Delete a listing
class DeleteListing extends ListingEvent {
  final String listingId;

  const DeleteListing(this.listingId);

  @override
  List<Object> get props => [listingId];
}

// Listen to all listings stream
class ListenToAllListings extends ListingEvent {
  const ListenToAllListings();
}

// Listen to user listings stream
class ListenToUserListings extends ListingEvent {
  final String userId;

  const ListenToUserListings(this.userId);

  @override
  List<Object> get props => [userId];
}

// Update listings from stream
class UpdateListingsFromStream extends ListingEvent {
  final List<Listing> listings;

  const UpdateListingsFromStream(this.listings);

  @override
  List<Object> get props => [listings];
}

// Stop listening to any active listings stream
class StopListeningToListings extends ListingEvent {
  const StopListeningToListings();
}
