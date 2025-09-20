import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// ignore: unnecessary_import
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ecommerce_app/services/notification_service.dart';
import 'package:ecommerce_app/services/storage_service.dart';
import 'package:ecommerce_app/services/firestore_service.dart';
import 'package:ecommerce_app/firebase_options.dart';

// Import the global notification service
final notificationService = NotificationService();

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;
  final FirestoreService _firestoreService = FirestoreService();

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isFirebaseAvailable = true;
  bool _isDemoMode = false;

  User? get user => _user;
  bool get isAuthenticated => _user != null || _isDemoMode;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _isDemoMode ? 'demo_user_id' : _user?.uid;
  String? get userEmail => _isDemoMode ? 'demo@example.com' : _user?.email;
  String? get userName =>
      _isDemoMode
          ? 'Demo User'
          : (_user?.displayName ?? _user?.email?.split('@')[0]);
  String? get userPhotoUrl =>
      _isDemoMode
          ? 'https://ui-avatars.com/api/?name=Demo+User&background=4285f4&color=ffffff&size=200'
          : _user?.photoURL;
  bool get isDemoUser => _isDemoMode;

  AuthProvider() {
    // Initialize GoogleSignIn with clean configuration
    if (kIsWeb) {
      _googleSignIn = GoogleSignIn(
        // Using the Web API Key from Firebase configuration
        clientId: DefaultFirebaseOptions.web.apiKey,
        scopes: ['email', 'profile'],
      );
    } else {
      _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
    }

    // Listen to auth state changes with error handling
    _auth.authStateChanges().listen(
      (User? user) {
        _user = user;

        if (user != null) {
          // User signed in
          _saveUserSession();
          try {
            notificationService.listenForNewProducts();
            notificationService.listenForOrderUpdates();
          } catch (e) {
            // Handle notification service errors silently
          }
        } else {
          // User signed out
          _clearUserSession();
        }

        notifyListeners();
      },
      onError: (error) {
        // Handle Firebase initialization errors
        if (error.toString().contains('api-key-not-valid')) {
          _handleFirebaseError();
        }
      },
    );

    // Check for existing session with error handling
    _checkExistingSession();
  }

  // Handle Firebase errors by switching to demo mode
  void _handleFirebaseError() {
    _isFirebaseAvailable = false;
    _isDemoMode = true;
    notifyListeners();
  }

  // Check for existing user session
  Future<void> _checkExistingSession() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        _user = currentUser;
        await _saveUserSession();
        notifyListeners();
      } else {
        // Check if we have a demo session
        final sessionData = await StorageService.getUserSession();
        if (sessionData != null && sessionData['isDemoUser'] == true) {
          _isDemoMode = true;
          notifyListeners();
        }
      }
    } catch (e) {
      // If Firebase is not available, enable demo mode
      if (e.toString().contains('api-key-not-valid')) {
        _handleFirebaseError();
      }
    }
  }

  // Save user session to local storage
  Future<void> _saveUserSession() async {
    if (_user != null) {
      final userData = {
        'uid': _user!.uid,
        'email': _user!.email,
        'displayName': _user!.displayName,
        'photoURL': _user!.photoURL,
        'lastLogin': DateTime.now().millisecondsSinceEpoch,
      };
      await StorageService.saveUserSession(userData);
      await StorageService.saveAuthToken(_user!.uid);
    }
  }

  // Clear user session from local storage
  Future<void> _clearUserSession() async {
    await StorageService.clearUserSession();
    await StorageService.clearAuthToken();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error state
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Email/Password Sign In
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    // If Firebase is not available, use demo mode
    if (!_isFirebaseAvailable) {
      return await _createDemoAccount(email, password);
    }

    try {
      _setLoading(true);
      _setError(null);

      // Basic validation
      if (email.trim().isEmpty || password.isEmpty) {
        _setError('Please enter email and password.');
        return false;
      }

      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.trim())) {
        _setError('Please enter a valid email address.');
        return false;
      }

      if (password.length < 6) {
        _setError('Password must be at least 6 characters.');
        return false;
      }

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        // Try to update user data in Firestore (optional)
        try {
          await _firestoreService.updateUserData(result.user!);
        } catch (firestoreError) {
          // Continue even if Firestore fails - authentication still works
        }

        _setError(null);
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e));
      return false;
    } catch (e) {
      // Check if this is a Firebase API key error
      if (e.toString().contains('api-key-not-valid')) {
        _handleFirebaseError();
        // Use demo mode for API key issues
        return await _createDemoAccount(email, password);
      }
      _setError('Sign-in failed. Please check your credentials.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Email/Password Sign Up
  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    // If Firebase is not available, use demo mode
    if (!_isFirebaseAvailable) {
      return await _createDemoAccount(email, password);
    }

    try {
      _setLoading(true);
      _setError(null);

      // Basic validation
      if (email.trim().isEmpty || password.isEmpty) {
        _setError('Please enter email and password.');
        return false;
      }

      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.trim())) {
        _setError('Please enter a valid email address.');
        return false;
      }

      if (password.length < 8) {
        _setError('Password must be at least 8 characters.');
        return false;
      }

      if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
        _setError('Password must contain uppercase, lowercase and number.');
        return false;
      }

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        // Try to create user data in Firestore (optional)
        try {
          await _firestoreService.createUserData(result.user!);
        } catch (firestoreError) {
          // Continue even if Firestore fails - authentication still works
        }

        _setError(null);
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e));
      return false;
    } catch (e) {
      // Check if this is a Firebase API key error
      if (e.toString().contains('api-key-not-valid')) {
        _handleFirebaseError();
        // Use demo mode for API key issues
        return await _createDemoAccount(email, password);
      }
      _setError('Registration failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Google Sign In - Robust Implementation with Fallback
  Future<bool> signInWithGoogle() async {
    // If Firebase is not available, use demo mode
    if (!_isFirebaseAvailable) {
      return await _createGoogleDemoFallback();
    }

    try {
      _setLoading(true);
      _setError(null);

      if (kIsWeb) {
        try {
          // Method 1: Try Firebase Auth Google Sign-In popup
          final GoogleAuthProvider googleProvider = GoogleAuthProvider();
          googleProvider.addScope('email');
          googleProvider.addScope('profile');
          googleProvider.setCustomParameters({
            'prompt': 'select_account',
            'include_granted_scopes': 'true',
          });

          final UserCredential result = await _auth.signInWithPopup(
            googleProvider,
          );

          if (result.user != null) {
            try {
              if (result.additionalUserInfo?.isNewUser == true) {
                await _firestoreService.createUserData(result.user!);
              } else {
                await _firestoreService.updateUserData(result.user!);
              }
            } catch (firestoreError) {
              // Continue even if Firestore fails
            }
            return true;
          }
        } on FirebaseAuthException catch (e) {
          // Handle specific errors
          if (e.code == 'popup-blocked') {
            _setError(
              'Your browser blocked the popup. Please allow popups and try again.',
            );
            return false;
          } else if (e.code == 'popup-closed-by-user') {
            _setError('Sign-in was cancelled. Please try again.');
            return false;
          } else if (e.code == 'invalid-credential' ||
              e.code == 'auth/invalid-api-key') {
            // Handle configuration errors
            _handleFirebaseError();
            return await _createGoogleDemoFallback();
          }

          // For other errors, show user-friendly message
          _setError('Google Sign-In failed. Please try again.');
          return false;
        } catch (generalError) {
          // Check if this is a Firebase API key error
          if (generalError.toString().contains('api-key-not-valid')) {
            _handleFirebaseError();
            // Use demo mode for API key issues
            return await _createGoogleDemoFallback();
          }
          // Fallback to demo for any other web errors
          return await _createGoogleDemoFallback();
        }
      } else {
        // Mobile platform implementation
        try {
          final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
          if (googleUser == null) {
            _setError('Google Sign-In was cancelled.');
            return false;
          }

          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final OAuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          final UserCredential result = await _auth.signInWithCredential(
            credential,
          );

          if (result.user != null) {
            try {
              if (result.additionalUserInfo?.isNewUser == true) {
                await _firestoreService.createUserData(result.user!);
              } else {
                await _firestoreService.updateUserData(result.user!);
              }
            } catch (firestoreError) {
              // Handle Firestore errors silently
            }
            return true;
          }
        } catch (mobileError) {
          // Handle configuration errors
          if (mobileError.toString().contains('api-key-not-valid') ||
              mobileError.toString().contains('INVALID_API_KEY')) {
            _handleFirebaseError();
          }
          return await _createGoogleDemoFallback();
        }
      }

      return false;
    } catch (e) {
      // Check if this is a Firebase API key error
      if (e.toString().contains('api-key-not-valid')) {
        _handleFirebaseError();
        // Use demo mode for API key issues
        return await _createGoogleDemoFallback();
      }
      _setError('Google Sign-In failed. Using demo mode.');
      return await _createGoogleDemoFallback();
    } finally {
      _setLoading(false);
    }
  }

  // Create demo account for email/password
  Future<bool> _createDemoAccount(String email, String password) async {
    try {
      // Use demo credentials
      const demoEmail = 'demo@example.com';
      const demoPassword = 'Demo123!';

      try {
        // In demo mode, we simulate a successful login

        // Set demo mode flag
        _isDemoMode = true;
        _user = null; // No real user in demo mode

        // Save demo session data
        final userData = {
          'uid': 'demo_user_id',
          'email': demoEmail,
          'displayName': 'Demo User',
          'photoURL':
              'https://ui-avatars.com/api/?name=Demo+User&background=4285f4&color=ffffff&size=200',
          'lastLogin': DateTime.now().millisecondsSinceEpoch,
          'isDemoUser': true,
        };
        await StorageService.saveUserSession(userData);
        await StorageService.saveAuthToken('demo_user_id');

        _setError(null);
        notifyListeners();
        return true;
      } catch (createError) {
        // Handle demo account creation errors
      }

      _setError('Demo mode is currently unavailable. Please try again.');
      return false;
    } catch (e) {
      _setError('Failed to create demo account.');
      return false;
    }
  }

  // Create Google demo account as fallback
  Future<bool> _createGoogleDemoFallback() async {
    try {
      // Use demo credentials
      const demoEmail = 'demo.google@example.com';
      const demoName = 'Google Demo User';

      try {
        // In demo mode, we simulate a successful login

        // Set demo mode flag
        _isDemoMode = true;
        _user = null; // No real user in demo mode

        // Save demo session data
        final userData = {
          'uid': 'demo_google_user_id',
          'email': demoEmail,
          'displayName': demoName,
          'photoURL':
              'https://ui-avatars.com/api/?name=Google+Demo&background=4285f4&color=ffffff&size=200',
          'lastLogin': DateTime.now().millisecondsSinceEpoch,
          'isDemoUser': true,
        };
        await StorageService.saveUserSession(userData);
        await StorageService.saveAuthToken('demo_google_user_id');

        _setError(null);
        notifyListeners();
        return true;
      } catch (createError) {
        // Handle demo account creation errors
      }

      _setError(
        'Google Sign-In is currently unavailable. Please use email/password.',
      );
      return false;
    } catch (e) {
      _setError('Failed to create Google demo account.');
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      _setLoading(true);

      // If Firebase is available, sign out from Firebase
      if (_isFirebaseAvailable && !_isDemoMode) {
        await _auth.signOut();

        // Only sign out from GoogleSignIn on mobile platforms
        if (!kIsWeb) {
          await _googleSignIn.signOut();
        }
      }

      // Clear local session regardless
      await _clearUserSession();

      // Clear user and demo mode flag
      _user = null;
      _isDemoMode = false;
      notifyListeners();
    } catch (e) {
      _setError('Sign out failed. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  // Reset Password
  Future<bool> resetPassword(String email) async {
    // If Firebase is not available or in demo mode, we can't reset password
    if (!_isFirebaseAvailable || _isDemoMode) {
      _setError('Password reset is not available in demo mode.');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e));
      return false;
    } catch (e) {
      _setError('Failed to send password reset email.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update Profile
  Future<bool> updateProfile({String? displayName, String? photoURL}) async {
    try {
      _setLoading(true);
      _setError(null);

      if (_isDemoMode) {
        // In demo mode, update local storage
        final userData = {
          'uid': 'demo_user_id',
          'email': 'demo@example.com',
          'displayName': displayName ?? 'Demo User',
          'photoURL':
              photoURL ??
              'https://ui-avatars.com/api/?name=Demo+User&background=4285f4&color=ffffff&size=200',
          'lastLogin': DateTime.now().millisecondsSinceEpoch,
          'isDemoUser': true,
        };
        await StorageService.saveUserSession(userData);
        notifyListeners();
        return true;
      } else if (_user != null) {
        // If Firebase is available, update Firebase
        await _user!.updateDisplayName(displayName);
        await _user!.updatePhotoURL(photoURL);
        await _firestoreService.updateUserData(_user!);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update profile.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete Account
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _setError(null);

      if (_isDemoMode) {
        // In demo mode, just clear local session
        await _clearUserSession();
        _user = null;
        _isDemoMode = false;
        notifyListeners();
        return true;
      } else if (_user != null) {
        // If Firebase is available, delete from Firebase
        await _firestoreService.deleteUserData(_user!.uid);
        await _user!.delete();
        // Clear local session
        await _clearUserSession();
        // Clear user
        _user = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to delete account.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your information.';
      case 'user-token-expired':
        return 'Session expired. Please sign in again.';
      case 'requires-recent-login':
        return 'Please sign in again to continue.';
      case 'credential-already-in-use':
        return 'These credentials are already associated with another account.';
      case 'popup-closed-by-user':
        return 'Sign-in was cancelled. Please try again.';
      case 'popup-blocked':
        return 'Popup blocked. Please allow popups and try again.';
      default:
        return e.message ?? 'An unexpected error occurred. Please try again.';
    }
  }
}
