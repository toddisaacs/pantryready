import 'package:flutter/foundation.dart';

enum Environment { local, dev, prod }

enum DataSource { mock, local, firestore }

class EnvironmentConfig {
  static Environment _environment = Environment.local;
  static DataSource _dataSource = DataSource.mock;
  static String _firestoreProfile = 'dev';
  static bool _isProduction = false;

  // Getters
  static Environment get environment => _environment;
  static DataSource get dataSource => _dataSource;
  static String get firestoreProfile => _firestoreProfile;
  static bool get isLocal => _environment == Environment.local;
  static bool get isDev => _environment == Environment.dev;
  static bool get isProd => _environment == Environment.prod;
  static bool get useMockData => _dataSource == DataSource.mock;
  static bool get useLocalData => _dataSource == DataSource.local;
  static bool get useFirestore => _dataSource == DataSource.firestore;
  static bool get isProduction => _isProduction;

  // Setters
  static void setEnvironment(Environment env) {
    _environment = env;
    debugPrint('Environment set to: $env');
  }

  static void setDataSource(DataSource source) {
    _dataSource = source;
    debugPrint('Data source set to: $source');
  }

  static void setFirestoreProfile(String profile) {
    _firestoreProfile = profile;
    debugPrint('Firestore profile set to: $profile');
  }

  static void setProductionMode(bool isProduction) {
    _isProduction = isProduction;
    debugPrint('Production mode set to: $isProduction');
  }

  // Configuration presets
  static void configureForLocalDevelopment() {
    setEnvironment(Environment.local);
    setDataSource(DataSource.mock);
    setProductionMode(false);
    debugPrint('Configured for local development with mock data');
  }

  static void configureForDev() {
    setEnvironment(Environment.dev);
    setDataSource(DataSource.firestore);
    setFirestoreProfile('dev');
    setProductionMode(false);
    debugPrint('Configured for DEV environment');
  }

  static void configureForProd() {
    setEnvironment(Environment.prod);
    setDataSource(DataSource.firestore);
    setFirestoreProfile('prod');
    setProductionMode(true);
    debugPrint('Configured for PROD environment');
  }

  // Build-time configuration
  static void configureFromBuildArgs() {
    // Check for build-time arguments
    const String buildEnv = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'local',
    );
    const String buildDataSource = String.fromEnvironment(
      'DATA_SOURCE',
      defaultValue: 'mock',
    );
    const String buildProfile = String.fromEnvironment(
      'FIRESTORE_PROFILE',
      defaultValue: 'dev',
    );

    // Set environment
    switch (buildEnv.toLowerCase()) {
      case 'local':
        setEnvironment(Environment.local);
        break;
      case 'dev':
        setEnvironment(Environment.dev);
        break;
      case 'prod':
        setEnvironment(Environment.prod);
        break;
    }

    // Set data source
    switch (buildDataSource.toLowerCase()) {
      case 'mock':
        setDataSource(DataSource.mock);
        break;
      case 'local':
        setDataSource(DataSource.local);
        break;
      case 'firestore':
        setDataSource(DataSource.firestore);
        break;
    }

    // Set Firestore profile
    setFirestoreProfile(buildProfile);

    // Set production mode
    setProductionMode(buildEnv.toLowerCase() == 'prod');

    debugPrint(
      'Configured from build args: $buildEnv/$buildDataSource/$buildProfile',
    );
  }

  // Helper methods
  static String getEnvironmentName() {
    switch (_environment) {
      case Environment.local:
        return 'LOCAL';
      case Environment.dev:
        return 'DEV';
      case Environment.prod:
        return 'PROD';
    }
  }

  static String getDataSourceName() {
    switch (_dataSource) {
      case DataSource.mock:
        return 'MOCK';
      case DataSource.local:
        return 'LOCAL';
      case DataSource.firestore:
        return 'FIRESTORE';
    }
  }

  static String getFullConfig() {
    return '${getEnvironmentName()}_${getDataSourceName()}_${_firestoreProfile.toUpperCase()}';
  }

  // Validation
  static bool isValidConfiguration() {
    if (_environment == Environment.local &&
        _dataSource == DataSource.firestore) {
      debugPrint(
        'Warning: Local environment with Firestore data source may cause issues',
      );
      return false;
    }
    return true;
  }

  // Check if environment switching should be allowed
  static bool allowEnvironmentSwitching() {
    return !_isProduction && kDebugMode;
  }
}
