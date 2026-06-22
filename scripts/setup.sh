#!/bin/sh

# Initialize the node configuration
init_config() {
  NETWORK=$1
  echo "network is $NETWORK"
  if [ "$NETWORK" = "mainnet" ]; then
    TEMPLATE="templates/hpp-mainnet-node-template.json"
    TARGET="hpp-mainnet-node-config.json"
    DEFAULT_L1_RPC="https://ethereum-rpc.publicnode.com"
    DEFAULT_L1_BEACON="https://ethereum-beacon-api.publicnode.com"
    SNAPSHOT_FILE="hpp-mainnet/snapshot-mainnet.tar"
    SNAPSHOT_DOWNLOAD_URL="https://snapshot.hpp.io/mainnet/latest.tar"
  else
    TEMPLATE="templates/hpp-sepolia-node-template.json"
    TARGET="hpp-sepolia-node-config.json"
    DEFAULT_L1_RPC="https://ethereum-sepolia-rpc.publicnode.com"
    DEFAULT_L1_BEACON="https://ethereum-sepolia-beacon-api.publicnode.com"
    SNAPSHOT_FILE="hpp-sepolia/snapshot-sepolia.tar"
    SNAPSHOT_DOWNLOAD_URL="https://snapshot.hpp.io/sepolia/latest.tar"
  fi

  if [ -f "$TARGET" ]; then
    printf "$TARGET already exists. Overwrite? (y/N): "
    read CONFIRM
    if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
      echo "Initialization cancelled."
      return
    fi
  fi

  # Prompt for configuration values (defaults shown in brackets)
  echo "Configuring $NETWORK node..."
  printf "Enter L1 RPC Endpoint [$DEFAULT_L1_RPC]: "
  read L1_RPC
  printf "Enter L1 Beacon API Endpoint [$DEFAULT_L1_BEACON]: "
  read L1_BEACON

  # Fall back to defaults when no input is given
  L1_RPC=${L1_RPC:-$DEFAULT_L1_RPC}
  L1_BEACON=${L1_BEACON:-$DEFAULT_L1_BEACON}

  # Read the template, substitute variables, and write the result
  sed -e "s|<L1_RPC_ENDPOINT>|$L1_RPC|g" \
      -e "s|<L1_BEACON_API_ENDPOINT>|$L1_BEACON|g" \
      "$TEMPLATE" > "$TARGET"

  echo "--------------------------------------"
  echo "Initialized $TARGET from $TEMPLATE"
  echo "L1 RPC: $L1_RPC"
  echo "L1 Beacon: $L1_BEACON"
  echo "--------------------------------------"

  # Check if the data directory is empty, and the snapshot file is required if data is empty.
  if [ ! -f "$SNAPSHOT_FILE" ] || [ ! -s "$SNAPSHOT_FILE" ]; then
    echo "Snapshot file is missing or empty, which is required for the first run."
    printf "Would you like to download it now? (y/N): "
    read DOWNLOAD_CONFIRM
    if [ "$DOWNLOAD_CONFIRM" = "y" ] || [ "$DOWNLOAD_CONFIRM" = "Y" ]; then
      download_snapshot "$NETWORK" "$SNAPSHOT_DOWNLOAD_URL" "$SNAPSHOT_FILE"
      if [ $? -ne 0 ]; then
        exit 105
      fi
    fi
  fi

}


    # Download the snapshot
    download_snapshot() {
      NETWORK=$1
      URL=$2
      TARGET_FILE=$3

      echo "Downloading snapshot for $NETWORK..."
      echo "URL: $URL"

      # create directory if is missing
      mkdir -p "$(dirname "$TARGET_FILE")"

      # delete empty snapshot file if exists
      [ -f "$TARGET_FILE" ] && [ ! -s "$TARGET_FILE" ] && rm "$TARGET_FILE"

      curl -L -o "$TARGET_FILE" "$URL"

      if [ $? -eq 0 ]; then
        echo "Download completed: $TARGET_FILE"
      else
        echo "Error: Failed to download snapshot."
        return 1
      fi
    }