#!/bin/bash

# Default values
ENVIRONMENT=${1:-local}
TARGET=${2:-}

echo "🚀 Running in $ENVIRONMENT development mode..."

# Build the base command
BASE_CMD="flutter run --dart-define=ENVIRONMENT=$ENVIRONMENT"

# Add environment-specific dart defines
if [ "$ENVIRONMENT" = "dev" ]; then
    BASE_CMD="$BASE_CMD --dart-define=DATA_SOURCE=firestore --dart-define=FIRESTORE_PROFILE=dev"
elif [ "$ENVIRONMENT" = "prod" ]; then
    BASE_CMD="$BASE_CMD --dart-define=DATA_SOURCE=firestore --dart-define=FIRESTORE_PROFILE=prod"
elif [ "$ENVIRONMENT" = "local" ]; then
    BASE_CMD="$BASE_CMD --dart-define=DATA_SOURCE=mock"
fi

# Handle target selection
if [ -z "$TARGET" ]; then
    # No target specified - show device selection
    echo "No target specified. Available devices:"
    flutter devices
    echo ""
    echo "Starting with device selection..."
    $BASE_CMD
else
    # Target specified - use it directly
    echo "Using target: $TARGET"
    if [ "$TARGET" = "chrome" ] || [ "$TARGET" = "web" ]; then
        $BASE_CMD -d chrome --web-port=8080
    else
        $BASE_CMD -d $TARGET
    fi
fi
