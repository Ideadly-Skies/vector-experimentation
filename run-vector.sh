#!/bin/bash
cd "$(dirname "$0")"

# Load environment variables from .env file
if [ -f ".env" ]; then
    echo "Loading environment variables from .env file..."
    set -a  # automatically export all variables
    source .env
    set +a
else
    echo "Warning: .env file not found. Using default values."
fi

# Prefer the known install location, fall back to PATH
if [ -x "/usr/local/bin/vector" ]; then
	VECTOR_BIN="/usr/local/bin/vector"
elif command -v vector >/dev/null 2>&1; then
	VECTOR_BIN="$(command -v vector)"
else
	echo "Error: vector binary not found in /usr/local/bin or PATH" >&2
	exit 1
fi

echo "Starting Vector Agent..."
echo "Using: $VECTOR_BIN"
echo "Gateway: ${VECTOR_GATEWAY_PROTOCOL:-https}://${VECTOR_GATEWAY_HOST:-localhost}:${VECTOR_GATEWAY_PORT:-8686}"
echo "TLS Enabled: ${TLS_VERIFY_CERTIFICATE:-true}"
echo ""

exec "$VECTOR_BIN" --config vector.yaml