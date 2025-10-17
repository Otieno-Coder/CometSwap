import { Address } from 'viem';

export interface AssetInfo {
  offset: number;
  asset: Address;
  priceFeed: Address;
  scale: bigint;
  borrowCollateralFactor: bigint;
  liquidateCollateralFactor: bigint;
  liquidationFactor: bigint;
  supplyCap: bigint;
}

export interface SwapExactInParams {
  comet: Address;
  account: Address;
  fromAsset: Address;
  toAsset: Address;
  fromAmount: bigint;
  minToAsset: bigint;
  swapData: `0x${string}`;
  useFlashLoan: boolean;
  receiver: Address;
}

export interface MarketConfig {
  comet: Address;
  baseToken: Address;
  aavePool: Address;
  swapper: Address;
}

export interface PositionData {
  borrowBalance: bigint;
  collateralBalances: Record<Address, bigint>;
  healthFactor: number;
  liquidationPrice: number;
  borrowCapacity: bigint;
  totalCollateralValue: bigint;
}

export interface SwapFormData {
  fromAsset: Address | null;
  toAsset: Address | null;
  amount: string;
  minToAsset: string;
  useFlashLoan: boolean;
  slippage: number;
}

export interface TransactionStatus {
  status: 'idle' | 'pending' | 'success' | 'error';
  hash?: `0x${string}`;
  error?: string;
  step?: number;
  totalSteps?: number;
}
