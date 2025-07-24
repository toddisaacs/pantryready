#!/bin/bash
echo "🚀 Building for PRODUCTION environment..."
flutter build web \
  --dart-define=ENVIRONMENT=prod \
  --dart-define=DATA_SOURCE=firestore \
  --dart-define=FIRESTORE_PROFILE=prod \
  --release
echo "✅ PRODUCTION build completed!"
