import { formatUnits, parseUnits } from 'viem';

export function formatTokenAmount(amount: bigint, decimals: number, precision: number = 6): string {
  return parseFloat(formatUnits(amount, decimals)).toFixed(precision);
}

export function formatUSD(amount: number, precision: number = 2): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: precision,
    maximumFractionDigits: precision,
  }).format(amount);
}

export function formatAddress(address: string, length: number = 6): string {
  if (address.length <= length * 2 + 2) return address;
  return `${address.slice(0, length + 2)}...${address.slice(-length)}`;
}

export function formatHealthFactor(healthFactor: number): string {
  if (healthFactor === 0) return 'N/A';
  return healthFactor.toFixed(2);
}

export function parseTokenAmount(amount: string, decimals: number): bigint {
  try {
    return parseUnits(amount, decimals);
  } catch {
    return 0n;
  }
}

export function formatPercentage(value: number, precision: number = 2): string {
  return `${(value * 100).toFixed(precision)}%`;
}
