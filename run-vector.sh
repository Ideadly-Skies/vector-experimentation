#!/bin/bash
cd "$(dirname "$0")"
# Prefer the known install location, fall back to PATH
if [ -x "/usr/local/bin/vector" ]; then
	VECTOR_BIN="/usr/local/bin/vector"
elif command -v vector >/dev/null 2>&1; then
	VECTOR_BIN="$(command -v vector)"
else
	echo "Error: vector binary not found in /usr/local/bin or PATH" >&2
	exit 1
fi

exec "$VECTOR_BIN" --config vector.yaml