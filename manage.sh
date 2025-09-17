#!/bin/sh

# Validate input arguments
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  echo "usage: manage.sh <operation> [network]"
  echo "  operation: run | stop | clear"
  echo "  network: mainnet (default) | sepolia"
  exit 100
fi

# The first argument specifies the operation (e.g., run, stop, clear)
OPERATION="$1"

# Validate the operation
case "$OPERATION" in
  run|stop|clear)
    ;; # If the operation is valid, continue
  *)
    echo "invalid operation: $OPERATION. Available operations: run, stop, clear"
    exit 101
    ;;
esac

# The second argument specifies the network, defaulting to "mainnet" if not provided
NETWORK="${2:-mainnet}" # If the second parameter is empty, use "mainnet" as the default
if [ "$NETWORK" = "mainnet" ]; then
  CONFIG_FILE="docker-compose.yml"
elif [ "$NETWORK" = "sepolia" ]; then
  CONFIG_FILE="docker-compose.sepolia.yml"
else
  echo "invalid network name: $NETWORK"
  exit 102
fi

# Execute the Docker Compose command based on the operation
if [ "$OPERATION" = "run" ]; then
  docker compose -f $CONFIG_FILE up -d
elif [ "$OPERATION" = "stop" ]; then
  docker compose -f $CONFIG_FILE stop
elif [ "$OPERATION" = "clear" ]; then
  docker compose -f $CONFIG_FILE down
fi
