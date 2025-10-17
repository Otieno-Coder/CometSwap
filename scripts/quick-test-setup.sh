#!/bin/bash

echo "🚀 Quick Test Setup for Comet Collateral Swap"
echo "=============================================="
echo ""

# Check if Anvil is running
echo "1. Checking Anvil connection..."
if curl -s http://localhost:8545 > /dev/null; then
    echo "✅ Anvil is running"
else
    echo "❌ Anvil is not running. Please start it first:"
    echo "   anvil --fork-url https://eth-mainnet.g.alchemy.com/v2/-9qz-DtOGipKb25eo-uCFmudmEqxgPbV"
    exit 1
fi

# Check if contracts are deployed
echo ""
echo "2. Checking contract deployment..."
ROUTER_ADDRESS=$(grep "NEXT_PUBLIC_ROUTER_ADDRESS" frontend/.env.local 2>/dev/null | cut -d'=' -f2)
if [ -n "$ROUTER_ADDRESS" ] && [ "$ROUTER_ADDRESS" != "" ]; then
    echo "✅ Contracts are deployed"
    echo "   Router: $ROUTER_ADDRESS"
else
    echo "⚠️  Contracts not deployed. Deploying now..."
    ./scripts/deploy-to-anvil.sh
fi

# Check frontend
echo ""
echo "3. Checking frontend..."
if curl -s http://localhost:3000 > /dev/null; then
    echo "✅ Frontend is running at http://localhost:3000"
else
    echo "⚠️  Frontend not running. Starting now..."
    cd frontend && npm run dev:local &
    sleep 5
    cd ..
fi

# Get current balances
echo ""
echo "4. Current test account balances:"
ETH_BALANCE=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_getBalance","params":["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", "latest"],"id":1}' http://localhost:8545 | jq -r '.result' | xargs printf "%d\n" | awk '{print $1/1000000000000000000}')
WETH_BALANCE=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_call","params":[{"to":"0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2","data":"0x70a08231000000000000000000000000f39Fd6e51aad88F6F4ce6aB8827279cffFb92266"},"latest"],"id":1}' http://localhost:8545 | jq -r '.result' | xargs printf "%d\n" | awk '{print $1/1000000000000000000}')

echo "   ETH: $ETH_BALANCE ETH (for gas)"
echo "   WETH: $WETH_BALANCE WETH (for testing)"

echo ""
echo "🎯 Ready to test! Here's what to do:"
echo "===================================="
echo ""
echo "1. Open MetaMask and add network:"
echo "   - Network Name: Anvil Local"
echo "   - RPC URL: http://localhost:8545"
echo "   - Chain ID: 1"
echo "   - Currency Symbol: ETH"
echo ""
echo "2. Import test account:"
echo "   - Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
echo ""
echo "3. Go to: http://localhost:3000/swap"
echo ""
echo "4. Try this test swap:"
echo "   - From: WETH"
echo "   - To: USDC"
echo "   - Amount: 0.1 WETH"
echo "   - Mode: Direct"
echo ""
echo "5. Check the TEST_VALUES.md file for more test scenarios"
echo ""
echo "Happy testing! 🎉"
