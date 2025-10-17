# Comet Collateral Swap Router

A smart contract system for atomically replacing collateral on Compound v3 (Comet) protocol. Supports both direct and flash-assisted swap modes to maintain user health factors during collateral swaps.

## Overview

The Comet Collateral Swap Router allows users to atomically replace one collateral asset with another on Compound v3 while maintaining their position's health factor. The system supports two modes:

- **Direct Mode**: For users with sufficient headroom to safely withdraw collateral
- **Flash-Assisted Mode**: Uses Aave V3 flash loans to temporarily repay debt when near liquidation thresholds

## Architecture

### Core Contracts

1. **`CollateralSwapRouter`**: Main router contract that orchestrates collateral swaps
2. **`UniswapV3Swapper`**: Adapter for Uniswap V3 token swaps
3. **Interface Contracts**: `IComet`, `IAaveV3Pool`, `ISwapper`

### Key Features

- **Atomic Operations**: All-or-nothing execution ensures position safety
- **Health Factor Protection**: Prevents liquidations during swaps
- **Dual Mode Support**: Direct swaps for efficiency, flash loans for safety
- **Manager Access**: Support for account delegation via Comet's allow mechanism
- **Slippage Protection**: Configurable minimum output amounts
- **Modular Design**: Pluggable swapper interface for different DEXs

## Installation

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Node.js (for testing)

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd cometswap
```

2. Install dependencies:
```bash
forge install
```

3. Set up environment variables:
```bash
cp env.example .env
# Edit .env with your RPC URLs and API keys
```

4. Compile contracts:
```bash
forge build
```

## Usage

### Basic Swap

```solidity
// Prepare swap parameters
CollateralSwapRouter.SwapExactInParams memory params = CollateralSwapRouter.SwapExactInParams({
    comet: COMET_ADDRESS,
    account: userAddress,
    fromAsset: WBTC_ADDRESS,
    toAsset: WETH_ADDRESS,
    fromAmount: 0.1 ether,
    minToAsset: 0.05 ether, // 50% slippage tolerance
    swapData: abi.encode(uint24(3000)), // 0.3% Uniswap fee
    useFlashLoan: false,
    receiver: userAddress
});

// Execute swap
router.swapCollateralExactIn(params);
```

### Flash-Assisted Swap

```solidity
// Same parameters but with useFlashLoan: true
params.useFlashLoan = true;
router.swapCollateralExactIn(params);
```

### Manager Access

```solidity
// Allow manager to operate on behalf of user
comet.allow(managerAddress, true);

// Manager can now execute swaps for the user
router.swapCollateralExactIn(params);
```

## Testing

### Run Tests

```bash
# Run all tests
forge test

# Run with verbosity
forge test -vvv

# Run specific test
forge test --match-test testDirectSwap_WBTC_to_WETH

# Run with gas reporting
forge test --gas-report
```

### Test Coverage

```bash
forge coverage
```

### Fork Testing

The tests use mainnet fork to ensure realistic testing conditions:

```bash
# Start Anvil fork
anvil --fork-url $MAINNET_RPC_URL --fork-block-number 19000000

# Run tests against fork
forge test --fork-url http://127.0.0.1:8545
```

## Deployment

### Deploy to Mainnet Fork

```bash
# Start Anvil
anvil --fork-url $MAINNET_RPC_URL --fork-block-number 19000000

# Deploy
forge script script/Deploy.s.sol --fork-url http://127.0.0.1:8545 --broadcast
```

### Deploy to Mainnet

```bash
# Set environment variables
export PRIVATE_KEY=your_private_key
export ETHERSCAN_API_KEY=your_api_key

# Deploy
forge script script/Deploy.s.sol --rpc-url $MAINNET_RPC_URL --broadcast --verify
```

## Configuration

### Mainnet Addresses

- **Comet (cUSDCv3)**: `0xc3d688B66703497DAA19211EEdff47f25384cdc3`
- **Aave V3 Pool**: `0x87870bca3f3fd6335c3f4ce8392d69350b4fa4e2`
- **Uniswap V3 Router**: `0xE592427A0AEce92De3Edee1F18E0157C05861564`
- **USDC**: `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`

### Supported Assets

The router supports all collateral assets enabled on the Comet market. Check the Comet contract for the current list of supported assets.

## Security Considerations

### Health Factor Protection

The router implements multiple layers of health factor protection:

1. **Pre-swap validation**: Checks if direct withdrawal is safe
2. **Flash loan safety**: Temporarily reduces debt during swaps
3. **Post-swap verification**: Ensures position remains collateralized

### Slippage Protection

- Minimum output amounts prevent excessive slippage
- Configurable slippage tolerance per swap
- Real-time price validation

### Access Control

- Manager access via Comet's native allow mechanism
- Owner-only configuration updates
- Reentrancy protection on all external functions

## Gas Optimization

### Direct Mode (Recommended)

- **Gas Cost**: ~150,000 gas
- **Use Case**: Users with sufficient headroom
- **Operations**: withdraw → swap → supply

### Flash-Assisted Mode

- **Gas Cost**: ~300,000 gas
- **Use Case**: Users near liquidation thresholds
- **Operations**: flash loan → repay debt → withdraw → swap → supply → re-borrow → repay flash loan

## API Reference

### CollateralSwapRouter

#### Functions

- `swapCollateralExactIn(SwapExactInParams calldata params)`: Execute collateral swap
- `previewDirectWithdrawHeadroom(address comet, address account, address asset, uint256 withdrawAmount)`: Check if direct withdrawal is safe
- `quoteSwapOut(address swapper, address tokenIn, address tokenOut, uint256 amountIn, bytes calldata swapData)`: Quote swap output

#### Events

- `CollateralSwapped(address indexed account, address indexed comet, address indexed fromAsset, address toAsset, uint256 fromAmount, uint256 toAmount, bool flashUsed)`

#### Errors

- `UnsupportedAsset(address asset)`: Asset not supported by Comet
- `HealthFactorTooLow()`: Direct withdrawal would cause liquidation
- `SlippageExceeded(uint256 expected, uint256 min)`: Output below minimum threshold
- `NotManager()`: Caller not authorized to manage account

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Disclaimer

This software is provided as-is. Use at your own risk. Always audit smart contracts before using with real funds.