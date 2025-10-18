// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IComet
 * @notice Interface for Compound v3 (Comet) protocol
 * @dev Based on the official Comet ABI
 */
interface IComet {
    // ============ Structs ============
    
    struct AssetInfo {
        uint8 offset;
        address asset;
        address priceFeed;
        uint64 scale;
        uint64 borrowCollateralFactor;
        uint64 liquidateCollateralFactor;
        uint64 liquidationFactor;
        uint128 supplyCap;
    }

    // ============ Core Functions ============
    
    function supply(address asset, uint256 amount) external;
    function withdraw(address asset, uint256 amount) external;
    function withdrawTo(address to, address asset, uint256 amount) external;
    function withdrawFrom(address src, address to, address asset, uint256 amount) external;
    function supplyFrom(address from, address dst, address asset, uint256 amount) external;
    function supplyTo(address dst, address asset, uint256 amount) external;

    // ============ Account Data ============
    
    function borrowBalanceOf(address account) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function collateralBalanceOf(address account, address asset) external view returns (uint128);
    function userNonce(address account) external view returns (uint256);

    // ============ Manager/Allowance ============
    
    function allow(address manager, bool isAllowed) external;
    function allowBySig(
        address owner,
        address manager,
        bool isAllowed,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
    function hasPermission(address owner, address manager) external view returns (bool);
    function isAllowed(address owner, address manager) external view returns (bool);

    // ============ Asset Information ============
    
    function numAssets() external view returns (uint8);
    function getAssetInfo(uint8 i) external view returns (AssetInfo memory);
    function getAssetInfoByAddress(address asset) external view returns (AssetInfo memory);
    function factorScale() external pure returns (uint64);

    // ============ Health & Liquidation ============
    
    function isBorrowCollateralized(address account) external view returns (bool);
    function isLiquidatable(address account) external view returns (bool);

    // ============ Base Token ============
    
    function baseToken() external view returns (address);
    function baseScale() external view returns (uint256);
    function baseBorrowMin() external view returns (uint256);

    // ============ Price Feeds ============
    
    function getPrice(address priceFeed) external view returns (uint256);
    function baseTokenPriceFeed() external view returns (address);

    // ============ Pause States ============
    
    function isSupplyPaused() external view returns (bool);
    function isTransferPaused() external view returns (bool);
    function isWithdrawPaused() external view returns (bool);
    function isAbsorbPaused() external view returns (bool);
    function isBuyPaused() external view returns (bool);

    // ============ ERC20 Functions ============
    
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address dst, uint256 amount) external returns (bool);
    function transferFrom(address src, address dst, uint256 amount) external returns (bool);
}
// Updated: Added comprehensive error handling
