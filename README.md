# 🏠 PantryReady

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

5. **Run the app**
   ```bash
   flutter run
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

All 60 tests should pass, including:
- Widget tests for UI components
- Service tests for data operations
- Integration tests for barcode functionality

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
