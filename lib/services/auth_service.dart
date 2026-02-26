import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      // Send email verification
      if (user != null) {
        try {
          await user.sendEmailVerification();
          developer.log('Verification email sent to: ${user.email}');
        } catch (e) {
          developer.log('Error sending verification email: $e');
          // Continue with account creation even if email fails
        }

        // Create user profile in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'emailVerified': false,
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      
      // Sync email verification status with Firestore
      if (user != null) {
        await user.reload();
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (userDoc.exists) {
          final firestoreVerified = userDoc.data()?['emailVerified'] ?? false;
          
          // Update Firestore if verification status changed
          if (user.emailVerified != firestoreVerified) {
            await _firestore.collection('users').doc(user.uid).update({
              'emailVerified': user.emailVerified,
            });
            developer.log(' Updated emailVerified in Firestore: ${user.emailVerified}');
          }
        }
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if email is verified and sync with Firestore
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    final isVerified = _auth.currentUser?.emailVerified ?? false;
    
    // Sync with Firestore
    if (_auth.currentUser != null) {
      await _syncEmailVerificationStatus();
    }
    
    return isVerified;
  }

  // Resend verification email
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // Sync email verification status between Auth and Firestore
  Future<void> _syncEmailVerificationStatus() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await user.reload();
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        final firestoreVerified = userDoc.data()?['emailVerified'] ?? false;
        
        // Update Firestore if verification status changed
        if (user.emailVerified != firestoreVerified) {
          await _firestore.collection('users').doc(user.uid).update({
            'emailVerified': user.emailVerified,
          });
          developer.log('Synced emailVerified in Firestore: ${user.emailVerified}');
        }
      }
    } catch (e) {
      developer.log('Error syncing email verification status: $e');
    }
  }

  // Handle auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'Invalid email address.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
