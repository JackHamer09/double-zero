Escrow Trade Demo Between Private Chains
========================================

This guide walks you through setting up a local escrow trade demo between two private ZKsync-compatible chains using Double Zero and Interop. The demo spins up two isolated chains, deploys escrow contracts, and leverages an interoperability layer to settle cross-chain trades confidentially.

## Prerequisites

Ensure you have the following tools installed. Click each dropdown for installation instructions:

<details>
  <summary><strong>1. Rust</strong></summary>

  Install via Rustup:
  ```bash
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  rustup install stable
  ```
</details>

<details>
  <summary><strong>2. Docker</strong></summary>

  Follow Docker’s official instructions for your OS:
  - https://docs.docker.com/engine/install/
  ```bash
  # Example for Ubuntu
  sudo apt-get update
  sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io
  ```
</details>

<details>
  <summary><strong>3. Foundry (zksync-foundry)</strong></summary>

  Install Foundry following the ZKsync documentation:
  ```bash
  curl -L https://foundry.paradigm.xyz | bash
  foundryup
  ```
</details>

<details>
  <summary><strong>4. zkstack (via zkstackup)</strong></summary>

  ```bash
  curl -L https://raw.githubusercontent.com/matter-labs/zksync-era/main/zkstack_cli/zkstackup/install | bash
  zkstackup
  ```
</details>

<details>
  <summary><strong>5. jq</strong></summary>

  - **macOS**: `brew install jq`
  - **Ubuntu**: `sudo apt-get install jq`
  - **Windows (WSL)**: `sudo apt-get install jq`
</details>

## 1. Deploy Two Private Chains

We'll use **zkstack** to run two private validium chains (Chain A and Chain B).

```bash
# Clone & prepare the zksync-era repo
git clone git@github.com:matter-labs/zksync-era.git
cd zksync-era
git checkout dr/interop-tests-with-broadcaster-server
git submodule update --init --recursive

# Start both chains
./.github/scripts/interop.sh
```

## 2. Deploy Escrow Contracts

```bash
# Clone the escrow demo repo
git clone git@github.com:JackHamer09/interop-escrow-double-zero.git
cd interop-escrow-double-zero
git submodule update --init --recursive

# Start the Interop Broadcaster
cd interop-broadcaster-server
npm install
npm run dev

# Set wallet addresses
export USER_1_CHAIN_A_ADDRESS=0xYourAddressOnChainA
export USER_2_CHAIN_B_ADDRESS=0xYourAddressOnChainB

# Deploy contracts (requires jq)
cd ../contracts
./scripts/deploy.sh
```

After completion, note the contract addresses for Chain A and Chain B.

## 3. Clone & Configure Double Zero Services

First, clone the Double Zero repository:

```bash
git clone git@github.com:JackHamer09/double-zero.git
cd double-zero
```

Double Zero provides a private RPC proxy with fine-grained access control. Edit the permission files and replace `update_address_here` with your deployed escrow contract addresses:

- `environments/compose-hyperchain-permissions-a.yaml`
- `environments/compose-hyperchain-permissions-b.yaml`

## 4. Launch Double Zero Services

We’ll run Double Zero services in Docker, connecting them to our local chains via your machine’s IP.

1. **Find your local IP**:
   - macOS: `ipconfig getifaddr en0`
   - Linux: `ip -4 addr show wlan0 | grep -oP '(?<=inet\\s)\\d+(\\.\\d+){3}'`
   - Windows: check under your network adapter in `ipconfig`

2. **Configure environment files** in the `double-zero` directory:
   - `environments/compose-hyperchain-a.env`
   - `environments/compose-hyperchain-b.env`
   - (Optional) `environments/compose-gateway-explorer.env`
   
   Set your local IP for the RPC endpoints.

3. **Launch Chain A services**:
   ```bash
   ./environments/launch-hyperchain-env-a.sh
   ```

4. **Launch Chain B services** in another terminal:
   ```bash
   ./environments/launch-hyperchain-env-b.sh
   ```

5. (Optional) **Launch Gateway Explorer** in another terminal:
   ```bash
   ./environments/launch-gateway-explorer.sh
   ```

---

## 5. Verify Explorers & Authorize Access

1. **Visit your address page**:
   - **Chain A (Account 1)**: [http://localhost:3010/address/{USER_1_CHAIN_A_ADDRESS}](http://localhost:3010)
   - **Chain B (Account 2)**: [http://localhost:3110/address/{USER_2_CHAIN_B_ADDRESS}](http://localhost:3110)

2. If you see **"Access Restricted"**, complete the following on the respective explorer:
   - Click **Login** on the top right corner, connect the corresponding wallet, and follow the prompts to authorize access.
   - After login, click **Add Network** to register your private RPC URL for your address with your MetaMask wallet.

## 6. Run the Demo App

Back to `interop-escrow-double-zero` repo:
```bash
cd web
cp .env.example .env
# Populate .env with your contract addresses

pnpm install
pnpm dev
```

Now open the app: http://localhost:3000/trade

## Troubleshooting

### Port Conflicts

This setup launches many services on different ports. If you see an error about a busy port:
```bash
# Replace 3010 with the conflicting port
lsof -i :3010
kill -9 <PID>
```
Then re-run the affected launch script.

### Browser Wallet Extensions

Ensure **only MetaMask** is enabled in your browser. Disable other wallet extensions (e.g., Coinbase Wallet, WalletConnect) to avoid conflicts when connecting to private RPCs.

---

**Limitations**

- Currently, you can only **propose** trades from **Chain A**.
- Permissions and interop are proof-of-concept; production setups require hardened security.

