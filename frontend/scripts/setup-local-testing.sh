#!/bin/bash

# Setup script for local Anvil testing
echo "🚀 Setting up Comet Collateral Swap for local testing..."

# Check if Anvil is running
if ! curl -s http://localhost:8545 > /dev/null; then
    echo "❌ Anvil is not running on localhost:8545"
    echo "Please start Anvil with: anvil --fork-url https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY"
    exit 1
fi

echo "✅ Anvil is running"

# Create .env.local file
cat > .env.local << EOF
# Local Anvil Fork Configuration
NEXT_PUBLIC_MAINNET_RPC_URL=http://localhost:8545
NEXT_PUBLIC_CHAIN_ID=1

# Contract Addresses (will be set after deployment to Anvil)
NEXT_PUBLIC_COMET_ADDRESS=0xc3d688B66703497DAA19211EEdff47f25384cdc3
NEXT_PUBLIC_ROUTER_ADDRESS=
NEXT_PUBLIC_SWAPPER_ADDRESS=
NEXT_PUBLIC_AAVE_POOL_ADDRESS=0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2

# WalletConnect Project ID (demo for local testing)
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=demo-project-id
EOF

echo "✅ Created .env.local file"

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Deploy contracts to Anvil:"
echo "   cd ../ && forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast"
echo ""
echo "2. Update contract addresses in .env.local with the deployed addresses"
echo ""
echo "3. Start the frontend:"
echo "   npm run dev"
echo ""
echo "4. Open http://localhost:3000 in your browser"
echo ""
echo "5. Connect MetaMask to Anvil (Chain ID: 31337, RPC: http://localhost:8545)"
