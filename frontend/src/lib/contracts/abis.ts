// CollateralSwapRouter ABI (essential functions)
export const COLLATERAL_SWAP_ROUTER_ABI = [
  {
    inputs: [
      {
        components: [
          { internalType: 'address', name: 'comet', type: 'address' },
          { internalType: 'address', name: 'account', type: 'address' },
          { internalType: 'address', name: 'fromAsset', type: 'address' },
          { internalType: 'address', name: 'toAsset', type: 'address' },
          { internalType: 'uint256', name: 'fromAmount', type: 'uint256' },
          { internalType: 'uint256', name: 'minToAsset', type: 'uint256' },
          { internalType: 'bytes', name: 'swapData', type: 'bytes' },
          { internalType: 'bool', name: 'useFlashLoan', type: 'bool' },
          { internalType: 'address', name: 'receiver', type: 'address' },
        ],
        internalType: 'struct CollateralSwapRouter.SwapExactInParams',
        name: 'params',
        type: 'tuple',
      },
    ],
    name: 'swapCollateralExactIn',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      { internalType: 'address', name: 'comet', type: 'address' },
      { internalType: 'address', name: 'account', type: 'address' },
      { internalType: 'address', name: 'asset', type: 'address' },
      { internalType: 'uint256', name: 'withdrawAmount', type: 'uint256' },
    ],
    name: 'previewDirectWithdrawHeadroom',
    outputs: [
      { internalType: 'bool', name: 'canWithdrawSafely', type: 'bool' },
      { internalType: 'uint256', name: 'newBorrowCapacity', type: 'uint256' },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'marketConfig',
    outputs: [
      { internalType: 'address', name: 'comet', type: 'address' },
      { internalType: 'address', name: 'baseToken', type: 'address' },
      { internalType: 'address', name: 'aavePool', type: 'address' },
      { internalType: 'address', name: 'swapper', type: 'address' },
    ],
    stateMutability: 'view',
    type: 'function',
  },
] as const;

// IComet ABI (essential functions)
export const ICOMET_ABI = [
  {
    inputs: [
      { internalType: 'address', name: 'asset', type: 'address' },
      { internalType: 'uint256', name: 'amount', type: 'uint256' },
    ],
    name: 'supply',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      { internalType: 'address', name: 'asset', type: 'address' },
      { internalType: 'uint256', name: 'amount', type: 'uint256' },
    ],
    name: 'withdraw',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      { internalType: 'address', name: 'src', type: 'address' },
      { internalType: 'address', name: 'to', type: 'address' },
      { internalType: 'address', name: 'asset', type: 'address' },
      { internalType: 'uint256', name: 'amount', type: 'uint256' },
    ],
    name: 'withdrawFrom',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      { internalType: 'address', name: 'dst', type: 'address' },
      { internalType: 'address', name: 'asset', type: 'address' },
      { internalType: 'uint256', name: 'amount', type: 'uint256' },
    ],
    name: 'supplyTo',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [{ internalType: 'address', name: 'account', type: 'address' }],
    name: 'borrowBalanceOf',
    outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ internalType: 'address', name: 'account', type: 'address' }],
    name: 'balanceOf',
    outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      { internalType: 'address', name: 'account', type: 'address' },
      { internalType: 'address', name: 'asset', type: 'address' },
    ],
    name: 'collateralBalanceOf',
    outputs: [{ internalType: 'uint128', name: '', type: 'uint128' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ internalType: 'address', name: 'account', type: 'address' }],
    name: 'isBorrowCollateralized',
    outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ internalType: 'address', name: 'account', type: 'address' }],
    name: 'isLiquidatable',
    outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ internalType: 'address', name: 'asset', type: 'address' }],
    name: 'getAssetInfoByAddress',
    outputs: [
      {
        components: [
          { internalType: 'uint8', name: 'offset', type: 'uint8' },
          { internalType: 'address', name: 'asset', type: 'address' },
          { internalType: 'address', name: 'priceFeed', type: 'address' },
          { internalType: 'uint64', name: 'scale', type: 'uint64' },
          { internalType: 'uint64', name: 'borrowCollateralFactor', type: 'uint64' },
          { internalType: 'uint64', name: 'liquidateCollateralFactor', type: 'uint64' },
          { internalType: 'uint64', name: 'liquidationFactor', type: 'uint64' },
          { internalType: 'uint128', name: 'supplyCap', type: 'uint128' },
        ],
        internalType: 'struct CometCore.AssetInfo',
        name: '',
        type: 'tuple',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'numAssets',
    outputs: [{ internalType: 'uint8', name: '', type: 'uint8' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ internalType: 'uint8', name: 'i', type: 'uint8' }],
    name: 'getAssetInfo',
    outputs: [
      {
        components: [
          { internalType: 'uint8', name: 'offset', type: 'uint8' },
          { internalType: 'address', name: 'asset', type: 'address' },
          { internalType: 'address', name: 'priceFeed', type: 'address' },
          { internalType: 'uint64', name: 'scale', type: 'uint64' },
          { internalType: 'uint64', name: 'borrowCollateralFactor', type: 'uint64' },
          { internalType: 'uint64', name: 'liquidateCollateralFactor', type: 'uint64' },
          { internalType: 'uint64', name: 'liquidationFactor', type: 'uint64' },
          { internalType: 'uint128', name: 'supplyCap', type: 'uint128' },
        ],
        internalType: 'struct CometCore.AssetInfo',
        name: '',
        type: 'tuple',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'factorScale',
    outputs: [{ internalType: 'uint64', name: '', type: 'uint64' }],
    stateMutability: 'pure',
    type: 'function',
  },
  {
    inputs: [{ internalType: 'address', name: 'priceFeed', type: 'address' }],
    name: 'getPrice',
    outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      { internalType: 'address', name: 'manager', type: 'address' },
      { internalType: 'bool', name: 'isAllowed', type: 'bool' },
    ],
    name: 'allow',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      { internalType: 'address', name: 'owner', type: 'address' },
      { internalType: 'address', name: 'manager', type: 'address' },
    ],
    name: 'hasPermission',
    outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
    stateMutability: 'view',
    type: 'function',
  },
] as const;

// ERC20 ABI (essential functions)
export const ERC20_ABI = [
  {
    inputs: [
      { internalType: 'address', name: 'spender', type: 'address' },
      { internalType: 'uint256', name: 'amount', type: 'uint256' },
    ],
    name: 'approve',
    outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      { internalType: 'address', name: 'owner', type: 'address' },
      { internalType: 'address', name: 'spender', type: 'address' },
    ],
    name: 'allowance',
    outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ internalType: 'address', name: 'account', type: 'address' }],
    name: 'balanceOf',
    outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'decimals',
    outputs: [{ internalType: 'uint8', name: '', type: 'uint8' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'symbol',
    outputs: [{ internalType: 'string', name: '', type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
] as const;
