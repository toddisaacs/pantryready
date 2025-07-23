#!/bin/bash

# Firebase Setup Script for PantryReady
# This script helps developers set up Firebase configuration

set -e

echo "🚀 Firebase Setup for PantryReady"
echo "=================================="

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Create config directory if it doesn't exist
mkdir -p lib/config

echo ""
echo "📋 Current Configuration Status:"
echo "================================"

# Check if firebase_options.dart exists and has real values
if [ -f "lib/firebase_options.dart" ]; then
    if grep -q "your-project-id" lib/firebase_options.dart; then
        echo "⚠️  Firebase is configured with placeholder values"
        echo "   Run this script to set up real Firebase configuration"
    else
        echo "✅ Firebase is configured with real values"
        echo "   Your app should work with Firebase"
    fi
else
    echo "❌ Firebase configuration file not found"
    echo "   Run this script to create configuration"
fi

echo ""
echo "🔧 Setup Options:"
echo "=================="
echo "1. Use placeholder values (for development without Firebase)"
echo "2. Set up with real Firebase project"
echo "3. View current configuration"
echo "4. Exit"

read -p "Choose an option (1-4): " choice

case $choice in
    1)
        echo ""
        echo "📝 Setting up with placeholder values..."
        
        # Copy template to actual file
        if [ -f "lib/firebase_options_template.dart" ]; then
            cp lib/firebase_options_template.dart lib/firebase_options.dart
            echo "✅ Created lib/firebase_options.dart with placeholder values"
        else
            echo "❌ Template file not found. Creating basic placeholder..."
            cat > lib/firebase_options.dart << 'EOF'
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
/// 
/// IMPORTANT: This file contains placeholder values for development.
/// For production, replace with real Firebase configuration.

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your-api-key',
    appId: 'your-app-id',
    messagingSenderId: '123456789',
    projectId: 'your-project-id',
    authDomain: 'your-project-id.firebaseapp.com',
    storageBucket: 'your-project-id.appspot.com',
    measurementId: 'G-XXXXXXXXXX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-api-key',
    appId: 'your-app-id',
    messagingSenderId: '123456789',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-api-key',
    appId: 'your-app-id',
    messagingSenderId: '123456789',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
    iosBundleId: 'com.example.pantryready',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-api-key',
    appId: 'your-app-id',
    messagingSenderId: '123456789',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
    iosBundleId: 'com.example.pantryready',
  );
}
EOF
            echo "✅ Created lib/firebase_options.dart with placeholder values"
        fi
        
        echo ""
        echo "🎉 Setup complete! Your app will run without Firebase."
        echo "   To enable Firebase later, run this script again and choose option 2."
        ;;
        
    2)
        echo ""
        echo "🔥 Setting up with real Firebase project..."
        echo ""
        echo "To set up Firebase:"
        echo "1. Go to https://console.firebase.google.com/"
        echo "2. Create a new project or select existing project"
        echo "3. Add your apps (Android, iOS, Web)"
        echo "4. Download the configuration files"
        echo "5. Replace the placeholder values in lib/firebase_options.dart"
        echo ""
        echo "For FlutterFire CLI setup:"
        echo "1. Install FlutterFire CLI: dart pub global activate flutterfire_cli"
        echo "2. Run: flutterfire configure"
        echo "3. This will automatically update lib/firebase_options.dart"
        echo ""
        read -p "Press Enter when you're ready to continue..."
        
        # Check if FlutterFire CLI is available
        if command -v flutterfire &> /dev/null; then
            echo "🚀 FlutterFire CLI detected! Running configuration..."
            flutterfire configure
        else
            echo "📝 Manual setup required. Please follow the steps above."
            echo "   After setup, your lib/firebase_options.dart should contain real values."
        fi
        ;;
        
    3)
        echo ""
        echo "📊 Current Configuration:"
        echo "========================="
        if [ -f "lib/firebase_options.dart" ]; then
            echo "Firebase Options File: ✅ Found"
            if grep -q "your-project-id" lib/firebase_options.dart; then
                echo "Configuration: ⚠️  Placeholder values"
            else
                echo "Configuration: ✅ Real values"
            fi
        else
            echo "Firebase Options File: ❌ Not found"
        fi
        
        if [ -f "lib/config/firebase_config.dart" ]; then
            echo "Config Management: ✅ Found"
        else
            echo "Config Management: ❌ Not found"
        fi
        ;;
        
    4)
        echo "👋 Goodbye!"
        exit 0
        ;;
        
    *)
        echo "❌ Invalid option. Please choose 1-4."
        exit 1
        ;;
esac

echo ""
echo "✅ Setup complete!" 