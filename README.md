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

To run the node for mainnet, follow these steps:
   ```bash
   # initialize configuration file and download snapshot file if needed.
   ./manage.sh init mainnet
   # Starts the container for the mainnet 
   ./manage.sh run mainnet
   # Stops the container for the mainnet 
   ./manage.sh stop mainnet  
   # Clears the containers for the mainnet (but chain data will be not be deleted, you need to delete it manually)
   ./manage.sh clear mainnet         
   
   # Check the running status of the node
   ./manage.sh status
   ```

To run the node for the testnet, follow these steps:
   ```bash
   # initialize configuration file and download snapshot file if needed.
   ./manage.sh init sepolia
   # Starts the container for the sepolia testnet 
   ./manage.sh run sepolia
   # Stops the container for the testnet 
   ./manage.sh stop sepolia  
   # Clears the containers for the testnet
   ./manage.sh clear sepolia
   ```

### Advanced Usage

1. Initialize configuration file
    The configuration file contains the RPC endpoint and other parameters, but you need to modify L1 RPC and L1_BEACON_RPC parameters in a normal situation. 
    The command `init` in script `manage.sh` can help you.

   ```shell
   # initialize configuration file and download snapshot file if needed.
   ./manage.sh init mainnet
   # initialize testnet 
   ./manage.sh init sepolia
    ```

2. Download snapshot file

   HPP is a chain based on Arbitrum Nitro, and it supports synchronization from snapshots. 
   The default configuration file starts synchronization by reading the snapshot file located at the specified path. 
   If the node has been inactive for more than two weeks since its last successful sync, it is recommended to resynchronize the node using a new snapshot.

   The command `init` of `manage.sh` also downloads the snapshot if needed.

   Or, you can download the snapshot manually.
   ```bash
   # download mainnet snapshot
   curl -o hpp-mainnet/snapshot-mainnet.tar https://storage.googleapis.com/conduit-networks-snapshots/hpp-mainnet-xeajiyxsci/latest.tar
   # download sepolia snapshot
   curl -o hpp-sepolia/snapshot-sepolia.tar https://storage.googleapis.com/conduit-networks-snapshots/hpp-sepolia-turdrv0107/latest.tar
   ``

3. Start the node:

   You can use helper script `manage.sh` to start/stop the node:
   ```bash
   # Starts the container for the "sepolia" testnet
   ./manage.sh run sepolia   
   # Stops the container for the mainnet 
   ./manage.sh stop mainnet  
   # Clears the containers for the "mainnet" (default)
   ./manage.sh clear         
   ```
   
   NOTE: you can run only one network at a time.

   You can alternatively use docker compose directly: 
   ```bash
   # For mainnet (default):
   docker compose up --build

   # For testnet:
   docker compose -f docker-compose.sepolia.yml up --build
   ```

## Configuration


#### L1 RPC endpoint

The L1 RPC endpoint provided in the example configuration, `https://ethereum-rpc.publicnode.com`, is a free service 
that may have usage limits. For production use with higher traffic, it is recommended to use a dedicated RPC endpoint 
service (e.g., Alchemy, Infura, or dRPC). Replace the RPC endpoint in the configuration as needed.

#### HPP RPC endpoint

The public HPP RPC (`https://mainnet.hpp.io`) has rate limits in place. If you need higher throughput for development, 
operations, or team usage, you can get a dedicated RPC endpoint with an API key through Conduit:

1. Sign up at [app.conduit.xyz](https://app.conduit.xyz)
2. Navigate to **HPP Mainnet** (or **HPP Sepolia**) and go to **Node** > **RPC**
3. Generate an API key
4. Use the provided RPC URL:
   - Mainnet: `https://mainnet.hpp.io/<YOUR_API_KEY>`
   - Sepolia: `https://sepolia.hpp.io/<YOUR_API_KEY>`

This gives you higher rate limits and more reliable access compared to the public endpoint.


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
