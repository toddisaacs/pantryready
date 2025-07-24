#!/bin/bash
echo "🚀 Building for LOCAL development..."
flutter build web \
  --dart-define=ENVIRONMENT=local \
  --dart-define=DATA_SOURCE=mock \
  --dart-define=FIRESTORE_PROFILE=dev \
  --release
echo "✅ LOCAL build completed!"
