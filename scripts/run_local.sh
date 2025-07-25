#!/bin/bash

# Backward compatibility wrapper for the new unified run.sh script
# Usage: ./scripts/run_local.sh [target]
# Example: ./scripts/run_local.sh chrome

TARGET=${1:-}

if [ -z "$TARGET" ]; then
    ./scripts/run.sh local
else
    ./scripts/run.sh local "$TARGET"
fi
