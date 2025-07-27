#!/bin/bash

# Run the app with empty local data (no mock data)
echo "🚀 Running PantryReady with empty local data..."
echo "📝 This starts with an empty inventory for testing fresh data scenarios"

flutter run --debug --dart-define=USE_EMPTY_DATA=true 