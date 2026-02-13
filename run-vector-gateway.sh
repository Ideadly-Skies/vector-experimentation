#!/bin/bash

# Check if Vector is available at common locations
if [ -x "/usr/local/bin/vector" ]; then
    VECTOR_BIN="/usr/local/bin/vector"
elif command -v vector &> /dev/null; then
    VECTOR_BIN="vector"
else
    echo "Error: Vector binary not found!"
    echo "Please install Vector or add it to your PATH"
    exit 1
fi

echo "Starting Vector Gateway..."
echo "Using: $VECTOR_BIN"
echo "Config: vector-gateway.yaml"
echo "Listening on: http://localhost:8686"
echo ""

# Run Vector with gateway configuration
exec "$VECTOR_BIN" --config vector-gateway.yaml
