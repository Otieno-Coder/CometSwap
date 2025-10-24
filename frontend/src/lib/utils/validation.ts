import { Address } from 'viem';

export function isValidAddress(address: string): boolean {
  return /^0x[a-fA-F0-9]{40}$/.test(address);
}

export function isValidAmount(amount: string): boolean {
  if (!amount || amount === '') return false;
  const num = parseFloat(amount);
  return !isNaN(num) && num > 0 && isFinite(num);
}

export function validateSwapInputs(
  fromAsset: Address | null,
  toAsset: Address | null,
  amount: string,
  minToAsset: string
): { isValid: boolean; error?: string } {
  if (!fromAsset) {
    return { isValid: false, error: 'Please select a source asset' };
  }
  
  if (!toAsset) {
    return { isValid: false, error: 'Please select a destination asset' };
  }
  
  if (fromAsset === toAsset) {
    return { isValid: false, error: 'Source and destination assets must be different' };
  }
  
  if (!isValidAmount(amount)) {
    return { isValid: false, error: 'Please enter a valid amount' };
  }
  
  if (!isValidAmount(minToAsset)) {
    return { isValid: false, error: 'Please enter a valid minimum amount' };
  }
  
  const amountNum = parseFloat(amount);
  const minAmountNum = parseFloat(minToAsset);
  
  // For now, just check that minimum amount is positive and reasonable
  // The actual validation against expected output should happen after price calculation
  if (minAmountNum <= 0) {
    return { isValid: false, error: 'Minimum amount must be greater than 0' };
  }
  
  return { isValid: true };
}

export function validateSlippage(slippage: number): { isValid: boolean; error?: string } {
  if (slippage < 0.01) {
    return { isValid: false, error: 'Slippage must be at least 0.01%' };
  }
  
  if (slippage > 50) {
    return { isValid: false, error: 'Slippage cannot exceed 50%' };
  }
  
  return { isValid: true };
}
// Updated: Frontend validation improvements
