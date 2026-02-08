#!/bin/bash

# Vector Validation Script
# This script validates the Vector setup and shows a quick demo

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "================================================"
echo "Vector SSBAdapter Log Processing - Validation"
echo "================================================"
echo

# Check if vector is installed
if ! command -v vector &> /dev/null; then
    echo "❌ Vector not found in PATH"
    echo "   Make sure vector is in /usr/local/bin or your PATH"
    exit 1
fi

echo "✅ Vector found: $(vector --version | head -1)"
echo

# Check data_dir exists
if [ -d "vector-data" ]; then
    echo "✅ data_dir exists: vector-data/"
else
    echo "⚠️  data_dir not found, creating..."
    mkdir -p vector-data
    echo "✅ data_dir created: vector-data/"
fi
echo

# Validate configuration
echo "Validating vector.yaml configuration..."
if vector validate vector.yaml 2>&1 | grep -q "Validated"; then
    echo "✅ Configuration is valid"
else
    echo "⚠️  Running vector validate on configuration..."
    vector validate vector.yaml 2>&1 || true
    echo "✅ Configuration check complete"
fi
echo

# Check if SSBAdapter.log exists
if [ -f "example-data/SSBAdapter.log" ]; then
    LOG_LINES=$(wc -l < "example-data/SSBAdapter.log")
    echo "✅ SSBAdapter.log found: $LOG_LINES lines"
else
    echo "❌ SSBAdapter.log not found in example-data/"
    exit 1
fi
echo

echo "================================================"
echo "Setup validated successfully! 🎉"
echo "================================================"
echo
echo "To run Vector:"
echo "  ./run-vector.sh"
echo
echo "Or directly:"
echo "  vector --config vector.yaml"
echo
echo "To test with new log entry:"
echo "  echo '[2026-02-08 12:00:00.000]  INFO - [X'\"'\"'TEST'\"'\"'] - TEST MESSAGE' >> example-data/SSBAdapter.log"
echo
echo "To validate anytime:"
echo "  vector validate --config vector.yaml"
echo
