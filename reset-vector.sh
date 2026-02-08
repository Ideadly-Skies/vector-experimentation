#!/bin/bash

# Reset Vector - Clear checkpoint data to re-process logs from beginning

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "================================================"
echo "Vector Reset - Clear Checkpoint Data"
echo "================================================"
echo

# Stop Vector if running
echo "Stopping any running Vector processes..."
pkill -f "vector --config vector.yaml" 2>/dev/null || true
sleep 1
echo "✅ Vector processes stopped"
echo

# Clear checkpoint data
if [ -d "vector-data" ]; then
    echo "Clearing checkpoint data from vector-data/..."
    rm -rf vector-data/*
    echo "✅ Checkpoint data cleared"
else
    echo "⚠️  vector-data directory not found"
    mkdir -p vector-data
    echo "✅ vector-data directory created"
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
