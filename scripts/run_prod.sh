#!/bin/bash

# Backward compatibility wrapper for the new unified run.sh script
# Usage: ./scripts/run_prod.sh [target]
# Example: ./scripts/run_prod.sh chrome

TARGET=${1:-}

if [ -z "$TARGET" ]; then
    ./scripts/run.sh prod
else
    ./scripts/run.sh prod "$TARGET"
fi 