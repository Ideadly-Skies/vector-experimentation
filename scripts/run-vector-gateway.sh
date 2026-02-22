#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Change to project root (parent directory)
cd "$SCRIPT_DIR/.."

# Load environment variables from .env file
if [ -f ".env" ]; then
    echo "Loading environment variables from .env file..."
    set -a  # automatically export all variables
    source .env
    set +a
else
    echo "Warning: .env file not found. Using default values."
fi

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
echo "Config: gateway/ (modular configuration)"
echo "Listening on: ${VECTOR_GATEWAY_PROTOCOL:-https}://${VECTOR_GATEWAY_ADDRESS:-0.0.0.0}:${VECTOR_GATEWAY_PORT:-8686}"
echo "TLS Certificate: ${TLS_GATEWAY_CERT_FILE:-./certs/gateway.crt}"
echo "TLS Key: ${TLS_GATEWAY_KEY_FILE:-./certs/gateway.key}"
echo ""

# Run Vector with gateway configuration
exec "$VECTOR_BIN" \
  --config-yaml gateway/vector.yaml \
  --config-yaml gateway/sources/from_agent.yaml \
  --config-yaml gateway/sinks/console_output.yaml
