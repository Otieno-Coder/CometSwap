// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {CollateralSwapRouter} from "../src/CollateralSwapRouter.sol";
import {UniswapV3Swapper} from "../src/UniswapV3Swapper.sol";

/**
 * @title Deploy
 * @notice Deployment script for Comet Collateral Swap Router
 * @dev Deploys to mainnet fork or live mainnet
 */
contract Deploy is Script {
    // ============ Constants ============
    
    // Mainnet addresses
    address constant COMET = 0xc3d688B66703497DAA19211EEdff47f25384cdc3;
    address constant AAVE_POOL = 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2;
    address constant UNISWAP_SWAP_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    function run() external {
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80; // Anvil default
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying contracts...");
        console.log("Deployer:", deployer);
        console.log("Deployer balance:", deployer.balance);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy UniswapV3Swapper
        console.log("\n=== Deploying UniswapV3Swapper ===");
        UniswapV3Swapper swapper = new UniswapV3Swapper(UNISWAP_SWAP_ROUTER);
        console.log("UniswapV3Swapper deployed at:", address(swapper));

        // Deploy CollateralSwapRouter
        console.log("\n=== Deploying CollateralSwapRouter ===");
        CollateralSwapRouter router = new CollateralSwapRouter(
            COMET,
            USDC,
            AAVE_POOL,
            address(swapper)
        );
        console.log("CollateralSwapRouter deployed at:", address(router));

        vm.stopBroadcast();

        // Log deployment summary
        console.log("\n=== Deployment Summary ===");
        console.log("Network: Mainnet Fork");
        console.log("Comet:", COMET);
        console.log("Aave Pool:", AAVE_POOL);
        console.log("Uniswap Router:", UNISWAP_SWAP_ROUTER);
        console.log("USDC:", USDC);
        console.log("Swapper:", address(swapper));
        console.log("Router:", address(router));

        // Verification commands
        console.log("\n=== Verification Commands ===");
        console.log("forge verify-contract --chain-id 1 --num-of-optimizations 200 --watch --constructor-args $(cast abi-encode \"constructor(address)\" \"0xE592427A0AEce92De3Edee1F18E0157C05861564\") --etherscan-api-key $ETHERSCAN_API_KEY %s src/UniswapV3Swapper.sol:UniswapV3Swapper", address(swapper));
        console.log("forge verify-contract --chain-id 1 --num-of-optimizations 200 --watch --constructor-args $(cast abi-encode \"constructor(address,address,address,address)\" \"0xc3d688B66703497DAA19211EEdff47f25384cdc3\" \"0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48\" \"0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2\" \"%s\") --etherscan-api-key $ETHERSCAN_API_KEY %s src/CollateralSwapRouter.sol:CollateralSwapRouter", address(swapper), address(router));

        // Test deployment
        console.log("\n=== Testing Deployment ===");
        _testDeployment(router, swapper);
    }

    function _testDeployment(CollateralSwapRouter router, UniswapV3Swapper swapper) internal view {
        // Test router configuration
        (address comet, address baseToken, address aavePool, address swapperAddr) = router.marketConfig();
        
        console.log("Router config verification:");
        console.log("  Comet:", comet);
        console.log("  Base Token:", baseToken);
        console.log("  Aave Pool:", aavePool);
        console.log("  Swapper:", swapperAddr);
        
        // Verify configuration
        require(comet == COMET, "Invalid Comet address");
        require(baseToken == USDC, "Invalid base token address");
        require(aavePool == AAVE_POOL, "Invalid Aave pool address");
        require(swapperAddr == address(swapper), "Invalid swapper address");
        
        console.log("Configuration verified");
        
        // Test swapper configuration
        address swapRouter = swapper.SWAP_ROUTER();
        require(swapRouter == UNISWAP_SWAP_ROUTER, "Invalid swap router address");
        
        console.log("Swapper configuration verified");
        console.log("Deployment test passed");
    }
}
