#!/bin/bash

# Reset Vector - Clear checkpoint data to re-process logs from beginning

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Load environment variables from .env file
if [ -f ".env" ]; then
    set -a
    source .env
    set +a
fi

AGENT_DATA_DIR="${VECTOR_AGENT_DATA_DIR:-./vector-data}"
GATEWAY_DATA_DIR="${VECTOR_GATEWAY_DATA_DIR:-./vector-data-gateway}"

echo "================================================"
echo "Vector Reset - Clear Checkpoint Data"
echo "================================================"
echo

# Stop Vector if running
echo "Stopping any running Vector processes..."
pkill -f "vector --config vector.yaml" 2>/dev/null || true
pkill -f "vector --config vector-gateway.yaml" 2>/dev/null || true
sleep 1
echo "✅ Vector processes stopped"
echo

# Clear checkpoint data for agent
if [ -d "$AGENT_DATA_DIR" ]; then
    echo "Clearing checkpoint data from $AGENT_DATA_DIR/..."
    rm -rf "$AGENT_DATA_DIR"/*
    echo "✅ Agent checkpoint data cleared"
else
    echo "⚠️  $AGENT_DATA_DIR directory not found"
    mkdir -p "$AGENT_DATA_DIR"
    echo "✅ $AGENT_DATA_DIR directory created"
fi
echo

# Clear checkpoint data for gateway
if [ -d "$GATEWAY_DATA_DIR" ]; then
    echo "Clearing checkpoint data from $GATEWAY_DATA_DIR/..."
    rm -rf "$GATEWAY_DATA_DIR"/*
    echo "✅ Gateway checkpoint data cleared"
else
    echo "⚠️  $GATEWAY_DATA_DIR directory not found"
    mkdir -p "$GATEWAY_DATA_DIR"
    echo "✅ $GATEWAY_DATA_DIR directory created"
fi
echo

echo "================================================"
echo "Reset complete! 🎉"
echo "================================================"
echo
echo "Vector will now read from the beginning on next run."
echo
echo "To start Vector:"
echo "  ./run-vector.sh"
echo
