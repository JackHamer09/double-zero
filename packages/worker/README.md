# ZKsync Era Block Explorer Worker
## Overview

`ZKsync Era Block Explorer Worker` is an indexer service for ZKsync Era blockchain data. It retrieves aggregated data from the [Data Fetcher](/packages/data-fetcher) via HTTP and also directly from the blockchain using [ZKsync Era JSON-RPC API](https://docs.zksync.io/build/api-reference/ethereum-rpc), processes it and saves into the database in a way that makes it easy to read by the [Block Explorer API](/packages/api).

## Installation

```bash
$ yarn install
```

## Setting up env variables

- Create `.env` file in the `worker` package folder and copy paste `.env.example` content in there.
```
cp .env.example .env
```
- In order to tell the service where to get the blockchain data from set the value of the `BLOCKCHAIN_RPC_URL` env var to your blockchain RPC API URL. For ZKsync Era testnet it can be set to `https://sepolia.era.zksync.dev`. For ZKsync Era mainnet - `https://mainnet.era.zksync.io`.
- To retrieve aggregated blockchain data for a certain block, the Worker service calls the [Data Fetcher](/packages/data-fetcher) service via HTTP. To specify Data Fetcher URL use `DATA_FETCHER_URL` env variable. By default, it is set to `http://localhost:3040` which is a default value for the local environment.
- Set up env variables for Postgres database connection. By default it points to `localhost:5432` and database name is `block-explorer`.
You need to have a running Postgres server, set the following env variables to point the service to your database:
  - `DATABASE_HOST`
  - `DATABASE_USER`
  - `DATABASE_PASSWORD`
  - `DATABASE_NAME`
  - `DATABASE_CONNECTION_IDLE_TIMEOUT_MS`
  - `DATABASE_CONNECTION_POOL_SIZE`

The service doesn't create database automatically, you can create database by running the following command:
```bash
$ yarn db:create
```

## Running the app

```bash
# development
$ yarn dev

# watch mode
$ yarn dev:watch

# debug mode
$ yarn dev:debug

# production mode
$ yarn start
```

## Test

```bash
# unit tests
$ yarn test

# unit tests debug mode
$ yarn test:debug

# e2e tests
$ yarn test:e2e

# test coverage
$ yarn test:cov
```

## Development

### Linter
Run `yarn lint` to make sure the code base follows configured linter rules.

### DB changes
Changes to the DB are stored as migrations scripts in `src/migrations` folder and are automatically executed on the application start.

We use _code first_ approach for managing DB schema so desired schema changes should be first applied to the Entity classes and then migrations scripts can be generated running the following command: `migration:generate`.

Example:

```
yarn migration:generate -name=AddStatusColumnToTxTable
```

a new migration with the specified name and all schema changes will be generated in `src/migration` folder. Always check generated migrations to confirm that they have everything you intended.

Sometimes you need to write a manual migration script not generated based on any schema changes. For instance, to run a script to update some records. In this case use `migration:create` to create an empty migration.

Example:

```
yarn migration:create -name=UpdateTxsFee
```

this command will simply create an empty migration where the custom migration logic can be added.