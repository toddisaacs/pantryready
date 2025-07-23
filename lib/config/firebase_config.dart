import 'package:flutter/foundation.dart';

/// Firebase configuration management
///
/// This class handles Firebase configuration for different environments.
/// It can be extended to support environment variables, build-time configuration,
/// or other configuration management strategies.
class FirebaseConfig {
  /// Whether to use Firebase in the current environment
  static const bool useFirebase = bool.fromEnvironment(
    'USE_FIREBASE',
    defaultValue: false, // Default to false for safety
  );

  /// Firebase project ID
  static const String projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'your-project-id',
  );

  /// Firebase API key
  static const String apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'your-api-key',
  );

  /// Firebase app ID
  static const String appId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: 'your-app-id',
  );

  /// Firebase messaging sender ID
  static const String messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '123456789',
  );

  /// Firebase storage bucket
  static const String storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'your-project-id.appspot.com',
  );

  /// Firebase auth domain
  static const String authDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: 'your-project-id.firebaseapp.com',
  );

  /// Firebase measurement ID
  static const String measurementId = String.fromEnvironment(
    'FIREBASE_MEASUREMENT_ID',
    defaultValue: 'G-XXXXXXXXXX',
  );

  /// Check if we're in development mode
  static bool get isDevelopment => kDebugMode;

  /// Check if we're in production mode
  static bool get isProduction => kReleaseMode;

  /// Get configuration status
  static String get status {
    if (!useFirebase) {
      return 'Firebase disabled';
    }
    if (projectId == 'your-project-id') {
      return 'Firebase configured with placeholder values';
    }
    return 'Firebase configured with real values';
  }

  /// Print configuration status for debugging
  static void printStatus() {
    debugPrint('Firebase Config Status:');
    debugPrint('- Use Firebase: $useFirebase');
    debugPrint('- Project ID: $projectId');
    debugPrint(
      '- Environment: ${isDevelopment ? "Development" : "Production"}',
    );
    debugPrint('- Status: $status');
  }
}
