#!/bin/sh

# importing init function
if [ -f "./scripts/setup.sh" ]; then
  . ./scripts/setup.sh
fi

# Validate input arguments
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  echo "usage: manage.sh <operation> [network]"
  echo "  operation: init | run | stop | clear | status " #
  echo "  network: mainnet (default) | sepolia"
  exit 100
fi

# The first argument specifies the operation (e.g., run, stop, clear)
OPERATION="$1"

# Validate the operation
case "$OPERATION" in
  init|run|stop|clear|status)
    ;;
  *)
    echo "invalid operation: $OPERATION. Available operations: init, run, stop, clear, status"
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
  DATA_DIR="hpp-mainnet/data"
elif [ "$NETWORK" = "sepolia" ]; then
  CONFIG_FILE="docker-compose.sepolia.yml"
  SNAPSHOT_FILE=hpp-sepolia/snapshot-sepolia.tar
  NODE_CONFIG="hpp-sepolia-node-config.json"
  CONTAINER_NAME="hpp-node-sepolia"
  DATA_DIR="hpp-sepolia/data"
else
  echo "invalid network name: $NETWORK"
  exit 102
fi

# Function to check if any node container is running
check_any_running() {
  RUNNING_CONTAINER=$(docker ps -q -f "name=hpp-node-mainnet" -f "name=hpp-node-sepolia")
  if [ -n "$RUNNING_CONTAINER" ]; then
    # Get the name of the running container for the error message
    RUNNING_NAME=$(docker inspect --format='{{.Name}}' $RUNNING_CONTAINER | sed 's/\///')
    RUNNING_NETWORK=${RUNNING_NAME#hpp-node-}
    return 0 # True, something is running
  else
    return 1 # False, nothing is running
  fi
}

# Execute the Docker Compose command based on the operation
if [ "$OPERATION" = "run" ]; then
  if check_any_running; then
    echo "Error: Cannot start $NETWORK node. Another node ($RUNNING_NAME) is already running."
    echo "Please stop it first using: ./manage.sh stop <network>"
    exit 104
  fi

  MISSING_FILES=""
  [ ! -f "$NODE_CONFIG" ] && MISSING_FILES="$MISSING_FILES $NODE_CONFIG"

  # Check if the data directory is empty, and the snapshot file is required if data is empty.
  if [ ! -d "$DATA_DIR" ] || [ -z "$(ls -A "$DATA_DIR" 2>/dev/null)" ]; then
    if [ ! -f "$SNAPSHOT_FILE" ]; then
      MISSING_FILES="$MISSING_FILES $SNAPSHOT_FILE (required for first run)"
    fi
  else
    # 데이터가 이미 있다면, 도커 볼륨 연결 에러를 방지하기 위해 빈 파일이라도 생성
    if [ ! -f "$SNAPSHOT_FILE" ]; then
      echo "Notice: Creating a dummy snapshot file to satisfy Docker volume requirements."
      touch "$SNAPSHOT_FILE"
    fi
  fi

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
  if check_any_running; then
    echo "Node ($RUNNING_NETWORK) status: RUNNING"
    docker compose -f $CONFIG_FILE ps
  else
    echo "Node status: STOPPED"
  fi
elif [ "$OPERATION" = "init" ]; then
  echo "Initializing configuration of network $NETWORK"
  init_config "$NETWORK"
fi
