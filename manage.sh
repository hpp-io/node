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
  run|stop|clear|status)
    ;; # If the operation is valid, continue
  *)
    echo "invalid operation: $OPERATION. Available operations: run, stop, clear, status"
    exit 101
    ;;
esac

# The second argument specifies the network, defaulting to "mainnet" if not provided
NETWORK="${2:-mainnet}" # If the second parameter is empty, use "mainnet" as the default
if [ "$NETWORK" = "mainnet" ]; then
  CONFIG_FILE="docker-compose.yml"
  SNAPSHOT_FILE=hpp-mainnet/snapshot-mainnet.tar
  NODE_CONFIG="hpp-mainnet-node-config.json"
  CONTAINER_NAME="hpp-node-mainnet"
elif [ "$NETWORK" = "sepolia" ]; then
  CONFIG_FILE="docker-compose.sepolia.yml"
  SNAPSHOT_FILE=hpp-sepolia/latest-sepolia.tar
  NODE_CONFIG="hpp-sepolia-node-config.json"
  CONTAINER_NAME="hpp-node-sepolia"
else
  echo "invalid network name: $NETWORK"
  exit 102
fi

# Function to check if container is running
is_running() {
  if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
    return 0 # True
  else
    return 1 # False
  fi
}

# Execute the Docker Compose command based on the operation
if [ "$OPERATION" = "run" ]; then
  if is_running; then
    echo "Warning: $CONTAINER_NAME is already running."
    exit 0
  fi

  MISSING_FILES=""
  [ ! -f "$NODE_CONFIG" ] && MISSING_FILES="$MISSING_FILES $NODE_CONFIG"
  [ ! -f "$SNAPSHOT_FILE" ] && MISSING_FILES="$MISSING_FILES $SNAPSHOT_FILE"

  if [ -n "$MISSING_FILES" ]; then
    echo "Error: The following required files are missing:$MISSING_FILES"
    echo "Please refer to the README.md to download or create them before running the node."
    exit 103
  fi

  docker compose -f $CONFIG_FILE up -d
elif [ "$OPERATION" = "stop" ]; then
  docker compose -f $CONFIG_FILE stop
elif [ "$OPERATION" = "clear" ]; then
  docker compose -f $CONFIG_FILE down
elif [ "$OPERATION" = "status" ]; then
  if is_running; then
    echo "Node ($NETWORK) status: RUNNING"
    docker compose -f $CONFIG_FILE ps
  else
    echo "Node ($NETWORK) status: STOPPED"
  fi
fi
