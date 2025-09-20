import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Mock authentication service for demo purposes
/// This simulates Google Sign-In when using demo Firebase configuration
class MockAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Simulate Google Sign-In for demo purposes
  static Future<UserCredential?> simulateGoogleSignIn() async {
    try {
      // Create a demo user credential for testing
      const String demoDisplayName = 'Demo User';

      // Simulate successful authentication with a delay
      await Future.delayed(const Duration(seconds: 1));

      // Try anonymous auth first (works with most Firebase configs)
      try {
        final UserCredential result = await _auth.signInAnonymously();

        if (result.user != null) {
          // Update the user profile with demo data
          await result.user!.updateDisplayName(demoDisplayName);
          return result;
        }
      } catch (authError) {
        debugPrint('Anonymous auth failed: $authError');
        // If Firebase auth completely fails, we'll handle this in the provider
        throw Exception('Demo authentication temporarily unavailable');
      }

      return null;
    } catch (e) {
      debugPrint('Mock Google Sign-In error: $e');
      rethrow; // Let the provider handle the error properly
    }
  }

  /// Check if we should use mock authentication (when using demo Firebase config)
  static bool shouldUseMockAuth() {
    // Now we have proper Firebase config, so disable mock auth
    return false; // Disabled - using real Firebase
  }
}
