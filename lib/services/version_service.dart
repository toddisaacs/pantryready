import 'package:flutter/foundation.dart';
import 'package:pantryready/constants/app_constants.dart';

/// Service for managing app versioning and providing version information
class VersionService {
  /// Get the current app version string
  static String get versionString => AppConstants.versionString;

  /// Get the clean display version (without build number)
  static String get displayVersion => AppConstants.displayVersion;

  /// Get the app version (MAJOR.MINOR.PATCH)
  static String get version => AppConstants.appVersion;

  /// Get the build number
  static String get buildNumber => AppConstants.appBuildNumber;

  /// Get the app name
  static String get appName => AppConstants.appName;

  /// Get user agent string for API calls
  static String get userAgent => AppConstants.userAgent;

  /// Get detailed version info for debugging
  static Map<String, String> get versionInfo => {
    'app_name': appName,
    'version': version,
    'build_number': buildNumber,
    'version_string': versionString,
    'user_agent': userAgent,
    'environment': _getEnvironmentString(),
    'data_source': _getDataSourceString(),
    'flutter_version': _getFlutterVersion(),
  };

  /// Get environment string for version tracking
  static String _getEnvironmentString() {
    if (kReleaseMode) {
      return 'production';
    } else if (kDebugMode) {
      return 'debug';
    } else {
      return 'profile';
    }
  }

  /// Get data source string for version tracking
  static String _getDataSourceString() {
    // This would need to be updated to get from your environment config
    return 'mock'; // Default for now
  }

  /// Get Flutter version for debugging
  static String _getFlutterVersion() {
    // This would need to be updated to get actual Flutter version
    return '3.7.0+'; // Default for now
  }

  /// Check if this is a new version (for analytics)
  static bool isNewVersion() {
    // Implementation would check against stored version
    return true; // Default for now
  }

  /// Log version information for debugging
  static void logVersionInfo() {
    debugPrint('=== App Version Information ===');
    debugPrint('App: $versionString');
    debugPrint('Environment: ${_getEnvironmentString()}');
    debugPrint('Data Source: ${_getDataSourceString()}');
    debugPrint('User Agent: $userAgent');
    debugPrint('==============================');
  }

  /// Get version info for crash reporting
  static Map<String, dynamic> getCrashReportInfo() {
    return {
      'app_version': version,
      'build_number': buildNumber,
      'environment': _getEnvironmentString(),
      'data_source': _getDataSourceString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
