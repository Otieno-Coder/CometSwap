# Local Testing Guide

This guide explains how to test the Comet Collateral Swap frontend with a local Anvil fork.

## Prerequisites

1. **Anvil running** with mainnet fork
2. **MetaMask** configured for local testing
3. **Contracts deployed** to Anvil

## Step 1: Start Anvil Fork

```bash
# In the root directory
anvil --fork-url https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY
```

This will start Anvil on `http://localhost:8545` with a mainnet fork.

## Step 2: Deploy Contracts

```bash
# In the root directory
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
```

This will deploy the contracts to your local Anvil fork. Note the deployed addresses.

## Step 3: Configure Frontend

### Option A: Use the setup script
```bash
cd frontend
./scripts/setup-local-testing.sh
```

### Option B: Manual setup
Create `.env.local` file:
```env
# Local Anvil Fork Configuration
NEXT_PUBLIC_MAINNET_RPC_URL=http://localhost:8545
NEXT_PUBLIC_CHAIN_ID=1

# Contract Addresses (update with deployed addresses)
NEXT_PUBLIC_COMET_ADDRESS=0xc3d688B66703497DAA19211EEdff47f25384cdc3
NEXT_PUBLIC_ROUTER_ADDRESS=0x[YOUR_DEPLOYED_ROUTER_ADDRESS]
NEXT_PUBLIC_SWAPPER_ADDRESS=0x[YOUR_DEPLOYED_SWAPPER_ADDRESS]
NEXT_PUBLIC_AAVE_POOL_ADDRESS=0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2

# WalletConnect Project ID (demo for local testing)
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=demo-project-id
```

## Step 4: Configure MetaMask

1. Open MetaMask
2. Click on network dropdown
3. Select "Add network" → "Add a network manually"
4. Enter:
   - **Network name**: Anvil Local
   - **RPC URL**: http://localhost:8545
   - **Chain ID**: 31337
   - **Currency symbol**: ETH
   - **Block explorer URL**: (leave empty)

## Step 5: Import Test Account

Anvil provides test accounts with pre-funded ETH. Import one of these:

**Private Key**: `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`
**Address**: `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`

This account has 10,000 ETH for testing.

## Step 6: Start Frontend

```bash
cd frontend
npm run dev
```

Open http://localhost:3000 in your browser.

## Step 7: Test the Application

1. **Connect Wallet**: Click "Connect Wallet" and select MetaMask
2. **Switch Network**: Ensure you're on the Anvil Local network
3. **Check Position**: The position overview should show your account's state
4. **Test Swap**: Try swapping between different assets

## Troubleshooting

### Frontend won't connect to Anvil
- Ensure Anvil is running on port 8545
- Check that `.env.local` has the correct RPC URL
- Verify MetaMask is on the correct network

### Contracts not found
- Ensure contracts are deployed to Anvil
- Check that contract addresses in `.env.local` are correct
- Verify the contracts are deployed on the correct chain

### Transaction fails
- Ensure you have enough ETH for gas
- Check that the contracts are properly deployed
- Verify the account has the required permissions

### Health factor issues
- The forked mainnet state might not have the expected positions
- You may need to create test positions first
- Check the Comet contract state on Anvil

## Testing Scenarios

### 1. Basic Swap
- Select WETH as from asset
- Select USDC as to asset
- Enter amount (e.g., 0.1 WETH)
- Choose Direct mode
- Execute swap

### 2. Flash Loan Swap
- Create a risky position first
- Try swapping with Flash mode
- Verify the flash loan is used

### 3. Position Management
- Check health factor display
- Verify collateral balances
- Test different asset combinations

## Development Tips

- Use `anvil --fork-url <RPC_URL> --fork-block-number <BLOCK_NUMBER>` to fork from a specific block
- Check Anvil logs for transaction details
- Use `cast` commands to interact with contracts directly
- Monitor gas usage and transaction costs

## Environment Variables

| Variable | Description | Local Value |
|----------|-------------|-------------|
| `NEXT_PUBLIC_MAINNET_RPC_URL` | RPC URL for blockchain | `http://localhost:8545` |
| `NEXT_PUBLIC_CHAIN_ID` | Chain ID | `1` (or `31337` for Anvil) |
| `NEXT_PUBLIC_ROUTER_ADDRESS` | Deployed router address | Set after deployment |
| `NEXT_PUBLIC_SWAPPER_ADDRESS` | Deployed swapper address | Set after deployment |
| `NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID` | WalletConnect project ID | `demo-project-id` |

## Next Steps

Once local testing is complete:
1. Test on testnet (Sepolia)
2. Deploy to mainnet
3. Update production environment variables
4. Configure monitoring and analytics
