# Environment-Based Data Architecture

## Overview

The PantryReady app now supports a flexible, environment-based data architecture that allows developers to seamlessly switch between different data sources and environments without code changes. This system provides:

- **Local Development**: Mock data with seeded sample items
- **Development Environment**: Firestore with DEV profile
- **Production Environment**: Firestore with PROD profile
- **Easy Switching**: Runtime environment configuration
- **Seeded Data**: Pre-populated sample data for testing

## Architecture Components

### 1. Environment Configuration (`lib/config/environment_config.dart`)

Central configuration management that controls:
- **Environment**: `local`, `dev`, `prod`
- **Data Source**: `mock`, `local`, `firestore`
- **Firestore Profile**: `dev`, `prod`, `test`

```dart
// Configure for local development
EnvironmentConfig.configureForLocalDevelopment();

// Configure for development environment
EnvironmentConfig.configureForDev();

// Configure for production environment
EnvironmentConfig.configureForProd();
```

### 2. Data Service Factory (`lib/services/data_service_factory.dart`)

Factory pattern that creates the appropriate data service based on configuration:

```dart
// Get data service for current configuration
DataService dataService = DataServiceFactory.getDataService();

// Switch data source
DataService newService = DataServiceFactory.switchDataSource(DataSource.firestore);

// Configure for specific environment
DataService envService = DataServiceFactory.configureForEnvironment(Environment.dev);
```

### 3. Data Services

#### Mock Data Service (`lib/services/mock_data_service.dart`)
- Provides seeded sample data for local development
- No external dependencies
- Real-time updates via StreamController
- Includes 10 sample pantry items with realistic data

#### Local Data Service (`lib/services/data_service.dart`)
- In-memory storage for testing
- Simple list-based implementation
- No persistence

#### Environment Firestore Service (`lib/services/environment_firestore_service.dart`)
- Firestore with environment-specific collections
- Profile-based collection naming: `pantry_items_{profile}`
- Supports multiple Firestore profiles (dev, prod, test)

## Usage Patterns

### Development Workflow

1. **Local Development** (Default)
   ```dart
   // App starts with mock data
   EnvironmentConfig.configureForLocalDevelopment();
   DataService dataService = DataServiceFactory.getDataService();
   ```

2. **Development Environment**
   ```dart
   // Switch to DEV Firestore
   EnvironmentConfig.configureForDev();
   DataService dataService = DataServiceFactory.getDataService();
   ```

3. **Production Environment**
   ```dart
   // Switch to PROD Firestore
   EnvironmentConfig.configureForProd();
   DataService dataService = DataServiceFactory.getDataService();
   ```

### Runtime Environment Switching

The app includes an Environment Settings screen that allows runtime switching:

```dart
// Navigate to environment settings
Navigator.pushNamed(context, '/environment-settings');
```

### Firestore Profiles

Each environment uses separate Firestore collections:

- **DEV**: `pantry_items_dev`
- **PROD**: `pantry_items_prod`
- **TEST**: `pantry_items_test`

This ensures complete data isolation between environments.

## Configuration Examples

### Local Development Setup
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Configure for local development by default
  EnvironmentConfig.configureForLocalDevelopment();
  
  runApp(const PantryReadyApp());
}
```

### Environment-Specific Builds
```dart
// Development build
EnvironmentConfig.configureForDev();

// Production build
EnvironmentConfig.configureForProd();
```

### Runtime Switching
```dart
// Switch to Firestore with DEV profile
DataServiceFactory.switchFirestoreProfile('dev');

// Switch to mock data
DataServiceFactory.switchDataSource(DataSource.mock);

// Configure for specific environment
DataServiceFactory.configureForEnvironment(Environment.prod);
```

## Data Seeding

### Mock Data Service Seeding
The MockDataService automatically seeds 10 sample items:

1. **Canned Beans** - 12 cans, Canned Goods
2. **Rice** - 5 lbs, Grains
3. **Bottled Water** - 24 bottles, Beverages
4. **Pasta** - 8 boxes, Grains
5. **Peanut Butter** - 3 jars, Condiments
6. **Pinto Beans** - 2 lbs, Grains
7. **Canned Tomatoes** - 6 cans, Canned Goods
8. **Olive Oil** - 1 bottle, Condiments
9. **Frozen Vegetables** - 4 bags, Frozen Foods
10. **Cereal** - 2 boxes, Grains

### Firestore Seeding
```dart
// Seed Firestore with sample data
final firestoreService = EnvironmentFirestoreService();
await firestoreService.seedData(sampleItems);
```

## Environment Settings UI

The app includes a comprehensive Environment Settings screen that provides:

- **Environment Selection**: Local, Development, Production
- **Data Source Selection**: Mock, Local, Firestore
- **Firestore Profile Selection**: dev, prod, test
- **Current Configuration Display**: Shows active settings
- **Apply Configuration**: Switch environments at runtime
- **Reset to Default**: Return to local development

## Benefits

### For Developers
1. **No Code Changes**: Switch environments without rebuilding
2. **Isolated Testing**: Separate data for each environment
3. **Fast Development**: Mock data for quick iteration
4. **Real Data Testing**: Easy access to Firestore environments

### For Testing
1. **Consistent Data**: Seeded sample data for reliable tests
2. **Environment Isolation**: No cross-contamination between environments
3. **Easy Reset**: Reset to known state with mock data

### For Production
1. **Environment Separation**: Clear dev/prod data boundaries
2. **Profile Management**: Multiple Firestore profiles
3. **Configuration Control**: Runtime environment switching

## Migration Guide

### From Old Architecture
1. **Remove Direct Service Creation**:
   ```dart
   // Old
   DataService dataService = FirestoreDataService();
   
   // New
   DataService dataService = DataServiceFactory.getDataService();
   ```

2. **Use Environment Configuration**:
   ```dart
   // Old
   bool useFirestore = true;
   
   // New
   EnvironmentConfig.configureForDev();
   ```

3. **Update Settings UI**:
   ```dart
   // Old: Toggle switches
   // New: Environment Settings screen
   Navigator.pushNamed(context, '/environment-settings');
   ```

## Best Practices

### Development
1. **Start with Mock Data**: Use local development for initial development
2. **Test with Real Data**: Switch to DEV environment for integration testing
3. **Use Environment Settings**: Leverage the UI for easy switching

### Testing
1. **Use Mock Data**: Reliable, fast tests with seeded data
2. **Isolate Environments**: Never test against production data
3. **Reset State**: Use reset functionality to return to known state

### Production
1. **Use PROD Profile**: Always use production Firestore profile
2. **Validate Configuration**: Ensure correct environment settings
3. **Monitor Data**: Track data usage and performance

## Troubleshooting

### Common Issues

1. **Firestore Connection Errors**
   - Ensure Firebase is properly initialized
   - Check Firestore security rules
   - Verify collection names match profile

2. **Data Not Loading**
   - Check environment configuration
   - Verify data service is properly initialized
   - Check console for debug messages

3. **Environment Switching Not Working**
   - Ensure DataServiceFactory is used
   - Check that configuration is applied
   - Verify UI updates after switching

### Debug Information
```dart
// Get current service info
String info = DataServiceFactory.getCurrentServiceInfo();
print(info); // "MockDataService - mock - local - dev"

// Get full configuration
String config = EnvironmentConfig.getFullConfig();
print(config); // "LOCAL_MOCK_DEV"
```

## Future Enhancements

1. **Persistent Configuration**: Save environment preferences
2. **Environment Variables**: Support for build-time configuration
3. **Multiple Mock Datasets**: Different seed data for different scenarios
4. **Data Migration**: Tools for moving data between environments
5. **Environment Validation**: Automatic validation of environment setup 