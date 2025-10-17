#!/bin/bash

# Deploy contracts to Anvil and update frontend environment
echo "🚀 Deploying contracts to Anvil..."

# Check if Anvil is running
if ! curl -s http://localhost:8545 > /dev/null; then
    echo "❌ Anvil is not running on localhost:8545"
    echo "Please start Anvil with: anvil --fork-url https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY"
    exit 1
fi

echo "✅ Anvil is running"

# Deploy contracts
echo "📦 Deploying contracts..."
cd "$(dirname "$0")/.."
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast

# Extract deployed addresses from the output
echo "🔍 Extracting deployed addresses..."

# This is a simplified approach - in practice, you'd parse the forge output
# For now, we'll create a template that you can fill in manually
cat > frontend/.env.local << EOF
# Local Anvil Fork Configuration
NEXT_PUBLIC_MAINNET_RPC_URL=http://localhost:8545
NEXT_PUBLIC_CHAIN_ID=1

# Contract Addresses (update with deployed addresses from forge output)
NEXT_PUBLIC_COMET_ADDRESS=0xc3d688B66703497DAA19211EEdff47f25384cdc3
NEXT_PUBLIC_ROUTER_ADDRESS=0x[UPDATE_WITH_DEPLOYED_ROUTER_ADDRESS]
NEXT_PUBLIC_SWAPPER_ADDRESS=0x[UPDATE_WITH_DEPLOYED_SWAPPER_ADDRESS]
NEXT_PUBLIC_AAVE_POOL_ADDRESS=0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2

# WalletConnect Project ID (demo for local testing)
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=demo-project-id
EOF

echo "✅ Created frontend/.env.local template"
echo ""
echo "📝 Next steps:"
echo "1. Check the forge output above for deployed contract addresses"
echo "2. Update the addresses in frontend/.env.local"
echo "3. Start the frontend: cd frontend && npm run dev:local"
echo ""
echo "🔗 Contract addresses to update:"
echo "   - ROUTER_ADDRESS: [Check forge output]"
echo "   - SWAPPER_ADDRESS: [Check forge output]"
