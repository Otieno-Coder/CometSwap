#!/bin/bash

echo "🔍 Testing Network Connection..."
echo ""

# Test Anvil connection
echo "1. Testing Anvil connection..."
CHAIN_ID=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' http://localhost:8545 | jq -r '.result' | xargs printf "%d\n")
echo "Anvil Chain ID: $CHAIN_ID"

# Test frontend connection
echo ""
echo "2. Testing frontend connection..."
if curl -s http://localhost:3000 > /dev/null; then
    echo "✅ Frontend is running on http://localhost:3000"
else
    echo "❌ Frontend is not running"
    exit 1
fi

# Test contract addresses
echo ""
echo "3. Testing contract addresses..."
ROUTER_ADDRESS=$(grep "NEXT_PUBLIC_ROUTER_ADDRESS" frontend/.env.local | cut -d'=' -f2)
SWAPPER_ADDRESS=$(grep "NEXT_PUBLIC_SWAPPER_ADDRESS" frontend/.env.local | cut -d'=' -f2)

echo "Router Address: $ROUTER_ADDRESS"
echo "Swapper Address: $SWAPPER_ADDRESS"

# Test if contracts exist on Anvil
echo ""
echo "4. Testing contract deployment..."
if [ -n "$ROUTER_ADDRESS" ] && [ "$ROUTER_ADDRESS" != "" ]; then
    CODE=$(curl -s -X POST -H "Content-Type: application/json" --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getCode\",\"params\":[\"$ROUTER_ADDRESS\", \"latest\"],\"id\":1}" http://localhost:8545 | jq -r '.result')
    if [ "$CODE" != "0x" ]; then
        echo "✅ Router contract deployed"
    else
        echo "❌ Router contract not found"
    fi
else
    echo "⚠️  Router address not set"
fi

if [ -n "$SWAPPER_ADDRESS" ] && [ "$SWAPPER_ADDRESS" != "" ]; then
    CODE=$(curl -s -X POST -H "Content-Type: application/json" --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getCode\",\"params\":[\"$SWAPPER_ADDRESS\", \"latest\"],\"id\":1}" http://localhost:8545 | jq -r '.result')
    if [ "$CODE" != "0x" ]; then
        echo "✅ Swapper contract deployed"
    else
        echo "❌ Swapper contract not found"
    fi
else
    echo "⚠️  Swapper address not set"
fi

echo ""
echo "🎯 MetaMask Configuration (Updated):"
echo "===================================="
echo "Network Name: Anvil Local"
echo "RPC URL: http://localhost:8545"
echo "Chain ID: $CHAIN_ID"
echo "Currency Symbol: ETH"
echo "Block Explorer URL: (leave empty)"
echo ""
echo "🔑 Test Account:"
echo "Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
echo "Address: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
echo ""
echo "✅ Configuration should now work with Chain ID: $CHAIN_ID"
