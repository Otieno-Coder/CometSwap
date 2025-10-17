#!/bin/bash

echo "🔍 Verifying Anvil Connection..."
echo ""

# Check if Anvil is running
echo "1. Checking if Anvil is running on localhost:8545..."
if curl -s http://localhost:8545 > /dev/null; then
    echo "✅ Anvil is running"
else
    echo "❌ Anvil is not running. Please start it with:"
    echo "   anvil --fork-url https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY"
    exit 1
fi

echo ""

# Get chain ID
echo "2. Getting chain ID..."
CHAIN_ID=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' http://localhost:8545 | jq -r '.result' | xargs printf "%d\n")
echo "Chain ID: $CHAIN_ID"

# Get latest block
echo ""
echo "3. Getting latest block..."
BLOCK_NUMBER=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' http://localhost:8545 | jq -r '.result' | xargs printf "%d\n")
echo "Latest block: $BLOCK_NUMBER"

# Get test account balance
echo ""
echo "4. Checking test account balance..."
BALANCE=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_getBalance","params":["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", "latest"],"id":1}' http://localhost:8545 | jq -r '.result' | xargs printf "%d\n")
ETH_BALANCE=$(echo "scale=4; $BALANCE / 1000000000000000000" | bc)
echo "Test account balance: $ETH_BALANCE ETH"

echo ""
echo "🎯 MetaMask Configuration:"
echo "=========================="
echo "Network Name: Anvil Local"
echo "RPC URL: http://localhost:8545"
echo "Chain ID: $CHAIN_ID"
echo "Currency Symbol: ETH"
echo "Block Explorer URL: (leave empty)"
echo ""
echo "🔑 Test Account Private Key:"
echo "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
echo ""
echo "📍 Test Account Address:"
echo "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
echo ""
echo "💰 Account Balance: $ETH_BALANCE ETH"
echo ""
echo "✅ Configuration complete! Use these settings in MetaMask."
