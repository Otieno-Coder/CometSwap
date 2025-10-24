import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { mainnet } from 'viem/chains';
import { http } from 'viem';

// Create a custom mainnet chain configuration for local Anvil fork
const anvilMainnet = {
  ...mainnet,
  id: 1,
  name: 'Anvil Mainnet Fork',
  rpcUrls: {
    default: {
      http: ['http://localhost:8545'],
    },
    public: {
      http: ['http://localhost:8545'],
    },
  },
  blockExplorers: {
    default: { name: 'Etherscan', url: 'https://etherscan.io' },
  },
};

export const config = getDefaultConfig({
  appName: 'Comet Collateral Swap',
  projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID || 'demo-project-id',
  chains: [anvilMainnet],
  ssr: true,
  transports: {
    [anvilMainnet.id]: http('http://localhost:8545'),
  },
});
// Updated: Final integration testing
