#!/bin/bash
echo "🚀 Building for DEV environment..."
flutter build web \
  --dart-define=ENVIRONMENT=dev \
  --dart-define=DATA_SOURCE=firestore \
  --dart-define=FIRESTORE_PROFILE=dev \
  --release
echo "✅ DEV build completed!"
