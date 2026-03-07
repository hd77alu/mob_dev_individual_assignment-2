import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'listing_event.dart';
import 'listing_state.dart';
import '../../services/listing_service.dart';

class ListingBloc extends Bloc<ListingEvent, ListingState> {
  final ListingService _listingService;
  StreamSubscription? _listingsSubscription;

  ListingBloc(this._listingService) : super(const ListingInitial()) {
    on<LoadAllListings>(_onLoadAllListings);
    on<LoadUserListings>(_onLoadUserListings);
    on<CreateListing>(_onCreateListing);
    on<UpdateListing>(_onUpdateListing);
    on<DeleteListing>(_onDeleteListing);
    on<ListenToAllListings>(_onListenToAllListings);
    on<ListenToUserListings>(_onListenToUserListings);
    on<UpdateListingsFromStream>(_onUpdateListingsFromStream);
  }

  Future<void> _onLoadAllListings(
    LoadAllListings event,
    Emitter<ListingState> emit,
  ) async {
    try {
      emit(const ListingLoading());
      // This will be replaced by stream subscription
      developer.log('LoadAllListings called - use ListenToAllListings instead');
    } catch (e) {
      emit(ListingError('Failed to load listings: ${e.toString()}'));
    }
  }

  Future<void> _onLoadUserListings(
    LoadUserListings event,
    Emitter<ListingState> emit,
  ) async {
    try {
      emit(const ListingLoading());
      developer.log('LoadUserListings called - use ListenToUserListings instead');
    } catch (e) {
      emit(ListingError('Failed to load user listings: ${e.toString()}'));
    }
  }

  Future<void> _onCreateListing(
    CreateListing event,
    Emitter<ListingState> emit,
  ) async {
    try {
      await _listingService.createListing(event.listing);
      
      // Don't add optimistically - let Firestore stream handle it
      // to avoid duplicates
      if (state is ListingLoaded) {
        final currentListings = (state as ListingLoaded).listings;
        emit(ListingOperationSuccess('Listing created successfully', listings: currentListings));
      } else {
        emit(const ListingOperationSuccess('Listing created successfully'));
      }
      // Firestore stream will add the new listing
    } catch (e) {
      developer.log('Error creating listing: $e');
      emit(ListingError('Failed to create listing: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateListing(
    UpdateListing event,
    Emitter<ListingState> emit,
  ) async {
    try {
      await _listingService.updateListing(event.listingId, event.listing);
      
      // Update the listings immediately
      if (state is ListingLoaded) {
        final currentListings = (state as ListingLoaded).listings;
        final updatedListings = currentListings.map((listing) {
          return listing.id == event.listingId ? event.listing : listing;
        }).toList();
        emit(ListingOperationSuccess('Listing updated successfully', listings: updatedListings));
      } else {
        emit(const ListingOperationSuccess('Listing updated successfully'));
      }
      // Firestore stream will confirm with fresh data
    } catch (e) {
      developer.log('Error updating listing: $e');
      emit(ListingError('Failed to update listing: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteListing(
    DeleteListing event,
    Emitter<ListingState> emit,
  ) async {
    try {
      await _listingService.deleteListing(event.listingId);
      
      //  Remove the listing immediately
      if (state is ListingLoaded) {
        final currentListings = (state as ListingLoaded).listings;
        final updatedListings = currentListings
            .where((listing) => listing.id != event.listingId)
            .toList();
        emit(ListingOperationSuccess('Listing deleted successfully', listings: updatedListings));
      } else {
        emit(const ListingOperationSuccess('Listing deleted successfully'));
      }
      // Firestore stream will confirm with fresh data
    } catch (e) {
      developer.log('Error deleting listing: $e');
      emit(ListingError('Failed to delete listing: ${e.toString()}'));
    }
  }

  Future<void> _onListenToAllListings(
    ListenToAllListings event,
    Emitter<ListingState> emit,
  ) async {
    try {
      await _listingsSubscription?.cancel();
      emit(const ListingLoading());
      
      _listingsSubscription = _listingService.getAllListings().listen(
        (listings) {
          add(UpdateListingsFromStream(listings));
        },
        onError: (error) {
          developer.log('Error in listings stream: $error');
          emit(ListingError('Failed to load listings: ${error.toString()}'));
        },
      );
    } catch (e) {
      emit(ListingError('Failed to listen to listings: ${e.toString()}'));
    }
  }

  Future<void> _onListenToUserListings(
    ListenToUserListings event,
    Emitter<ListingState> emit,
  ) async {
    try {
      await _listingsSubscription?.cancel();
      emit(const ListingLoading());
      
      _listingsSubscription = _listingService.getUserListings(event.userId).listen(
        (listings) {
          add(UpdateListingsFromStream(listings));
        },
        onError: (error) {
          developer.log('Error in user listings stream: $error');
          emit(ListingError('Failed to load user listings: ${error.toString()}'));
        },
      );
    } catch (e) {
      emit(ListingError('Failed to listen to user listings: ${e.toString()}'));
    }
  }

  void _onUpdateListingsFromStream(
    UpdateListingsFromStream event,
    Emitter<ListingState> emit,
  ) {
    // Always emit the latest listings from Firestore stream, 
    // even if we're in a success state
    emit(ListingLoaded(event.listings));
  }

  @override
  Future<void> close() {
    _listingsSubscription?.cancel();
    return super.close();
  }
}
