import 'package:equatable/equatable.dart';
import '../../models/listing.dart';

abstract class ListingState extends Equatable {
  const ListingState();

  @override
  List<Object?> get props => [];
}

// Initial state
class ListingInitial extends ListingState {
  const ListingInitial();
}

// Loading state
class ListingLoading extends ListingState {
  const ListingLoading();
}

// Listings loaded successfully
class ListingLoaded extends ListingState {
  final List<Listing> listings;

  const ListingLoaded(this.listings);

  @override
  List<Object> get props => [listings];
}

// Listing operation success (create/update/delete)
class ListingOperationSuccess extends ListingState {
  final String message;
  final List<Listing>? listings; // Optional: preserve current listings during operation

  const ListingOperationSuccess(this.message, {this.listings});

  @override
  List<Object?> get props => [message, listings];
}

// Error state
class ListingError extends ListingState {
  final String message;

  const ListingError(this.message);

  @override
  List<Object> get props => [message];
}
