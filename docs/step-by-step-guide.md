# Step-by-step full guide

Double Zero is a framework that provides privacy and access control for ZKsync-compatible chains.

This guide walks you through the complete process of setting up a local Double Zero environment, which includes a
private validium chain and a dapp built on the Double Zero framework.

## 1 - Deploy your validium chain

Our chain will be deployed using [zkstack](https://zkstack.io/). ZKstack enables you to create custom validium chains
tailored to your needs. For this guide, we'll use the basic deployment, but you can consult their documentation for more
customized configurations.

### 1.1 - Install rust

ZKstack requires Rust to be installed. The simplest way to install Rust is through Rustup. While you can use any
installation method you prefer, make sure you have an up-to-date version.

```bash
# rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# stable rust
rustup install stable
```

### 1.2 - Install zksync foundry:

We need zksync foundry to deploy the contracts that we’ll be using. Foundry can be installed following this guide:

https://foundry-book.zksync.io/getting-started/installation

### 1.3 - Install docker

We are going to use docker in several parts of this guide. Please follow the instructions for your OS before
continue: https://docs.docker.com/engine/install/

### 1.4 - Install zkstack

Once rust is installed we can install `zkstack`. The easiest way to do this is installing `zkstackup` (a version manager
for zkstack) and then use that to install zkstack:

```bash
# Install zkstackup
curl -L https://raw.githubusercontent.com/matter-labs/zksync-era/main/zkstack_cli/zkstackup/install | bash

# Install zkstack
zkstackup
```

### 1.5 - Clone zksync-era repo

We need to clone the `matter-labs/zksync-era` repo which contains initialization script.
Checkout branch `dr/interop-tests-with-broadcaster-server`

```bash
git clone git@github.com:matter-labs/zksync-era.git
cd zksync-era
git checkout dr/interop-tests-with-broadcaster-server
git submodule update --init --recursive
```

### 1.6 - Start both chains

Run the command below to start Chain A and Chain B.
```bash
./.github/scripts/interop.sh
```

## 2 - Deploy the Contracts

### 2.1 - Clone the repo of our app

In a new terminal:

```bash
git clone git@github.com:JackHamer09/interop-escrow-double-zero.git
cd interop-escrow-double-zero
git submodule update --init --recursive
```

### 2.2 - Start Interop Broadcaster server

In a new terminal, run the following command to start the interop broadcaster server:

```bash
cd interop-broadcaster-server
npm i
npm run dev
```

This will enable finalization of our cross-chain transactions.

### 2.3 - Deploy the contracts

The repo includes a script to deploy all the needed contracts together and fund your test accounts.

```bash
export USER_1_CHAIN_A_ADDRESS="some_address" # wallet address that you control (for Chain A)
export USER_2_CHAIN_B_ADDRESS="some_address_2" # second wallet address that you control (for Chain B)

cd contracts
./scripts/deploy.sh
```
At the end of the process you'll see multiple contract addresses.
Take note of them, they are going to be used in the next step.

After running this script:

- The Escrow contracts are deployed.
- Account 1 funded on Chain A
- Account 2 funded on Chain B

### 2.4 - Configure double zero permissions

Let’s go back to the double zero repo. We have to edit this file: `environments/compose-hyperchain-permissions-a.yaml` and `environments/compose-hyperchain-permissions-b.yaml`.

Update all occurrencies of `update_address_here` with the contract addresses you got from the previous step.

## 3. Privacy infra

Double Zero adds authentication and authorization on top of the newly created validium chain. All the services are
written in nodejs and they are meant to be easy to run and configure. Let’s go step by step.

### 3.1 - Clone the repo

Open a new terminal and run the following:

```bash
git clone git@github.com:JackHamer09/double-zero.git
cd double-zero
```

### 3.2 Config

At this stage we need to link the private chain with double zero. We are going to run the double zero services inside a
docker a network. But they need to interact with our validium chain that is running in the host machine. The easiest way
to make this work is by connecting the validium chain using your local ip. You can use this commands to get your local
ip:

```bash
# mac
ipconfig getifaddr en0

# linux
ip -4 addr show wlan0 | grep -oP ‘(?<=inet\s)\d+(\.\d+){3}’ | grep -Fv 127.0.0.1

# windows
ipconfig
```

We are going to use your ip to link the validium rpc and the contract verifier.

Let’s go ahead and add our IP in (replace `update_with_your_local_ip` with your local ip from previous step):

- `environments/compose-hyperchain-a.env`
- `environments/compose-hyperchain-b.env`

Once the configuration is in place you can run the double zero services.

### 3.3 - Launch

```bash
./environments/launch-hyperchain-env-a.sh
```

after chain A infrastructure was started, start chain B infra from another terminal:

```bash
./environments/launch-hyperchain-env-b.sh
```

This is going to run all the services of double zero using docker. At this stage you can check that the explorer is
working going with your browser to:

- Chain A: [http://localhost:3010](http://localhost:3010)
- Chain B: [http://localhost:3110](http://localhost:3110)

![img/explorer.png](./img/explorer.png)

### 4 - Configure and run dapp frontend

In a new termnal, go to the root of the `interop-escrow-double-zero` and run the following command:

```bash
cd web
cp .env.example .env
```

Now edit the .env file by filling missing contract addresses.

### 3.5 - Run the frontend of the dapp

```bash
pnpm install
pnpm dev
```

Now, you can go to [localhost:3000/trade](http://localhost:3000/trade) to see your dapp running.

### 4 - Authorizing RPC

To Authorize RPC for each chain you need to go:

- For **Account 1 on Chain A** account: can be done directly on the DApp by authorizing the RPC and the adding the network **OR** by going to the explorer login page [http://localhost:3010/login](http://localhost:3010/login) and authorizing the RPC there.
- For **Account 2 on Chain B** account: can be done ONLY by going to the explorer login page [http://localhost:3110/login](http://localhost:3110/login) and authorizing the RPC there.

---

### Limitations

- Right now you can only propose a trade from chain A. 