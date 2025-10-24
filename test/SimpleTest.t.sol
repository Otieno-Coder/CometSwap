// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {CollateralSwapRouter} from "../src/CollateralSwapRouter.sol";
import {UniswapV3Swapper} from "../src/UniswapV3Swapper.sol";
import {IComet} from "../src/interfaces/IComet.sol";

/**
 * @title SimpleTest
 * @notice Simple test to verify basic functionality
 */
contract SimpleTest is Test {
    // Mainnet addresses
    address constant COMET = 0xc3d688B66703497DAA19211EEdff47f25384cdc3;
    address constant AAVE_POOL = 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2;
    address constant UNISWAP_SWAP_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    CollateralSwapRouter public router;
    UniswapV3Swapper public swapper;
    IComet public comet;

    function setUp() public {
        // Fork mainnet
        vm.createFork(vm.envString("MAINNET_RPC_URL"));
        vm.selectFork(vm.createFork(vm.envString("MAINNET_RPC_URL")));
        vm.rollFork(20000000); // Use a more recent block

        // Initialize contracts
        comet = IComet(COMET);
        
        // Deploy swapper
        swapper = new UniswapV3Swapper(UNISWAP_SWAP_ROUTER);

        // Deploy router
        router = new CollateralSwapRouter(
            COMET,
            USDC,
            AAVE_POOL,
            address(swapper)
        );
    }

    function testBasicDeployment() public {
        // Test that contracts deployed correctly
        assertTrue(address(router) != address(0));
        assertTrue(address(swapper) != address(0));
        
        // Test configuration
        (address cometAddr, address baseToken, address aavePool, address swapperAddr) = router.marketConfig();
        assertEq(cometAddr, COMET);
        assertEq(baseToken, USDC);
        assertEq(aavePool, AAVE_POOL);
        assertEq(swapperAddr, address(swapper));
    }

    function testCometConnection() public {
        // Test that we can read from Comet
        uint8 numAssets = comet.numAssets();
        assertTrue(numAssets > 0);
        console.log("Number of assets:", numAssets);
        
        // Test getting asset info
        IComet.AssetInfo memory asset0 = comet.getAssetInfo(0);
        console.log("Asset 0 address:", asset0.asset);
        assertTrue(asset0.asset != address(0));
    }

    function testAssetValidation() public {
        // Test with a valid asset (WETH)
        IComet.AssetInfo memory wethInfo = comet.getAssetInfoByAddress(WETH);
        assertTrue(wethInfo.asset == WETH);
        console.log("WETH borrow factor:", wethInfo.borrowCollateralFactor);
        
        // Test with an invalid asset
        address invalidAsset = 0x1111111111111111111111111111111111111111;
        vm.expectRevert();
        comet.getAssetInfoByAddress(invalidAsset);
    }

    function testPreviewFunction() public {
        // Test preview function with a valid asset
        (bool canWithdraw, uint256 newCapacity) = router.previewDirectWithdrawHeadroom(
            COMET,
            address(this),
            WETH,
            1 ether
        );
        
        // Should be able to withdraw 0 (no collateral supplied)
        assertTrue(canWithdraw);
        assertEq(newCapacity, 0);
    }

    function testSwapValidation() public {
        // Test swap validation with same asset (should revert)
        CollateralSwapRouter.SwapExactInParams memory params = CollateralSwapRouter.SwapExactInParams({
            comet: COMET,
            account: address(this),
            fromAsset: WETH,
            toAsset: WETH, // Same asset
            fromAmount: 1 ether,
            minToAsset: 0,
            swapData: abi.encode(uint24(3000)),
            useFlashLoan: false,
            receiver: address(this)
        });

        vm.expectRevert(CollateralSwapRouter.InvalidConfig.selector);
        router.swapCollateralExactIn(params);
    }
}
// Updated: Enhanced error handling
