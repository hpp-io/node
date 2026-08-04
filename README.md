<p align="center">
  <img src="assets/HPP_primary_black.svg" alt="HPP" width="320">
</p>

# Overview

House Party Protocol (HPP) Mainnet is a cost-efficient, scalable, and
developer-friendly **Ethereum L2** built on the **Arbitrum Nitro Stack**.
Secured by Ethereum and operating in **AnyTrust** data availability mode,
HPP Mainnet delivers modular, performant infrastructure for the next
generation of decentralized applications.

This repository contains the Docker build and the guide to run your own
node on the HPP network.

## Requirements

### Minimum hardware configuration

The following is the minimum hardware configuration required to set up a
Nitro full node (not archival):

| Resource     | Recommended                                   |
| ------------ | --------------------------------------------- |
| RAM          | 16 GB                                         |
| CPU          | 4 core CPU (for AWS, a t3.xlarge instance)    |
| Storage Type | NVMe SSD drives are recommended               |
| Storage size | Depends on the chain and its traffic over time |

Please note that:

- These minimum requirements for RAM and CPU are recommended for nodes
  that process a small number of RPC requests. For nodes that need to
  process multiple simultaneous requests, both RAM and CPU core count
  should be scaled with the amount of traffic being served.
- Single-core performance matters. If the node is falling behind and a
  single core is pegged at 100%, move to a faster processor.
- Minimum storage requirements grow over time as the chain grows. Using
  more than the minimum is recommended for a robust full node.

### Prerequisites

1. Install [Docker](https://www.docker.com/) and make sure it is running.
2. An unlimited-rate Ethereum L1 RPC endpoint and an L1 Beacon Chain RPC
   endpoint.

## Quick Start

### Running the Node

To run a mainnet node:

```bash
# Initialize the config file and download the snapshot if needed.
./manage.sh init mainnet
# Start the mainnet container
./manage.sh run mainnet
# Stop the mainnet container
./manage.sh stop mainnet
# Clear the mainnet containers (chain data is NOT deleted — remove it manually)
./manage.sh clear mainnet

# Check node status
./manage.sh status
```

To run a testnet (Sepolia) node:

```bash
# Initialize the config file and download the snapshot if needed.
./manage.sh init sepolia
# Start the Sepolia testnet container
./manage.sh run sepolia
# Stop the testnet container
./manage.sh stop sepolia
# Clear the testnet containers
./manage.sh clear sepolia
```

### Advanced Usage

**1. Initialize the configuration file**

The configuration file contains the RPC endpoint and other parameters.
In a normal setup you only need to modify the `L1_RPC` and `L1_BEACON_RPC`
parameters. The `init` command in `manage.sh` handles this for you:

```bash
# Initialize mainnet config (downloads snapshot if needed)
./manage.sh init mainnet
# Initialize testnet config
./manage.sh init sepolia
```

**2. Download the snapshot file**

HPP is built on the Arbitrum Nitro Stack and supports synchronization
from snapshots. The default config starts syncing by reading the snapshot
at the configured path. If a node has been inactive for more than two
weeks since its last successful sync, re-sync from a fresh snapshot.

> **A snapshot is the only recovery path.** HPP runs in AnyTrust mode, and
> the DAC does not retain batch data indefinitely. A node whose chain data
> is damaged cannot be re-synced from genesis — it stops with
> `failed to fetch batch mentioned by batch posting report`. To recover,
> delete the data directory and start again from a snapshot:
>
> ```bash
> docker compose down -t 300
> rm -rf hpp-mainnet/data
> ./manage.sh init mainnet && ./manage.sh run mainnet
> ```
>
> Extracting the snapshot takes about a minute; catching up 43 days of
> history takes roughly 28 minutes with the tuning profile applied.

Snapshots are hosted by HPP and served from `https://snapshot.hpp.io` —
no GCP account or credentials are required.

The `init` command also downloads the snapshot if needed. To download
manually:

```bash
# Mainnet snapshot
curl -o hpp-mainnet/snapshot-mainnet.tar \
  https://snapshot.hpp.io/mainnet/latest.tar
# Sepolia snapshot
curl -o hpp-sepolia/snapshot-sepolia.tar \
  https://snapshot.hpp.io/sepolia/latest.tar
```

**3. Start the node**

Use the `manage.sh` helper to start/stop the node:

```bash
# Start the Sepolia testnet container
./manage.sh run sepolia
# Stop the mainnet container
./manage.sh stop mainnet
# Clear the mainnet containers (default)
./manage.sh clear
```

> **NOTE:** You can run only one network at a time.

> **Always give the node time to shut down.** `docker compose down`
> defaults to a 10-second grace period before sending SIGKILL. A node
> holding several GB of cached state cannot flush it in that window, and
> the chain data ends up corrupted — on the next start it falls back to
> `Loaded most recent local block number=0` and the log index is reset.
> Recovery then requires a full snapshot restore. Always stop with an
> explicit timeout:
>
> ```bash
> docker compose down -t 300
> ```

You can also use Docker Compose directly:

```bash
# Mainnet (default)
docker compose up --build

# Testnet
docker compose -f docker-compose.sepolia.yml up --build
```

## Configuration

#### L1 RPC endpoint

The L1 RPC endpoint in the example config,
`https://ethereum-rpc.publicnode.com`, is a free service that may have
usage limits. For production use with higher traffic, use a dedicated RPC
endpoint (e.g. Alchemy, Infura, or dRPC) and replace the endpoint in the
config as needed.

#### Performance tuning (optional but recommended)

The default `inbox-reader` and cache settings are conservative. This
repository ships tuning profiles that speed up the initial sync
substantially and reduce L1 request volume at the same time:

- `templates/hpp-mainnet-node-tuning.json` — for 16 GB hosts
- `templates/hpp-sepolia-node-tuning.json` — for 8 GB hosts

`--conf.file` accepts multiple files and merges them, so the profile can
be layered on top of the generated config:

```bash
--conf.file /config/nodeConfig.json
--conf.file /config/tuning.json
```

Mount the file alongside the node config in `docker-compose.yml`, or copy
the `node.inbox-reader` and `execution.caching` blocks straight into your
`hpp-<network>-node-config.json`.

Measured on a mainnet node syncing 233,742 blocks from a snapshot:

| Configuration            | Sync speed      | Time to tip | L1 requests |
| ------------------------ | --------------- | ----------- | ----------- |
| Alchemy free, 9 blocks   | 36 L1 blocks/s  | 2h 15m+     | ~33,000     |
| Defaults (100 / 2000)    | 48 blocks/s     | ~90 min     | —           |
| **Tuning profile**       | **213 blocks/s**| **~28 min** | **2,657**   |

> **IMPORTANT:** These profiles assume an L1 endpoint that accepts
> `eth_getLogs` over wide block ranges. Applying them to a provider with a
> narrow range limit (for example Alchemy's free tier, capped at 10 blocks)
> will cause the inbox reader to fail.

Cache values are sized for the host, not the network: use the mainnet
profile on a 16 GB machine and the Sepolia profile on 8 GB. Without
tuning the node uses only ~1.4 GB of RAM; with it, ~4.3 GB.

#### HPP RPC endpoint

The public HPP RPC (`https://mainnet.hpp.io`) is rate-limited. If you need
higher throughput for development, operations, or team usage, get a
dedicated RPC endpoint with an API key through Conduit:

1. Sign up at [app.conduit.xyz](https://app.conduit.xyz)
2. Go to **HPP Mainnet** (or **HPP Sepolia**) → **Node** → **RPC**
3. Generate an API key
4. Use the provided RPC URL:
   - Mainnet: `https://mainnet.hpp.io/<YOUR_API_KEY>`
   - Sepolia: `https://sepolia.hpp.io/<YOUR_API_KEY>`

This gives higher rate limits and more reliable access than the public
endpoint.

## Supported Networks

| Network      | Status |
| ------------ | ------ |
| HPP Mainnet  | ✅     |
| HPP Sepolia  | ✅     |

## Network Parameters

| Parameter        | Value                                        |
| ---------------- | -------------------------------------------- |
| Network          | HPP Mainnet (Ethereum L2)                    |
| Stack            | Arbitrum Nitro Stack (v3.9.8, ArbOS 51)      |
| Data Availability | AnyTrust                                     |
| Chain ID         | 190415                                       |
| Native Gas Token | ETH                                          |
| RPC Endpoint     | https://mainnet.hpp.io                        |
| Block Explorer   | https://explorer.hpp.io                       |

## Troubleshooting

For support, join the discussion on
[Telegram](https://t.me/aergoofficial) or open a new GitHub issue.

## Disclaimer

THE NODE SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND. We
make no guarantees about asset protection or security. Usage is subject
to applicable laws and regulations.

For more information, visit [docs.hpp.io](https://docs.hpp.io/).
