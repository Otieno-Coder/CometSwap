// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ISwapper} from "./interfaces/ISwapper.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Struct for Uniswap V3 exactInputSingle parameters
struct ExactInputSingleParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
    uint160 sqrtPriceLimitX96;
}

// Interface for Uniswap V3 SwapRouter02
interface ISwapRouter {
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
}

/**
 * @title UniswapV3Swapper
 * @notice Adapter for Uniswap V3 SwapRouter02 exactInputSingle
 * @dev Implements ISwapper interface for Uniswap V3 integration
 */
contract UniswapV3Swapper is ISwapper {
    using SafeERC20 for IERC20;

    // Uniswap V3 SwapRouter02 address
    address public immutable SWAP_ROUTER;



    error InvalidSwapData();
    error SwapFailed();

    constructor(address _swapRouter) {
        SWAP_ROUTER = _swapRouter;
    }

    /**
     * @notice Swaps exact input tokens for output tokens using Uniswap V3
     * @param tokenIn The address of the input token
     * @param tokenOut The address of the output token
     * @param amountIn The amount of input tokens to swap
     * @param minAmountOut The minimum amount of output tokens expected
     * @param data Encoded swap data containing pool fee (uint24)
     * @return amountOut The actual amount of output tokens received
     */
    function swapExactInput(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        bytes calldata data
    ) external override returns (uint256 amountOut) {
        // Decode swap data to get pool fee
        if (data.length != 32) {
            revert InvalidSwapData();
        }
        
        uint24 fee = abi.decode(data, (uint24));

        // Transfer tokens from caller to this contract
        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);

        // Approve SwapRouter to spend tokens
        IERC20(tokenIn).forceApprove(SWAP_ROUTER, amountIn);

        // Prepare Uniswap V3 exactInputSingle parameters
        ExactInputSingleParams memory params = ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: fee,
            recipient: msg.sender, // Send output tokens back to caller
            deadline: block.timestamp + 300, // 5 minute deadline
            amountIn: amountIn,
            amountOutMinimum: minAmountOut,
            sqrtPriceLimitX96: 0 // No price limit
        });

        // Execute swap
        try ISwapRouter(SWAP_ROUTER).exactInputSingle(params) returns (uint256 _amountOut) {
            amountOut = _amountOut;
        } catch {
            revert SwapFailed();
        }

        // Reset approval to save gas
        IERC20(tokenIn).forceApprove(SWAP_ROUTER, 0);
    }
}
// Updated: Enhanced Uniswap V3 integration
