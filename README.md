![HPP](./assets/HPP_primary_black.svg)

# Overview

House Party Protocol (HPP) is a cost-efficient, scalable, and developer-friendly Layer 2 (L2) network built on the 
Arbitrum Orbit. Secured by Ethereum and enhanced through data availability with Eigen DA, HPP delivers modular and 
performant infrastructure for the next generation of decentralized applications.

This repository contains Docker builds and guide to run your own node on the HPP network.

## Requirements

### Minimum hardware configuration

The following is the minimum hardware configuration required to set up a Nitro full node (not archival):

| Resource     | Recommended                                   |
|--------------|-----------------------------------------------|
| RAM          | 16 GB                                         |
| CPU          | 4 core CPU (for AWS, a t3 xLarge instance)    |
| Storage Type | NVMe SSD drives are recommended               |
| Storage size | Depends on the chain and its traffic overtime |

Please note that:

* These minimum requirements for RAM and CPU are recommended for nodes that process a small number of RPC requests. For
  nodes that require processing multiple simultaneous requests, both RAM and number of CPU cores will need to be scaled
  with the amount of traffic being served.
* Single core performance is important. If the node is falling behind and a single core is 100% busy, it is recommended
  to update to a faster processor
* The minimum storage requirements will change over time as the chain grows. Using more than the minimum requirements to
  run a robust full node is recommended.

### Prerequisites

1. Download and install [Docker](https://www.docker.com/), ensure it is running.
2. Unlimited rate limit Ethereum RPC endpoint and beacon chain RPC endpoint

## Quick Start

### Running the Node

1. Configure your L1 endpoints in the appropriate `.env` file:

   If you are running the node on mainnet or testnet, refer to `.env.eigenda.mainnet` or `.env.eigenda.sepolia`

   ```properties
   # EigenDA Proxy - .env.eigenda.mainnet
    EIGENDA_PROXY_EIGENDA_DISPERSER_RPC=disperser.eigenda.xyz:443
    EIGENDA_PROXY_EIGENDA_STATUS_QUERY_INTERVAL=5s
    EIGENDA_PROXY_EIGENDA_STATUS_QUERY_TIMEOUT=2400s
    EIGENDA_PROXY_EIGENDA_ETH_RPC=https://ethereum-rpc.publicnode.com
    EIGENDA_PROXY_EIGENDA_SERVICE_MANAGER_ADDR=0x870679E138bCdf293b7Ff14dD44b70FC97e12fc0
   ```

2. Download the snapshot of the HPP chain

   HPP is a chain based on Arbitrum Nitro, and it supports synchronization from snapshots. 
   The default configuration file starts synchronization by reading the snapshot file located at the specified path. 
   If the node has been inactive for more than two weeks since its last successful sync, it is recommended to resynchronize the node using a new snapshot

   The following command downloads the snapshot for the mainnet.
   ```shell
   # download mainnet snapshot
   curl -o hpp-mainnet/snapshot-mainnet.tar  https://storage.googleapis.com/conduit-networks-snapshots/hpp-mainnet-xeajiyxsci/latest.tar
   ```
   You can download the snapshot for the testnet from the following link: https://storage.googleapis.com/conduit-networks-snapshots/hpp-sepolia-turdrv0107/latest.tar

3. Modifying the docker compose configuration (Optional)

   The default `docker-compose.yml` file is configured to synchronize using a snapshot. If you are not using a snapshot, you must remove the relevant settings from the configuration.

   ```yaml
   volumes:
     # If snapshots are not used, remove the following line
     - ./hpp-mainnet/snapshot-mainnet.tar:/hpp-mainnet/snapshot.tar:ro
   # Remaining lines omitted for brevity
   command:
   [
     # Remove the following line when snapshots are not used
     "--init.url", "file:///home/user/snapshots.tar",
   # Remaining lines omitted for brevity
   ```

4. Modify the configuration of Arbitrum Nitro

   Update the required fields in the `hpp-mainnet-node-config.json` or `hpp-sepolia-node-config.json` file to align 
with the target chain. For additional details, refer to the [Configuration](#configuration) section below.

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
        "staker": {
          "enable": false
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
5. Start the node:

   ```bash
   # For mainnet (default):
   docker compose up --build

   # For testnet:
   docker compose -f docker-compose.sepolia.yml up --build

   ```

   You can alternatively use helper script `manage.sh` to start/stop the node:

   ```bash
   ./manage.sh run           # Starts the container for the mainnet (default)
   ./manage.sh run sepolia   # Starts the container for the "sepolia" testnet
   ./manage.sh stop mainnet  # Stops the container for the mainnet 
   ./manage.sh clear         # Clears the containers for the "mainnet" (default)
   ```

## Configuration

### Required Settings

These fields in example files contain URLs for public RPC endpoints with rate limits. For production use, you must replace them with your own unlimited RPC endpoints.

- `.env` file
  - `EIGENDA_PROXY_EIGENDA_ETH_RPC`: The URL of the Ethereum L1 node RPC endpoint
- `hpp-mainnet-node-config.json` or `hpp-sepolia-node-config.json` file
  - `parent-chain.connection.url`: The URL of the Ethereum L1 node RPC endpoint
  - `parent-chain.blob-client.beacon-url`: The URL of the Ethereum L1 beacon node endpoint
  - `node.eigen-da.rpc`: The URL of the EigenDA RPC endpoint

#### RPC endpoint

The RPC endpoint provided in the example configuration, `https://ethereum-rpc.publicnode.com`, is a free service 
that is not enough for use in the node due to the usage limits. It is recommended to use an unlimited RPC endpoint 
service. Users must subscribe to such a service and replace the example configuration with the RPC endpoint provided 
by the service.

For instance, when using Alchemy RPC, the RPC endpoint should be defined in the configuration as follows:

```properties
EIGENDA_PROXY_EIGENDA_ETH_RPC=https://eth-mainnet.g.alchemy.com/v2/3AbCdEfGh78JkL_zPxDdf
```

## Supported Networks

| Network | Status |
|---------|--------|
| Mainnet | ✅      |
| Testnet | ✅      |

## Troubleshooting

For support please join discussions on [Telegram](https://t.me/aergoofficial), or open a new GitHub issue.

## Disclaimer

THE NODE SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND. We make no guarantees about asset protection or
security. Usage is subject to applicable laws and regulations.

For more information, visit [docs.hpp.io](https://docs.hpp.io/).
