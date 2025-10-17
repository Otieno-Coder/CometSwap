#!/bin/bash

echo "🚀 Setting up Comet position for testing..."

# First, wrap some ETH to WETH
echo "1. Wrapping ETH to WETH..."
curl -s -X POST -H "Content-Type: application/json" \
  --data '{
    "jsonrpc":"2.0",
    "method":"eth_sendTransaction",
    "params":[{
      "from":"0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
      "to":"0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
      "value":"0x16345785d8a0000",
      "data":"0xd0e30db0"
    }],
    "id":1
  }' http://localhost:8545

echo ""
echo "2. Approving WETH for Comet..."
curl -s -X POST -H "Content-Type: application/json" \
  --data '{
    "jsonrpc":"2.0",
    "method":"eth_sendTransaction",
    "params":[{
      "from":"0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
      "to":"0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
      "data":"0x095ea7b3000000000000000000000000c3d688b66703497daa19211eedff47f25384cdc30000000000000000000000000000000000000000000000000de0b6b3a7640000"
    }],
    "id":1
  }' http://localhost:8545

echo ""
echo "3. Supplying WETH to Comet..."
curl -s -X POST -H "Content-Type: application/json" \
  --data '{
    "jsonrpc":"2.0",
    "method":"eth_sendTransaction",
    "params":[{
      "from":"0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
      "to":"0xc3d688B66703497DAA19211EEdff47f25384cdc3",
      "data":"0x0e752702000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc20000000000000000000000000000000000000000000000000de0b6b3a7640000"
    }],
    "id":1
  }' http://localhost:8545

echo ""
echo "✅ Position setup complete! Now you can test swaps."
