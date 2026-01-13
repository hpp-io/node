#!/bin/sh

# 설정 초기화 함수
init_config() {
  NETWORK=$1
  if [ "$NETWORK" = "mainnet" ]; then
    TEMPLATE="templates/hpp-mainnet-node-template.json"
    TARGET="hpp-mainnet-node-config.json"
  else
    TEMPLATE="templates/hpp-sepolia-node-template.json"
    TARGET="hpp-sepolia-node-config.json"
  fi

  if [ -f "$TARGET" ]; then
    printf "$TARGET already exists. Overwrite? (y/N): "
    read CONFIRM
    if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
      echo "Initialization cancelled."
      return
    fi
  fi

  cp "$TEMPLATE" "$TARGET"
  echo "Initialized $TARGET from $TEMPLATE"
}