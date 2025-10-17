export const CONTRACT_ADDRESSES = {
  mainnet: {
    COMET: '0xc3d688B66703497DAA19211EEdff47f25384cdc3',
    AAVE_POOL: '0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2',
    UNISWAP_SWAP_ROUTER: '0xE592427A0AEce92De3Edee1F18E0157C05861564',
    USDC: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
    WETH: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
    WBTC: '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599',
    // These will be set after deployment
    ROUTER: process.env.NEXT_PUBLIC_ROUTER_ADDRESS || '',
    SWAPPER: process.env.NEXT_PUBLIC_SWAPPER_ADDRESS || '',
  },
  localhost: {
    COMET: '0xc3d688B66703497DAA19211EEdff47f25384cdc3', // Same as mainnet for fork
    AAVE_POOL: '0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2', // Same as mainnet for fork
    UNISWAP_SWAP_ROUTER: '0xE592427A0AEce92De3Edee1F18E0157C05861564', // Same as mainnet for fork
    USDC: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48', // Same as mainnet for fork
    WETH: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', // Same as mainnet for fork
    WBTC: '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599', // Same as mainnet for fork
    // These will be set after deployment to Anvil
    ROUTER: process.env.NEXT_PUBLIC_ROUTER_ADDRESS || '',
    SWAPPER: process.env.NEXT_PUBLIC_SWAPPER_ADDRESS || '',
  },
} as const;

export const getContractAddress = (contract: keyof typeof CONTRACT_ADDRESSES.mainnet, chainId: number = 1) => {
  // For Anvil fork, we always use mainnet addresses since it's a mainnet fork
  // The localhost addresses are only for pure local Anvil without fork
  const chainKey = 'mainnet';
  
  if (chainId !== 1) {
    throw new Error(`Unsupported chain ID: ${chainId}. Only mainnet (1) is supported.`);
  }
  
  return CONTRACT_ADDRESSES[chainKey][contract];
};
