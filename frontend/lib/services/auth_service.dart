import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service for handling Firebase Authentication.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // GoogleSignIn instance for native sign-in
  GoogleSignIn? _googleSignIn;

  GoogleSignIn get googleSignIn {
    _googleSignIn ??= GoogleSignIn();
    return _googleSignIn!;
  }

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Check if a user exists in Firestore
  Future<bool> _userExistsInFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  /// Create user document in Firestore
  Future<void> _createUserInFirestore(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  /// Update last login timestamp
  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Create user in Firestore
      if (credential.user != null) {
        await _createUserInFirestore(credential.user!);
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Check if user exists in Firestore (they should if they signed up properly)
      if (credential.user != null) {
        final exists = await _userExistsInFirestore(credential.user!.uid);
        if (!exists) {
          // User exists in Firebase Auth but not Firestore - reject
          await _auth.signOut();
          throw 'Please sign up first before signing in.';
        }
        await _updateLastLogin(credential.user!.uid);
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign UP with Google - Creates new account
  /// Use this when user is on the "Sign Up" tab
  Future<UserCredential?> signUpWithGoogle() async {
    try {
      UserCredential? credential;

      if (kIsWeb) {
        // Web: Use popup
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        credential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Mobile: Use native Google Sign-In
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          // User cancelled the sign-in
          return null;
        }

        final googleAuth = await googleUser.authentication;
        final authCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        credential = await _auth.signInWithCredential(authCredential);
      }

      if (credential.user != null) {
        // Check if already registered
        final exists = await _userExistsInFirestore(credential.user!.uid);
        if (exists) {
          // User already exists - just update last login and proceed
          await _updateLastLogin(credential.user!.uid);
        } else {
          // New user - create in Firestore
          await _createUserInFirestore(credential.user!);
        }
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Google Sign-Up failed: $e';
    }
  }

  /// Sign IN with Google - Only for existing users
  /// Use this when user is on the "Sign In" tab
  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential? credential;

      if (kIsWeb) {
        // Web: Use popup
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        credential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Mobile: Use native Google Sign-In
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          // User cancelled the sign-in
          return null;
        }

        final googleAuth = await googleUser.authentication;
        final authCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        credential = await _auth.signInWithCredential(authCredential);
      }

      if (credential.user != null) {
        // Check if user exists in Firestore
        final exists = await _userExistsInFirestore(credential.user!.uid);
        if (!exists) {
          // User doesn't exist in our database - reject sign-in
          await _auth.signOut();
          if (!kIsWeb) {
            await googleSignIn.signOut();
          }
          throw 'No account found. Please sign up first.';
        }
        // Update last login
        await _updateLastLogin(credential.user!.uid);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      if (e.toString().contains('No account found')) {
        rethrow;
      }
      throw 'Google Sign-In failed: $e';
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (!kIsWeb) {
      await googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Convert Firebase auth errors to user-friendly messages
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
