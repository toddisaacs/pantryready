#!/bin/bash
echo "🚀 Running in DEV environment..."
flutter run \
  --dart-define=ENVIRONMENT=dev \
  --dart-define=DATA_SOURCE=firestore \
  --dart-define=FIRESTORE_PROFILE=dev \
  -d chrome --web-port=8080
