#!/bin/bash
echo "🚀 Running in LOCAL development mode..."
flutter run \
  --dart-define=ENVIRONMENT=local \
  --dart-define=DATA_SOURCE=mock \
  --dart-define=FIRESTORE_PROFILE=dev \
  -d chrome --web-port=8080
