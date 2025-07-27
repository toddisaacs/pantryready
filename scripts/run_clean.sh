#!/bin/bash

# Run the app with warnings suppressed
echo "🚀 Running PantryReady with clean output..."
echo "📝 This suppresses common warnings for a cleaner development experience"

# Run with warnings suppressed
flutter run --debug --suppress-analytics 2>&1 | grep -v "Could not find a set of Noto fonts" | grep -v "flutter/lifecycle channel was discarded" 