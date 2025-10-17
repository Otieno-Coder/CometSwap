import { formatUnits } from 'viem';
import { AssetInfo } from '@/lib/contracts/types';

export function calculateHealthFactor(
  collateralBalances: Record<string, bigint>,
  assetInfos: Record<string, AssetInfo>,
  prices: Record<string, number>,
  borrowBalance: bigint,
  factorScale: bigint
): number {
  let totalCollateralValue = 0;
  let totalBorrowCapacity = 0;

  // Calculate total collateral value and borrow capacity
  for (const [asset, balance] of Object.entries(collateralBalances)) {
    const assetInfo = assetInfos[asset];
    const price = prices[asset];
    
    if (!assetInfo || !price || balance === 0n) continue;
    
    const collateralValue = Number(formatUnits(balance, Number(assetInfo.scale))) * price;
    const borrowCapacity = (collateralValue * Number(assetInfo.borrowCollateralFactor)) / Number(factorScale);
    
    totalCollateralValue += collateralValue;
    totalBorrowCapacity += borrowCapacity;
  }

  const totalBorrowValue = Number(formatUnits(borrowBalance, 6)); // USDC has 6 decimals

  if (totalBorrowValue === 0) return Infinity;
  if (totalBorrowCapacity === 0) return 0;

  return totalBorrowCapacity / totalBorrowValue;
}

export function calculateLiquidationPrice(
  collateralBalance: bigint,
  assetInfo: AssetInfo,
  borrowBalance: bigint,
  factorScale: bigint
): number {
  if (collateralBalance === 0n) return 0;
  
  const collateralAmount = Number(formatUnits(collateralBalance, Number(assetInfo.scale)));
  const borrowValue = Number(formatUnits(borrowBalance, 6)); // USDC has 6 decimals
  const liquidationFactor = Number(assetInfo.liquidationFactor) / Number(factorScale);
  
  return borrowValue / (collateralAmount * liquidationFactor);
}

export function calculateBorrowCapacity(
  collateralBalance: bigint,
  assetInfo: AssetInfo,
  price: number,
  factorScale: bigint
): number {
  const collateralValue = Number(formatUnits(collateralBalance, Number(assetInfo.scale))) * price;
  const borrowCapacity = (collateralValue * Number(assetInfo.borrowCollateralFactor)) / Number(factorScale);
  
  return borrowCapacity;
}

export function getHealthFactorColor(healthFactor: number): string {
  if (healthFactor >= 1.5) return 'text-green-600';
  if (healthFactor >= 1.2) return 'text-yellow-600';
  return 'text-red-600';
}

export function getHealthFactorBgColor(healthFactor: number): string {
  if (healthFactor >= 1.5) return 'bg-green-100';
  if (healthFactor >= 1.2) return 'bg-yellow-100';
  return 'bg-red-100';
}
