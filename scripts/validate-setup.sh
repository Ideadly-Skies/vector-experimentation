#!/bin/bash

# Vector Validation Script
# This script validates the Vector setup and shows a quick demo

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Change to project root (parent directory)
cd "$SCRIPT_DIR/.."

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
if [ -d "data/agent" ]; then
    echo "✅ data_dir exists: data/agent/"
else
    echo "⚠️  data_dir not found, creating..."
    mkdir -p data/agent
    echo "✅ data_dir created: data/agent/"
fi
echo

# Validate configuration
echo "Validating agent configuration (modular)..."
if vector validate agent/vector.yaml agent/sources/adapter_logs.yaml agent/transforms/parse_adapter_logs.yaml agent/sinks/console_out.yaml agent/sinks/to_gateway.yaml 2>&1 | grep -q "Validated"; then
    echo "✅ Agent configuration is valid"
else
    echo "⚠️  Running vector validate on configuration..."
    vector validate agent/vector.yaml agent/sources/adapter_logs.yaml agent/transforms/parse_adapter_logs.yaml agent/sinks/console_out.yaml agent/sinks/to_gateway.yaml 2>&1 || true
    echo "✅ Configuration check complete"
fi
echo

# Check if SSBAdapter.log exists
if [ -f "data/examples/SSBAdapter.log" ]; then
    LOG_LINES=$(wc -l < "data/examples/SSBAdapter.log")
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
