# 🏠 PantryReady

[![Flutter CI](https://github.com/toddisaacs/pantryready/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/toddisaacs/pantryready/actions/workflows/flutter-ci.yml)
[![codecov](https://codecov.io/gh/toddisaacs/pantryready/branch/main/graph/badge.svg)](https://codecov.io/gh/toddisaacs/pantryready)

A Flutter app for managing your pantry inventory with barcode scanning and product lookup.

## ✨ Features

- **📱 Inventory Management**: Add, edit, and delete pantry items
- **📊 Barcode Scanning**: Scan product barcodes to auto-fill product information
- **🔍 Product Lookup**: Integration with Open Food Facts API for product details
- **☁️ Cloud Storage**: Optional Firebase Firestore integration for data sync
- **📱 Cross-Platform**: Works on iOS, Android, Web, and Desktop
- **🎨 Modern UI**: Clean, intuitive interface with Material Design

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.7.0 or higher)
- Dart SDK
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd pantryready
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase (Optional)**
   ```bash
   # Run the setup script
   chmod +x scripts/setup_firebase.sh
   ./scripts/setup_firebase.sh
   ```
   Choose option 1 for development without Firebase, or option 2 for Firebase setup.

4. **Configure firebase.json (if using Firebase)**
   - Copy the template and fill in your real values:
     ```bash
     cp firebase.json.template firebase.json
     # Edit firebase.json and add your real Firebase project/app IDs
     ```
   - **Never commit your real firebase.json!**

### Version Management

The app uses semantic versioning (MAJOR.MINOR.PATCH) for easy issue tracking and release management.

#### **Current Version: 1.0.0+1**

#### **Version Components:**
- **MAJOR** (1): Breaking changes, major feature releases
- **MINOR** (0): New features, backward compatible  
- **PATCH** (0): Bug fixes, backward compatible
- **BUILD** (1): Build number for tracking

#### **Version Management Commands:**
```bash
# Check current version
./scripts/version.sh

# Increment versions
./scripts/version.sh patch    # 1.0.0 -> 1.0.1
./scripts/version.sh minor    # 1.0.0 -> 1.1.0
./scripts/version.sh major    # 1.0.0 -> 2.0.0

# Preview changes
./scripts/version.sh patch --dry-run

# Commit with automatic version bump
./scripts/commit_with_version.sh major "Breaking change: refactor inventory model"
./scripts/commit_with_version.sh minor "Add new barcode scanning feature"
./scripts/commit_with_version.sh patch "Fix crash in item editing"
```

#### **Version Information in App:**
- Version info is displayed in Settings screen
- Version string is included in app title
- Version info is logged on app startup
- Version tracking helps identify issues by version

### Running the App

The app supports different data configurations for development and testing:

#### 🎭 **Mock Data (Default - Recommended for Development)**
```bash
# Run with sample data that resets on every run
flutter run --debug
# OR
./scripts/run_local.sh
```
- ✅ **Best for**: Development, manual testing, automated testing
- ✅ **Benefits**: Consistent sample data, reproducible test scenarios
- 📝 **Data**: 8 sample pantry items with realistic data

#### 📂 **Empty Local Data**
```bash
# Run with empty inventory (starts fresh)
flutter run --debug --dart-define=USE_EMPTY_DATA=true
# OR
./scripts/run_empty.sh
```
- ✅ **Best for**: Testing fresh user experience, data entry workflows
- ✅ **Benefits**: Clean slate, test real user onboarding
- 📝 **Data**: Empty inventory, add your own items

#### 🧹 **Clean Output (Suppressed Warnings)**
```bash
# Run with warnings suppressed for cleaner output
./scripts/run_clean.sh
```
- ✅ **Best for**: Development with minimal console noise
- ✅ **Benefits**: Suppresses font and lifecycle warnings
- 📝 **Note**: Warnings are still logged but filtered from output

## 🏗️ Build & Deployment

### Development Builds

**Simplified Run Script (Recommended):**
```bash
# Default: dev environment with device selection
./scripts/run.sh

# Specific environment with device selection
./scripts/run.sh dev
./scripts/run.sh local
./scripts/run.sh prod

# Specific environment and target
./scripts/run.sh dev chrome
./scripts/run.sh local ios
./scripts/run.sh prod android
```

**Legacy Scripts (Still Available):**
```bash
# Local development (mock data)
./scripts/run_local.sh

# Development with Firestore
./scripts/run_dev.sh

# Production with Firestore
./scripts/run_prod.sh
```

### Production Builds

#### Production Web Build
```bash
# Build for production (uses PROD Firestore profile)
./scripts/build_prod.sh

# Or manually:
flutter build web \
  --dart-define=ENVIRONMENT=prod \
  --dart-define=DATA_SOURCE=firestore \
  --dart-define=FIRESTORE_PROFILE=prod \
  --release
```

#### Development Web Build
```bash
# Build for development environment
./scripts/build_dev.sh

# Or manually:
flutter build web \
  --dart-define=ENVIRONMENT=dev \
  --dart-define=DATA_SOURCE=firestore \
  --dart-define=FIRESTORE_PROFILE=dev \
  --release
```

#### Local Mock Build
```bash
# Build with mock data (no Firebase required)
./scripts/build_local.sh
```

### Environment Configuration

The app supports three environments:

| Environment | Data Source | Firestore Profile | Environment Settings UI |
|-------------|-------------|-------------------|------------------------|
| **LOCAL** | Mock Data | N/A | ✅ Visible (Debug) |
| **DEV** | Firestore | `pantry_items_dev` | ✅ Visible (Debug) |
| **PROD** | Firestore | `pantry_items_prod` | ❌ Hidden |

### Build Arguments

You can customize builds using these dart-define arguments:

- `ENVIRONMENT`: `local`, `dev`, `prod`
- `DATA_SOURCE`: `mock`, `local`, `firestore`
- `FIRESTORE_PROFILE`: `dev`, `prod`, `test`

Example:
```bash
flutter build web \
  --dart-define=ENVIRONMENT=dev \
  --dart-define=DATA_SOURCE=firestore \
  --dart-define=FIRESTORE_PROFILE=test \
  --release
```

## 🔧 Development Setup

### Option 1: Development Without Firebase (Recommended for new developers)

The app works perfectly without Firebase using local storage:

```bash
# Run setup script and choose option 1
./scripts/setup_firebase.sh
# Choose: 1. Use placeholder values (for development without Firebase)
```

### Option 2: Development With Firebase

For full Firebase integration:

1. **Create a Firebase project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Add your apps (Android, iOS, Web)

2. **Set up configuration**
   ```bash
   ./scripts/setup_firebase.sh
   # Choose: 2. Set up with real Firebase project
   ```

3. **Configure firebase.json**
   - Copy the template and fill in your real values:
     ```bash
     cp firebase.json.template firebase.json
     # Edit firebase.json and add your real Firebase project/app IDs
     ```
   - **Never commit your real firebase.json!**

4. **Update Firestore rules**
   - Copy the rules from `firestore_rules.txt` to your Firebase console
   - Or use the provided rules for development

## 📱 Usage

### Adding Items

1. **Manual Entry**: Tap the "+" button and fill in item details
2. **Barcode Scan**: Tap the barcode scanner icon to scan product codes
3. **Product Lookup**: The app will automatically fetch product information from Open Food Facts

### Managing Inventory

- **View Items**: Browse your pantry items in the inventory tab
- **Edit Items**: Tap the edit icon to modify item details
- **Delete Items**: Swipe left on items to delete them
- **Search**: Use the search bar to find specific items

### Settings

- **Storage Mode**: Toggle between local storage and Firestore
- **API Service**: Switch between Open Food Facts and mock data
- **Test Connection**: Verify Firebase connectivity

## 🏗️ Architecture

### Core Components

- **Models**: `PantryItem` - Data structure for inventory items
- **Services**: 
  - `ProductApiService` - Product lookup abstraction
  - `DataService` - Storage abstraction (local/Firestore)
  - `OpenFoodFactsService` - Real product API
  - `MockProductApiService` - Test data
- **Screens**: Home, Inventory, Add Item, Edit Item, Settings
- **Configuration**: Hybrid Firebase setup with environment support

### Data Flow

```
User Input → UI Layer → Service Layer → Storage Layer
                ↓
            Product API → Open Food Facts
                ↓
            Data Service → Local Storage / Firestore
```

## 🔒 Security

### Firebase Configuration

- **Safe for Git**: Template files with placeholder values
- **Excluded Files**: Real Firebase config files are in `.gitignore`
- **firebase.json**: Your real `firebase.json` is ignored by Git. Use `firebase.json.template` for sharing structure.
- **How to use**: Copy `firebase.json.template` to `firebase.json` and fill in your real values locally.
- **Environment Variables**: Support for build-time configuration
- **Setup Script**: Automated configuration management

### Files Excluded from Git

- `lib/firebase_options.dart` - Contains real API keys
- `firebase.json` - Contains real Firebase project/app IDs
- `android/app/google-services.json` - Android Firebase config
- `ios/Runner/GoogleService-Info.plist` - iOS Firebase config
- `firebase.json` - Firebase project configuration

## 🧪 Testing

Run the test suite:

```bash
flutter test
```

Run tests with coverage:

```bash
flutter test --coverage
```

All 47 tests should pass, including:
- Widget tests for UI components
- Service tests for data operations
- Integration tests for barcode functionality

## ✅ Code Quality & CI

### Continuous Integration

The project uses GitHub Actions for automated testing and quality checks. Every push and PR runs:

- ✅ **Code formatting** (`dart format`)
- ✅ **Static analysis** (`flutter analyze`)
- ✅ **Unit & widget tests** (`flutter test`)
- ✅ **Coverage reporting** (uploaded to Codecov)
- ✅ **Dependency audit** (`flutter pub outdated`)

View CI results in the [Actions tab](https://github.com/tisaacs/pantryready/actions).

### Pre-commit Hooks

Enable pre-commit checks to catch issues before pushing:

```bash
# Enable git hooks
git config core.hooksPath .githooks
```

The pre-commit hook runs:
- Code formatting checks
- Flutter analyze
- All tests

To bypass (not recommended):
```bash
git commit --no-verify
```

### Code Quality Tools

**Format code:**
```bash
dart format .
```

**Analyze code:**
```bash
flutter analyze
```

**Check outdated dependencies:**
```bash
flutter pub outdated
```

**Generate coverage locally:**
```bash
flutter test --coverage
# View with lcov (install: brew install lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Lint Rules

The project uses strict lint rules defined in [analysis_options.yaml](analysis_options.yaml):

- **Code style:** Single quotes, const constructors, final fields
- **Error prevention:** No print statements, cancel subscriptions, close sinks
- **Best practices:** Return types, key in widgets, trailing commas
- **Readability:** Consistent formatting, super parameters

To temporarily disable a lint:
```dart
// ignore: rule_name
final value = something();
```

### Coverage Setup

To see coverage badges in your README:

1. Sign up at [codecov.io](https://codecov.io) with your GitHub account
2. Add the repository to Codecov
3. Get your upload token from Settings → General
4. Add the token to GitHub: Settings → Secrets → Actions → New repository secret
   - Name: `CODECOV_TOKEN`
   - Value: Your token from Codecov
5. The workflow will automatically upload coverage on every push

## 📚 Documentation

- **Firebase Setup**: See `FIREBASE_CONFIGURATION.md`
- **API Integration**: See `FIREBASE_SETUP_GUIDE.md`
- **Development**: See inline code comments

## 🛠️ Development

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── screens/                  # UI screens
├── services/                 # Business logic
├── constants/                # App constants
└── config/                   # Configuration management

scripts/
└── setup_firebase.sh        # Firebase setup script

test/
├── widget_test.dart          # Basic widget tests
└── screens/                  # Screen-specific tests
```

### Key Dependencies

- **firebase_core**: ^3.8.0 - Firebase initialization
- **cloud_firestore**: ^5.4.0 - Cloud database
- **mobile_scanner**: ^7.0.1 - Barcode scanning
- **openfoodfacts**: ^3.24.0 - Product API
- **http**: ^1.4.0 - HTTP requests

### Environment Variables

For production builds:

```bash
flutter build web \
  --dart-define=USE_FIREBASE=true \
  --dart-define=FIREBASE_PROJECT_ID=your-project-id \
  --dart-define=FIREBASE_API_KEY=your-api-key
```

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**
4. **Run tests**: `flutter test`
5. **Commit your changes**: `git commit -m 'Add amazing feature'`
6. **Push to the branch**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**

### Development Guidelines

- **Never commit real Firebase configuration**
- **Never commit your real firebase.json**
- **Use placeholder values for development**
- **Test both with and without Firebase**
- **Follow Flutter best practices**
- **Write tests for new features**

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

- **Issues**: Create an issue on GitHub
- **Documentation**: Check the Firebase configuration guide
- **Setup Help**: Run `./scripts/setup_firebase.sh` for guided setup

## 🎯 Roadmap

- [ ] User authentication
- [ ] Shopping list integration
- [ ] Expiry date notifications
- [ ] Recipe suggestions
- [ ] Nutritional information
- [ ] Multi-language support
- [ ] Offline mode improvements
- [ ] Advanced search filters
