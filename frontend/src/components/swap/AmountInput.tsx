'use client';

import { useState, useEffect } from 'react';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { formatTokenAmount, formatUSD } from '@/lib/utils/formatters';

interface AmountInputProps {
  value: string;
  onChange: (value: string) => void;
  balance?: bigint;
  decimals?: number;
  price?: number;
  symbol?: string;
  disabled?: boolean;
  placeholder?: string;
  error?: string;
}

export function AmountInput({
  value,
  onChange,
  balance,
  decimals = 18,
  price,
  symbol = '',
  disabled = false,
  placeholder = '0.0',
  error,
}: AmountInputProps) {
  const [usdValue, setUsdValue] = useState<number>(0);

  // Calculate USD value when amount or price changes
  useEffect(() => {
    if (value && price) {
      const amount = parseFloat(value);
      if (!isNaN(amount)) {
        setUsdValue(amount * price);
      } else {
        setUsdValue(0);
      }
    } else {
      setUsdValue(0);
    }
  }, [value, price]);

  const handleMaxClick = () => {
    if (balance && decimals) {
      const maxAmount = formatTokenAmount(balance, decimals, 6);
      onChange(maxAmount);
    }
  };

  const handlePercentageClick = (percentage: number) => {
    if (balance && decimals) {
      const amount = (Number(formatTokenAmount(balance, decimals)) * percentage).toString();
      onChange(amount);
    }
  };

  const formatBalance = (balance: bigint, decimals: number) => {
    if (balance === 0n) return '0';
    return formatTokenAmount(balance, decimals, 6);
  };

  return (
    <div className="space-y-2">
      <div className="relative">
        <Input
          type="number"
          value={value}
          onChange={(e) => onChange(e.target.value)}
          placeholder={placeholder}
          disabled={disabled}
          className={`pr-20 ${error ? 'border-red-500' : ''}`}
        />
        <div className="absolute right-2 top-1/2 transform -translate-y-1/2 flex items-center gap-1">
          {symbol && (
            <Badge variant="secondary" className="text-xs">
              {symbol}
            </Badge>
          )}
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={handleMaxClick}
            disabled={!balance || balance === 0n || disabled}
            className="h-6 px-2 text-xs"
          >
            MAX
          </Button>
        </div>
      </div>

      {/* Balance and USD value */}
      <div className="flex justify-between items-center text-sm">
        <div className="flex items-center gap-2">
          {balance !== undefined && (
            <span className="text-muted-foreground">
              Balance: {formatBalance(balance, decimals)}
            </span>
          )}
        </div>
        {price && usdValue > 0 && (
          <span className="text-muted-foreground">
            {formatUSD(usdValue)}
          </span>
        )}
      </div>

      {/* Percentage buttons */}
      {balance && balance > 0n && (
        <div className="flex gap-1">
          {[0.25, 0.5, 0.75, 1].map((percentage) => (
            <Button
              key={percentage}
              type="button"
              variant="outline"
              size="sm"
              onClick={() => handlePercentageClick(percentage)}
              disabled={disabled}
              className="flex-1 h-7 text-xs"
            >
              {percentage * 100}%
            </Button>
          ))}
        </div>
      )}

      {/* Error message */}
      {error && (
        <div className="text-sm text-red-500">{error}</div>
      )}
    </div>
  );
}
