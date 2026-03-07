import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing.dart';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'listings';

  // Get all listings stream
  Stream<List<Listing>> getAllListings() {
    try {
      return _firestore
          .collection(_collectionName)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Listing.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      developer.log('Error getting all listings: $e');
      rethrow;
    }
  }

  // Get listings created by a specific user
  Stream<List<Listing>> getUserListings(String userId) {
    try {
      return _firestore
          .collection(_collectionName)
          .where('createdBy', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        final listings = snapshot.docs
            .map((doc) => Listing.fromFirestore(doc))
            .toList();
        // Sort by timestamp in descending order (newest first)
        listings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return listings;
      });
    } catch (e) {
      developer.log('Error getting user listings: $e');
      rethrow;
    }
  }

  // Create a new listing
  Future<String> createListing(Listing listing) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collectionName)
          .add(listing.toMap());
      developer.log('Listing created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      developer.log('Error creating listing: $e');
      rethrow;
    }
  }

  // Update an existing listing
  Future<void> updateListing(String listingId, Listing listing) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(listingId)
          .update(listing.toMap());
      developer.log('Listing updated: $listingId');
    } catch (e) {
      developer.log('Error updating listing: $e');
      rethrow;
    }
  }

  // Delete a listing
  Future<void> deleteListing(String listingId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(listingId)
          .delete();
      developer.log('Listing deleted: $listingId');
    } catch (e) {
      developer.log('Error deleting listing: $e');
      rethrow;
    }
  }

  // Get a single listing by ID
  Future<Listing?> getListingById(String listingId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collectionName)
          .doc(listingId)
          .get();
      
      if (doc.exists) {
        return Listing.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      developer.log('Error getting listing by ID: $e');
      rethrow;
    }
  }

  // Get listings by category
  Stream<List<Listing>> getListingsByCategory(String category) {
    try {
      return _firestore
          .collection(_collectionName)
          .where('category', isEqualTo: category)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Listing.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      developer.log('Error getting listings by category: $e');
      rethrow;
    }
  }
}
