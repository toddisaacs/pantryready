#!/bin/bash

# Run the app locally with mock data (default for development and testing)
# This provides consistent sample data that resets on every run
echo "🚀 Running PantryReady locally with mock data..."
echo "📝 This includes sample data for testing and development"

# Backward compatibility wrapper for the new unified run.sh script
# Usage: ./scripts/run_local.sh [target]
# Example: ./scripts/run_local.sh chrome

TARGET=${1:-}

if [ -z "$TARGET" ]; then
    ./scripts/run.sh local
else
    ./scripts/run.sh local "$TARGET"
fi
