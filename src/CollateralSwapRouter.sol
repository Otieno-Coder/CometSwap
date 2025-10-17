// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IComet} from "./interfaces/IComet.sol";
import {IAaveV3Pool, IFlashLoanSimpleReceiver} from "./interfaces/IAaveV3Pool.sol";
import {ISwapper} from "./interfaces/ISwapper.sol";

/**
 * @title CollateralSwapRouter
 * @notice Router for atomically replacing collateral on Compound v3 (Comet)
 * @dev Supports both direct and flash-assisted swap modes
 */
contract CollateralSwapRouter is ReentrancyGuard, Ownable, IFlashLoanSimpleReceiver {
    using SafeERC20 for IERC20;

    // ============ Structs ============

    struct SwapExactInParams {
        address comet;           // Comet proxy (e.g., cUSDCv3)
        address account;         // User whose position we modify
        address fromAsset;       // Collateral we are replacing
        address toAsset;         // Collateral we are acquiring
        uint256 fromAmount;      // Exact collateral amount to replace
        uint256 minToAsset;      // Slippage control (post-swap amount)
        bytes   swapData;        // ABI-encoded params for ISwapper
        bool    useFlashLoan;    // Force flash loan path
        address receiver;        // Optional receiver of dust leftovers
    }

    struct MarketConfig {
        address comet;          // Comet proxy address
        address baseToken;      // Base token (e.g., USDC)
        address aavePool;       // Aave V3 Pool address
        address swapper;        // Swapper contract address
    }

    // ============ Events ============

    event CollateralSwapped(
        address indexed account,
        address indexed comet,
        address indexed fromAsset,
        address toAsset,
        uint256 fromAmount,
        uint256 toAmount,
        bool flashUsed
    );

    // ============ Errors ============

    error UnsupportedAsset(address asset);
    error HealthFactorTooLow();
    error SlippageExceeded(uint256 expected, uint256 min);
    error NotManager();
    error OracleCheckFailed();
    error Reentered();
    error InvalidConfig();
    error SwapFailed();

    // ============ Storage ============

    MarketConfig public marketConfig;
    
    // Flash loan state
    SwapExactInParams private _flashLoanParams;
    bool private _inFlashLoan;

    // ============ Constructor ============

    constructor(
        address _comet,
        address _baseToken,
        address _aavePool,
        address _swapper
    ) Ownable(msg.sender) {
        marketConfig = MarketConfig({
            comet: _comet,
            baseToken: _baseToken,
            aavePool: _aavePool,
            swapper: _swapper
        });
    }

    // ============ External Functions ============

    /**
     * @notice Atomically replace one collateral with another
     * @param params Swap parameters
     */
    function swapCollateralExactIn(SwapExactInParams calldata params) external nonReentrant {
        // Validate parameters
        _validateSwapParams(params);
        
        // Check manager access if account != msg.sender
        if (params.account != msg.sender) {
            if (!IComet(params.comet).hasPermission(params.account, msg.sender)) {
                revert NotManager();
            }
        }

        // Route to appropriate mode
        if (params.useFlashLoan) {
            _executeFlashAssistedSwap(params);
        } else {
            _executeDirectSwap(params);
        }
    }

    /**
     * @notice Preview if direct withdrawal is safe
     * @param comet Comet contract address
     * @param account Account to check
     * @param asset Asset to withdraw
     * @param withdrawAmount Amount to withdraw
     * @return canWithdrawSafely True if safe to withdraw
     * @return newBorrowCapacity New borrow capacity after withdrawal
     */
    function previewDirectWithdrawHeadroom(
        address comet,
        address account,
        address asset,
        uint256 withdrawAmount
    ) external view returns (bool canWithdrawSafely, uint256 newBorrowCapacity) {
        IComet cometContract = IComet(comet);
        
        // Get current borrow balance
        uint256 currentBorrow = cometContract.borrowBalanceOf(account);
        
        // Get asset info
        IComet.AssetInfo memory assetInfo = cometContract.getAssetInfoByAddress(asset);
        if (assetInfo.asset == address(0)) {
            return (false, 0);
        }

        // Calculate collateral value after withdrawal
        uint256 currentCollateral = cometContract.collateralBalanceOf(account, asset);
        uint256 newCollateral = currentCollateral > withdrawAmount ? currentCollateral - withdrawAmount : 0;
        
        // Get price and calculate value
        uint256 price = cometContract.getPrice(assetInfo.priceFeed);
        uint256 collateralValue = (newCollateral * price) / assetInfo.scale;
        
        // Calculate borrow capacity
        newBorrowCapacity = (collateralValue * assetInfo.borrowCollateralFactor) / cometContract.factorScale();
        
        // Check if still collateralized
        canWithdrawSafely = newBorrowCapacity >= currentBorrow;
    }

    /**
     * @notice Quote swap output amount
     * @return expectedOut Expected output amount
     */
    function quoteSwapOut(
        address /* swapper */,
        address /* tokenIn */,
        address /* tokenOut */,
        uint256 /* amountIn */,
        bytes calldata /* swapData */
    ) external pure returns (uint256 expectedOut) {
        // This is a placeholder - in practice, you'd call the swapper's quote function
        // For now, we'll return 0 and handle it in the actual swap
        return 0;
    }

    // ============ Aave Flash Loan Callback ============

    function executeOperation(
        address /* asset */,
        uint256 amount,
        uint256 premium,
        address /* initiator */,
        bytes calldata params
    ) external override returns (bool) {
        if (_inFlashLoan) {
            revert Reentered();
        }
        
        if (msg.sender != marketConfig.aavePool) {
            revert NotManager();
        }

        _inFlashLoan = true;

        // Decode flash loan parameters
        _flashLoanParams = abi.decode(params, (SwapExactInParams));

        // Execute the swap sequence
        _executeFlashSwapSequence(amount, premium);

        _inFlashLoan = false;
        return true;
    }

    // ============ Owner Functions ============

    function updateMarketConfig(
        address _comet,
        address _baseToken,
        address _aavePool,
        address _swapper
    ) external onlyOwner {
        if (_comet == address(0) || _baseToken == address(0) || 
            _aavePool == address(0) || _swapper == address(0)) {
            revert InvalidConfig();
        }
        
        marketConfig = MarketConfig({
            comet: _comet,
            baseToken: _baseToken,
            aavePool: _aavePool,
            swapper: _swapper
        });
    }

    // ============ Internal Functions ============

    function _validateSwapParams(SwapExactInParams calldata params) internal view {
        if (params.fromAsset == params.toAsset) {
            revert InvalidConfig();
        }
        if (params.fromAmount == 0) {
            revert InvalidConfig();
        }
        if (params.comet != marketConfig.comet) {
            revert InvalidConfig();
        }
    }

    function _executeDirectSwap(SwapExactInParams calldata params) internal {
        IComet comet = IComet(params.comet);
        
        // Validate assets
        _validateAsset(comet, params.fromAsset);
        _validateAsset(comet, params.toAsset);

        // Check if direct mode is safe
        (bool canWithdraw, ) = this.previewDirectWithdrawHeadroom(
            params.comet,
            params.account,
            params.fromAsset,
            params.fromAmount
        );
        if (!canWithdraw) {
            revert HealthFactorTooLow();
        }

        // Execute direct swap
        _executeSwapSequence(params, 0, 0);
    }

    function _executeFlashAssistedSwap(SwapExactInParams calldata params) internal {
        // Encode parameters for flash loan callback
        bytes memory encodedParams = abi.encode(params);
        
        // Calculate required base amount (approximate)
        uint256 requiredBase = _estimateRequiredBase(params);
        
        // Execute flash loan
        IAaveV3Pool(marketConfig.aavePool).flashLoanSimple(
            address(this),
            marketConfig.baseToken,
            requiredBase,
            encodedParams,
            0 // No referral code
        );
    }

    function _executeFlashSwapSequence(uint256 flashAmount, uint256 premium) internal {
        SwapExactInParams memory params = _flashLoanParams;
        IComet comet = IComet(params.comet);
        
        // 1. Supply base to repay debt
        IERC20 baseToken = IERC20(marketConfig.baseToken);
        baseToken.forceApprove(params.comet, flashAmount);
        comet.supply(marketConfig.baseToken, flashAmount);
        
        // 2. Withdraw fromAsset collateral
        comet.withdrawFrom(params.account, address(this), params.fromAsset, params.fromAmount);
        
        // 3. Swap fromAsset to toAsset
        IERC20 fromAsset = IERC20(params.fromAsset);
        fromAsset.forceApprove(marketConfig.swapper, params.fromAmount);
        uint256 toAmount = ISwapper(marketConfig.swapper).swapExactInput(
            params.fromAsset,
            params.toAsset,
            params.fromAmount,
            params.minToAsset,
            params.swapData
        );
        
        // 4. Supply toAsset collateral
        IERC20 toAsset = IERC20(params.toAsset);
        toAsset.forceApprove(params.comet, toAmount);
        comet.supplyTo(params.account, params.toAsset, toAmount);
        
        // 5. Re-borrow base to restore debt
        uint256 totalRepay = flashAmount + premium;
        comet.withdraw(marketConfig.baseToken, totalRepay);
        
        // 6. Repay flash loan
        baseToken.forceApprove(marketConfig.aavePool, totalRepay);
        baseToken.safeTransfer(marketConfig.aavePool, totalRepay);
        
        // 7. Emit event
        emit CollateralSwapped(
            params.account,
            params.comet,
            params.fromAsset,
            params.toAsset,
            params.fromAmount,
            toAmount,
            true
        );
    }

    function _executeSwapSequence(SwapExactInParams calldata params, uint256, uint256) internal {
        IComet comet = IComet(params.comet);
        
        // 1. Withdraw fromAsset collateral
        comet.withdrawFrom(params.account, address(this), params.fromAsset, params.fromAmount);
        
        // 2. Swap fromAsset to toAsset
        IERC20 fromAsset = IERC20(params.fromAsset);
        fromAsset.forceApprove(marketConfig.swapper, params.fromAmount);
        uint256 toAmount = ISwapper(marketConfig.swapper).swapExactInput(
            params.fromAsset,
            params.toAsset,
            params.fromAmount,
            params.minToAsset,
            params.swapData
        );
        
        // 3. Supply toAsset collateral
        IERC20 toAsset = IERC20(params.toAsset);
        toAsset.forceApprove(params.comet, toAmount);
        comet.supplyTo(params.account, params.toAsset, toAmount);
        
        // 4. Emit event
        emit CollateralSwapped(
            params.account,
            params.comet,
            params.fromAsset,
            params.toAsset,
            params.fromAmount,
            toAmount,
            false
        );
    }

    function _validateAsset(IComet comet, address asset) internal view {
        IComet.AssetInfo memory assetInfo = comet.getAssetInfoByAddress(asset);
        if (assetInfo.asset == address(0)) {
            revert UnsupportedAsset(asset);
        }
    }

    function _estimateRequiredBase(SwapExactInParams calldata params) internal view returns (uint256) {
        // Simple estimation - in practice, you'd calculate this more precisely
        IComet comet = IComet(params.comet);
        uint256 currentBorrow = comet.borrowBalanceOf(params.account);
        return currentBorrow / 2; // Use half of current borrow as estimation
    }
}
