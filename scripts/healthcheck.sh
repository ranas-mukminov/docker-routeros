#!/bin/sh
# Health check script for RouterOS container
# Checks if RouterOS is running and responsive by testing SSH port availability

# Default port to check (SSH)
PORT="${HEALTHCHECK_PORT:-22}"
HOST="${HEALTHCHECK_HOST:-127.0.0.1}"
TIMEOUT="${HEALTHCHECK_TIMEOUT:-5}"

# Use netcat to check if the port is open
# -z: zero-I/O mode (scanning)
# -w: timeout in seconds
if nc -z -w "$TIMEOUT" "$HOST" "$PORT" 2>/dev/null; then
    echo "RouterOS is healthy: port $PORT is reachable"
    exit 0
else
    echo "RouterOS is unhealthy: port $PORT is not reachable"
    exit 1
fi
