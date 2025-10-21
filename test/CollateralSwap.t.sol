// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {CollateralSwapRouter} from "../src/CollateralSwapRouter.sol";
import {UniswapV3Swapper} from "../src/UniswapV3Swapper.sol";
import {IComet} from "../src/interfaces/IComet.sol";
import {IAaveV3Pool} from "../src/interfaces/IAaveV3Pool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title CollateralSwapTest
 * @notice Test suite for CollateralSwapRouter
 * @dev Tests both direct and flash-assisted swap modes
 */
contract CollateralSwapTest is Test {
    // ============ Constants ============
    
    // Mainnet addresses
    address constant COMET = 0xc3d688B66703497DAA19211EEdff47f25384cdc3;
    address constant AAVE_POOL = 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2;
    address constant UNISWAP_SWAP_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    
    // Test accounts
    address constant USER = 0x1234567890123456789012345678901234567890;
    address constant MANAGER = 0x2345678901234567890123456789012345678901;
    
    // Fork block
    uint256 constant FORK_BLOCK = 19000000;

    // ============ State ============
    
    CollateralSwapRouter public router;
    UniswapV3Swapper public swapper;
    IComet public comet;
    IAaveV3Pool public aavePool;
    IERC20 public usdc;
    IERC20 public weth;
    IERC20 public wbtc;

    // ============ Setup ============

    function setUp() public {
        // Fork mainnet
        vm.createFork(vm.envString("MAINNET_RPC_URL"));
        vm.selectFork(vm.createFork(vm.envString("MAINNET_RPC_URL")));
        vm.rollFork(FORK_BLOCK);

        // Initialize contracts
        comet = IComet(COMET);
        aavePool = IAaveV3Pool(AAVE_POOL);
        usdc = IERC20(USDC);
        weth = IERC20(WETH);
        wbtc = IERC20(WBTC);

        // Deploy swapper
        swapper = new UniswapV3Swapper(UNISWAP_SWAP_ROUTER);

        // Deploy router
        router = new CollateralSwapRouter(
            COMET,
            USDC,
            AAVE_POOL,
            address(swapper)
        );

        // Setup test accounts
        vm.deal(USER, 100 ether);
        vm.deal(MANAGER, 100 ether);
    }

    // ============ Helper Functions ============

    function _dealTokens(address to, address token, uint256 amount) internal {
        // Deal tokens to the account
        deal(token, to, amount);
        
        // Approve Comet to spend tokens
        vm.prank(to);
        IERC20(token).approve(COMET, amount);
    }

    function _setupUserPosition(address user, uint256 wbtcAmount, uint256 usdcBorrow) internal {
        // Deal WBTC to user
        _dealTokens(user, WBTC, wbtcAmount);
        
        // Supply WBTC as collateral
        vm.prank(user);
        comet.supply(WBTC, wbtcAmount);
        
        // Borrow USDC
        vm.prank(user);
        comet.withdraw(USDC, usdcBorrow);
    }

    function _getSwapData(uint24 fee) internal pure returns (bytes memory) {
        return abi.encode(fee);
    }

    // ============ Direct Swap Tests ============

    function testDirectSwap_WBTC_to_WETH() public {
        // Setup user position
        uint256 wbtcAmount = 0.1 ether; // 0.1 WBTC
        uint256 usdcBorrow = 1000 * 1e6; // $1000 USDC
        _setupUserPosition(USER, wbtcAmount, usdcBorrow);

        // Check initial state
        uint256 initialWbtc = comet.collateralBalanceOf(USER, WBTC);
        uint256 initialWeth = comet.collateralBalanceOf(USER, WETH);
        uint256 initialBorrow = comet.borrowBalanceOf(USER);

        console.log("Initial WBTC collateral:", initialWbtc);
        console.log("Initial WETH collateral:", initialWeth);
        console.log("Initial borrow:", initialBorrow);

        // Prepare swap parameters
        CollateralSwapRouter.SwapExactInParams memory params = CollateralSwapRouter.SwapExactInParams({
            comet: COMET,
            account: USER,
            fromAsset: WBTC,
            toAsset: WETH,
            fromAmount: wbtcAmount / 2, // Swap half
            minToAsset: 0, // No slippage protection for test
            swapData: _getSwapData(3000), // 0.3% fee
            useFlashLoan: false,
            receiver: USER
        });

        // Execute swap
        vm.prank(USER);
        router.swapCollateralExactIn(params);

        // Check final state
        uint256 finalWbtc = comet.collateralBalanceOf(USER, WBTC);
        uint256 finalWeth = comet.collateralBalanceOf(USER, WETH);
        uint256 finalBorrow = comet.borrowBalanceOf(USER);

        console.log("Final WBTC collateral:", finalWbtc);
        console.log("Final WETH collateral:", finalWeth);
        console.log("Final borrow:", finalBorrow);

        // Assertions
        assertTrue(finalWbtc < initialWbtc, "WBTC should decrease");
        assertTrue(finalWeth > initialWeth, "WETH should increase");
        assertEq(finalBorrow, initialBorrow, "Borrow should remain same");
        assertTrue(comet.isBorrowCollateralized(USER), "User should remain collateralized");
    }

    function testDirectSwap_RevertWhen_HealthFactorTooLow() public {
        // Setup user position near liquidation
        uint256 wbtcAmount = 0.1 ether;
        uint256 usdcBorrow = 5000 * 1e6; // High borrow
        _setupUserPosition(USER, wbtcAmount, usdcBorrow);

        // Try to swap too much WBTC
        CollateralSwapRouter.SwapExactInParams memory params = CollateralSwapRouter.SwapExactInParams({
            comet: COMET,
            account: USER,
            fromAsset: WBTC,
            toAsset: WETH,
            fromAmount: wbtcAmount, // Try to swap all
            minToAsset: 0,
            swapData: _getSwapData(3000),
            useFlashLoan: false,
            receiver: USER
        });

        // Should revert
        vm.prank(USER);
        vm.expectRevert(CollateralSwapRouter.HealthFactorTooLow.selector);
        router.swapCollateralExactIn(params);
    }

    // ============ Flash-Assisted Swap Tests ============

    function testFlashAssistedSwap() public {
        // Setup user position near liquidation
        uint256 wbtcAmount = 0.1 ether;
        uint256 usdcBorrow = 4000 * 1e6; // High borrow
        _setupUserPosition(USER, wbtcAmount, usdcBorrow);

        // Check initial state
        uint256 initialWbtc = comet.collateralBalanceOf(USER, WBTC);
        uint256 initialWeth = comet.collateralBalanceOf(USER, WETH);
        uint256 initialBorrow = comet.borrowBalanceOf(USER);

        console.log("Initial WBTC collateral:", initialWbtc);
        console.log("Initial WETH collateral:", initialWeth);
        console.log("Initial borrow:", initialBorrow);

        // Prepare swap parameters
        CollateralSwapRouter.SwapExactInParams memory params = CollateralSwapRouter.SwapExactInParams({
            comet: COMET,
            account: USER,
            fromAsset: WBTC,
            toAsset: WETH,
            fromAmount: wbtcAmount / 2,
            minToAsset: 0,
            swapData: _getSwapData(3000),
            useFlashLoan: true,
            receiver: USER
        });

        // Execute swap
        vm.prank(USER);
        router.swapCollateralExactIn(params);

        // Check final state
        uint256 finalWbtc = comet.collateralBalanceOf(USER, WBTC);
        uint256 finalWeth = comet.collateralBalanceOf(USER, WETH);
        uint256 finalBorrow = comet.borrowBalanceOf(USER);

        console.log("Final WBTC collateral:", finalWbtc);
        console.log("Final WETH collateral:", finalWeth);
        console.log("Final borrow:", finalBorrow);

        // Assertions
        assertTrue(finalWbtc < initialWbtc, "WBTC should decrease");
        assertTrue(finalWeth > initialWeth, "WETH should increase");
        assertTrue(comet.isBorrowCollateralized(USER), "User should remain collateralized");
    }

    // ============ Slippage Tests ============

    function testSlippageRevert() public {
        // Setup user position
        uint256 wbtcAmount = 0.1 ether;
        uint256 usdcBorrow = 1000 * 1e6;
        _setupUserPosition(USER, wbtcAmount, usdcBorrow);

        // Prepare swap with unrealistic min amount
        CollateralSwapRouter.SwapExactInParams memory params = CollateralSwapRouter.SwapExactInParams({
            comet: COMET,
            account: USER,
            fromAsset: WBTC,
            toAsset: WETH,
            fromAmount: wbtcAmount / 2,
            minToAsset: 1000 ether, // Unrealistic minimum
            swapData: _getSwapData(3000),
            useFlashLoan: false,
            receiver: USER
        });

        // Should revert due to slippage
        vm.prank(USER);
        vm.expectRevert(CollateralSwapRouter.SlippageExceeded.selector);
        router.swapCollateralExactIn(params);
    }

    // ============ Asset Validation Tests ============

    function testUnsupportedAsset() public {
        address unsupportedAsset = 0x1111111111111111111111111111111111111111;

        CollateralSwapRouter.SwapExactInParams memory params = CollateralSwapRouter.SwapExactInParams({
            comet: COMET,
            account: USER,
            fromAsset: unsupportedAsset,
            toAsset: WETH,
            fromAmount: 1 ether,
            minToAsset: 0,
            swapData: _getSwapData(3000),
            useFlashLoan: false,
            receiver: USER
        });

        vm.prank(USER);
        vm.expectRevert(); // Comet will revert with BadAsset error
        router.swapCollateralExactIn(params);
    }

    // ============ Manager Access Tests ============

    function testManagerAccess() public {
        // Setup user position
        uint256 wbtcAmount = 0.1 ether;
        uint256 usdcBorrow = 1000 * 1e6;
        _setupUserPosition(USER, wbtcAmount, usdcBorrow);

        // Allow manager
        vm.prank(USER);
        comet.allow(MANAGER, true);

        // Prepare swap parameters
        CollateralSwapRouter.SwapExactInParams memory params = CollateralSwapRouter.SwapExactInParams({
            comet: COMET,
            account: USER,
            fromAsset: WBTC,
            toAsset: WETH,
            fromAmount: wbtcAmount / 2,
            minToAsset: 0,
            swapData: _getSwapData(3000),
            useFlashLoan: false,
            receiver: USER
        });

        // Execute swap as manager
        vm.prank(MANAGER);
        router.swapCollateralExactIn(params);

        // Should succeed
        assertTrue(comet.isBorrowCollateralized(USER), "User should remain collateralized");
    }

    function testManagerAccess_RevertWhen_NotAllowed() public {
        // Setup user position
        uint256 wbtcAmount = 0.1 ether;
        uint256 usdcBorrow = 1000 * 1e6;
        _setupUserPosition(USER, wbtcAmount, usdcBorrow);

        // Don't allow manager

        // Prepare swap parameters
        CollateralSwapRouter.SwapExactInParams memory params = CollateralSwapRouter.SwapExactInParams({
            comet: COMET,
            account: USER,
            fromAsset: WBTC,
            toAsset: WETH,
            fromAmount: wbtcAmount / 2,
            minToAsset: 0,
            swapData: _getSwapData(3000),
            useFlashLoan: false,
            receiver: USER
        });

        // Should revert
        vm.prank(MANAGER);
        vm.expectRevert(CollateralSwapRouter.NotManager.selector);
        router.swapCollateralExactIn(params);
    }

    // ============ View Function Tests ============

    function testPreviewDirectWithdrawHeadroom() public {
        // Setup user position
        uint256 wbtcAmount = 0.1 ether;
        uint256 usdcBorrow = 1000 * 1e6;
        _setupUserPosition(USER, wbtcAmount, usdcBorrow);

        // Test safe withdrawal
        (bool canWithdraw, uint256 newCapacity) = router.previewDirectWithdrawHeadroom(
            COMET,
            USER,
            WBTC,
            wbtcAmount / 2
        );

        assertTrue(canWithdraw, "Should be able to withdraw safely");
        assertTrue(newCapacity > 0, "Should have positive capacity");

        // Test unsafe withdrawal
        (bool canWithdrawAll, ) = router.previewDirectWithdrawHeadroom(
            COMET,
            USER,
            WBTC,
            wbtcAmount
        );

        assertFalse(canWithdrawAll, "Should not be able to withdraw all");
    }

    // ============ Edge Cases ============

    function testSameAssetRevert() public {
        CollateralSwapRouter.SwapExactInParams memory params = CollateralSwapRouter.SwapExactInParams({
            comet: COMET,
            account: USER,
            fromAsset: WBTC,
            toAsset: WBTC, // Same asset
            fromAmount: 1 ether,
            minToAsset: 0,
            swapData: _getSwapData(3000),
            useFlashLoan: false,
            receiver: USER
        });

        vm.prank(USER);
        vm.expectRevert(CollateralSwapRouter.InvalidConfig.selector);
        router.swapCollateralExactIn(params);
    }

    function testZeroAmountRevert() public {
        CollateralSwapRouter.SwapExactInParams memory params = CollateralSwapRouter.SwapExactInParams({
            comet: COMET,
            account: USER,
            fromAsset: WBTC,
            toAsset: WETH,
            fromAmount: 0, // Zero amount
            minToAsset: 0,
            swapData: _getSwapData(3000),
            useFlashLoan: false,
            receiver: USER
        });

        vm.prank(USER);
        vm.expectRevert(CollateralSwapRouter.InvalidConfig.selector);
        router.swapCollateralExactIn(params);
    }
}
// Updated: Comprehensive test suite
