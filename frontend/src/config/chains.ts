import { mainnet } from 'viem/chains';

export const supportedChains = [mainnet] as const;

export type SupportedChain = typeof supportedChains[number];
