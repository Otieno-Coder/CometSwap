// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ISwapper
 * @notice Interface for token swapping functionality
 * @dev Pluggable interface to support different DEX implementations
 */
interface ISwapper {
    /**
     * @notice Swaps exact input tokens for output tokens
     * @dev Must pull tokenIn from caller; router approves beforehand
     * @param tokenIn The address of the input token
     * @param tokenOut The address of the output token
     * @param amountIn The amount of input tokens to swap
     * @param minAmountOut The minimum amount of output tokens expected
     * @param data Additional data for the swap (e.g., pool fee, path)
     * @return amountOut The actual amount of output tokens received
     */
    function swapExactInput(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        bytes calldata data
    ) external returns (uint256 amountOut);
}
