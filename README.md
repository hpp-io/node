![HPP](logo.webp)

# Overview

TODO: need to fill overview 


## Quick Start

### Prerequisites

You should have an access point to Ethereum L1 full node RPC

### Running the Node

1. Configure your L1 endpoints in the appropriate `.env` file:

    If you are running the node on mainnet or testnet, refer to `.env.eigenda.mainnet` or `.env.eigenda.sepolia`

   ```yaml
   # EigenDA Proxy - .env.eigenda.mainnet
    EIGENDA_PROXY_EIGENDA_DISPERSER_RPC=disperser.eigenda.xyz:443
    EIGENDA_PROXY_EIGENDA_STATUS_QUERY_INTERVAL=5s
    EIGENDA_PROXY_EIGENDA_STATUS_QUERY_TIMEOUT=2400s
    EIGENDA_PROXY_EIGENDA_ETH_RPC=https://ethereum-rpc.publicnode.com
    EIGENDA_PROXY_EIGENDA_SERVICE_MANAGER_ADDR=0x870679E138bCdf293b7Ff14dD44b70FC97e12fc0
   ```

2. Modify the configuration of Arbitrum Nitro
    
    Refer to `hpp-mainnet-node-config.json` or `hpp-sepolia-node-config.json`.

     ```json
       {
      "chain": {
        "info-json": "[{\"chain-id\":190415,\"parent-chain-id\":1,\"chain-name\":\"conduit-orbit-deployer\",\"chain-config\":{\"chainId\":190415,\"homesteadBlock\":0,\"daoForkBlock\":null,\"daoForkSupport\":true,\"eip150Block\":0,\"eip150Hash\":\"0x0000000000000000000000000000000000000000000000000000000000000000\",\"eip155Block\":0,\"eip158Block\":0,\"byzantiumBlock\":0,\"constantinopleBlock\":0,\"petersburgBlock\":0,\"istanbulBlock\":0,\"muirGlacierBlock\":0,\"berlinBlock\":0,\"londonBlock\":0,\"clique\":{\"period\":0,\"epoch\":0},\"arbitrum\":{\"EnableArbOS\":true,\"AllowDebugPrecompiles\":false,\"DataAvailabilityCommittee\":true,\"InitialArbOSVersion\":32,\"InitialChainOwner\":\"0xF91B7476e52374dD75fb3d598C5f2D5dc019fc90\",\"GenesisBlockNum\":0}},\"rollup\":{\"bridge\":\"0x9948eDFBb9e0b104bAd60393dBe79d0BC7937014\",\"inbox\":\"0xE0400a87d5Ee8a2Fc1dF2aAf4B6d8f89d0B9bE55\",\"sequencer-inbox\":\"0x9B26957a661bc862FA0d7eb21813Aa008d0Cc6E6\",\"rollup\":\"0xf0d2960a37B33567FF7507C2d59da021277663A1\",\"validator-utils\":\"0x84eA2523b271029FFAeB58fc6E6F1435a280db44\",\"validator-wallet-creator\":\"0x0A5eC2286bB15893d5b8f320aAbc823B2186BA09\",\"deployed-at\":22943219}}]",
        "name": "conduit-orbit-deployer"
      },
      "parent-chain": {
        "connection": {
          "url": "https://ethereum-rpc.publicnode.com"
        },
        "blob-client": {
          "beacon-url": "https://ethereum-beacon-api.publicnode.com"
        }
      },
      "node": {
        "feed": {
          "input": {
            "url": "wss://relay-hpp-mainnet-xeajiyxsci.t.conduit.xyz"
          }
        },
        "batch-poster": {
          "enable-eigenda-failover": true
        },
        "eigen-da": {
          "enable": true,
          "rpc": "http://localhost:3100"
        },
        "data-availability": {
          "enable": true,
          "rest-aggregator": {
            "enable": true,
            "urls": "https://das-hpp-mainnet-xeajiyxsci.t.conduit.xyz"
          }
        }
      },
      "execution": {
        "forwarding-target": "https://mainnet.hpp.io"
      },
      "http": {
        "api": "net,web3,eth",
        "corsdomain": "*",
        "addr": "0.0.0.0",
        "vhosts": "*"
      }
    }
    ```

3. Start the node:

   ```bash
   # For mainnet (default):
   docker compose up --build

   # For testnet:
   docker compose -f docker-compose.sepolia.yml up --build

   ```

    You can use helper script `manage.sh` to start/stop the node:

   ```bash
   ./manage.sh run           # Starts the container for the mainnet (default)
   ./manage.sh run sepolia   # Starts the container for the "sepolia" testnet
   ./manage.sh stop mainnet  # Stops the container for the mainnet 
   ./manage.sh clear         # Clears the containers for the "mainnet" (default)
   ```

## Requirements

The following are the hardware specifications we use in production:

## Configuration

### Required Settings

- L1 Configuration:

## Supported Networks

| Network | Status |
| ------- | ------ |
| Mainnet | ✅     |
| Testnet | ✅     |

## Troubleshooting

TODO: need to fill troubleshooting

## Disclaimer

THE NODE SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND. We make no guarantees about asset protection or security. Usage is subject to applicable laws and regulations.

For more information, visit [docs.base.org](https://docs.hpp.io/).
