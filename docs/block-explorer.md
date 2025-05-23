# ZKsync Prividium Block Explorer

**A privacy-focused, access-controlled blockchain browser for the ZKsync Prividium implementation**

## 📌 Overview

> [!NOTE]
> **ZKsync Prividium** Block Explorer is a customized version of
> the [ZKsync Era Block Explorer](https://github.com/matter-labs/block-explorer) that introduces a layer of privacy and
> access control. By implementing user **authentication and permission-based data restrictions**, it ensures that users
> can access blockchain data according to their assigned permissions.

This repository is a monorepo consisting of 6 packages:

- [Worker](./packages/worker) - an indexer service for [ZKsync Era](https://zksync.io) compatible chains. The purpose of
  the service is to read blockchain data in real time, transform it and fill in it's database with the data in a way
  that makes it easy to be queried by the [API](./packages/api) service.
- [Data Fetcher](./packages/data-fetcher) - a service that exposes and implements an HTTP endpoint to retrieve
  aggregated data for a certain block / range of blocks from the blockchain. This endpoint is called by
  the [Worker](./packages/worker) service.
- [API](./packages/api) - a service providing Web API for retrieving structured [ZKsync Era](https://zksync.io)
  blockchain data collected by [Worker](./packages/worker). It connects to the Worker's database to be able to query the
  collected data.
- [Proxy](./packages/proxy) - a proxy between the WebApp and the API used to filter data to users, and ensure that each
  user sees only the data that they are allowed to see.
- [App](./packages/app) - a front-end app providing an easy-to-use interface for users to view and inspect transactions,
  blocks, contracts and more. It makes requests to the [API](./packages/api) to get the data and presents it in a way
  that's easy to read and understand.
- [Private RPC](./packages/private-rpc) - a proxy layer between end users and the network RPC. Users must provide a
  unique token to interact with the network, and each token grants a specific, scoped view of the network.

## 🏛 Architecture

The following diagram illustrates how are the block explorer components connected:

```mermaid
flowchart
  subgraph blockchain[Blockchain]
    Blockchain[ZKsync Era JSON-RPC API]
  end

  subgraph proxy[Permission-Based Proxy]
      PrivateRpc[Private RPC]
  end

  subgraph explorer[Block Explorer]
    Database[("Block explorer DB<br/>(PostgreSQL)")]
    Worker(Worker service)
    Data-Fetcher(Data Fetcher service)
    API(API service)
    App(App)
    Proxy(Data-Access Proxy)

    Worker-."Request aggregated data (HTTP)".->Data-Fetcher
    Data-Fetcher-."Request data (HTTP)".->Blockchain
    Worker-.Save processed data.->Database

    App-."Request data (HTTP)".->Proxy

    Proxy-."Request data (HTTP) and filter results".->API
    API-.Query data.->Database
  end

  %% Sub-graph connections
  PrivateRpc -."Reads data. Returns data filtered per user.".->Blockchain
  Worker-."Request data (HTTP)".->Blockchain
  App-."Request data (HTTP)".->PrivateRpc

  %% Define custom styles
  classDef highlight fill:#add8e6,stroke:#00008b,stroke-width:2px;

  %% Apply styles
  class PrivateRpc highlight;
  class Proxy highlight;
  ```

[Worker](./packages/worker) service retrieves aggregated data from the [Data Fetcher](./packages/data-fetcher) via HTTP
and also directly from the blockchain
using [ZKsync Era JSON-RPC API](https://docs.zksync.io/build/api-reference/ethereum-rpc), processes it and saves into
the database. [API](./packages/api) service is connected to the same database where it gets the data from to handle API
requests. It performs only read requests to the database. The front-end [App](./packages/app) makes HTTP calls to the
Block Explorer [API](./packages/api) to get blockchain data. The [Proxy](./packages/proxy) filters API responses based
on user permissions, ensuring secure and controlled data access.For reading contracts or performing transactions,
the [Private RPC](./packages/private-rpc) is used to provide a layer of access control for network interactions.

## 🚀 Features

### Privacy and access control

- ✅ Authentication and authorization using Sign In With Ethereum (SIWE).
- ✅ Data scoped per user based on user permissions.
- ✅ Access control for reading contracts and performing transactions.

### Block Explorer

- ✅ View transactions, blocks, transfers and logs.
- ✅ Inspect accounts, contracts, tokens and balances.
- ✅ Verify smart contracts.
- ✅ Interact with smart contracts.
- ✅ Standalone HTTP API.
- ✅ Local node support.

## 📋 Prerequisites

- Ensure you have `node >= 18.0.0` and `yarn >= 1.20` installed.

## 🛠 Installation

```bash
yarn install
```

## ⚙️ Setting up env variables

### Manually set up env variables

Make sure you have set up all the necessary env variables. Follow setting up env variables instructions
for [Worker](./packages/worker#setting-up-env-variables), [Data Fetcher](./packages/data-fetcher#setting-up-env-variables)
and [API](./packages/api#setting-up-env-variables). For the [App](./packages/app) package you might want to edit
environment config, see [Environment configs](./packages/app#environment-configs).

### Build env variables based on your [zksync-era](https://github.com/matter-labs/zksync-era) local repo setup

Make sure you have [zksync-era](https://github.com/matter-labs/zksync-era) repo set up locally. You must have your
environment variables files present in the [zksync-era](https://github.com/matter-labs/zksync-era) repo at
`/etc/env/*.env` for the build envs script to work.

The following script sets `.env` files
for [Worker](./packages/worker), [Data Fetcher](./packages/data-fetcher), [API](./packages/api)
and [Proxy](./packages/proxy) packages as well as environment configuration file for [App](./packages/app) package based
on your local [zksync-era](https://github.com/matter-labs/zksync-era) repo setup.

```bash
yarn run hyperchain:configure
```

You can review and edit generated files if you need to change any settings.

## 👨‍💻 Running locally

Before running the solution, make sure you have a database server up and running, you have created a database and set up
all the required environment variables.
To create a database run the following command:

```bash
yarn run db:create
```

To run all the packages (`Worker`, `Data Fetcher`, `API`, `Proxy` and front-end `App`) in `development` mode run the
following command from the root directory.

```bash
yarn dev
```

For `production` mode run:

```bash
yarn build
yarn start
```

Each component can also be started individually. Follow individual packages `README` for details.

## 🐳 Running in Docker

There is a docker compose configuration that allows you to run Block Explorer and all its dependencies in docker. Just
run the following command to spin up the whole environment:

```
docker compose up
```

It will run local Ethereum node, ZkSync Era, Postgres DB and all Block Explorer services.

Another option is to run only the prividium services hitting external endpoints
These can be done by upgrading the content `proxy.env` with the desired rpc and explorer
urls. Then running:

``` shell
docker compose -f docker-compose-00.yaml --env-file=proxy.env up
```

This is going to spin only the services needed to make a functional
prividium setup against the specified environment.

## ⛓️ Connection to your Hyperchain

To get block-explorer connected to your ZK Stack Hyperchain you need to set up all the the necessary environment and
configuration files with your Hyperchain settings. You can use a script to build them.
See [Setting up env variables](#%EF%B8%8F-setting-up-env-variables).

## 🔍 Verify Block Explorer is up and running

To verify front-end `App` is running open http://localhost:3010 in your browser. `proxy` should be available
at http://localhost:4040 and `private-rpc` at http://localhost:4041.

## 🕵️‍♂️ Testing

Run unit tests for all packages:

```bash
yarn test
```

Run e2e tests for all packages:

```bash
yarn test:e2e
```

Run tests for a specific package:

```bash
yarn test -w {package}
```

For more details on testing please check individual packages `README`.

## 💻 Conventional Commits

We follow the Conventional Commits [specification](https://www.conventionalcommits.org/en/v1.0.0/#specification).

## 📘 License

ZKsync Era Block Explorer is distributed under the terms of either

- Apache License, Version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or <http://www.apache.org/licenses/LICENSE-2.0>)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or <http://opensource.org/licenses/MIT>)

at your option.

## 🔗 Production links

- Testnet Sepolia API: https://block-explorer-api.sepolia.zksync.dev
- Mainnet API: https://block-explorer-api.mainnet.zksync.io
- Testnet Sepolia App: https://sepolia.explorer.zksync.io
- Mainnet App: https://explorer.zksync.io
