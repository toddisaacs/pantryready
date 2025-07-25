#!/bin/bash

# Backward compatibility wrapper for the new unified run.sh script
# Usage: ./scripts/run_dev.sh [target]
# Example: ./scripts/run_dev.sh chrome

TARGET=${1:-}

if [ -z "$TARGET" ]; then
    ./scripts/run.sh dev
else
    ./scripts/run.sh dev "$TARGET"
fi
