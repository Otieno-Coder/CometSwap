'use client';

import { useState } from 'react';
import { Address } from 'viem';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { ArrowUpDown, Settings } from 'lucide-react';
import { AssetSelector } from './AssetSelector';
import { AmountInput } from './AmountInput';
import { ModeToggle } from './ModeToggle';
import { SwapFormData } from '@/lib/contracts/types';
import { validateSwapInputs } from '@/lib/utils/validation';

interface Asset {
  address: Address;
  symbol: string;
  name: string;
  decimals: number;
  balance?: bigint;
  price?: number;
  logo?: string;
}

interface SwapCardProps {
  assets: Asset[];
  onSwap: (formData: SwapFormData) => void;
  isLoading?: boolean;
  healthFactor?: number;
}

export function SwapCard({ assets, onSwap, isLoading = false, healthFactor }: SwapCardProps) {
  const [formData, setFormData] = useState<SwapFormData>({
    fromAsset: null,
    toAsset: null,
    amount: '',
    minToAsset: '',
    useFlashLoan: false,
    slippage: 0.5,
  });

  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleFromAssetChange = (asset: Address) => {
    setFormData(prev => ({ ...prev, fromAsset: asset }));
    setErrors(prev => ({ ...prev, fromAsset: '' }));
  };

  const handleToAssetChange = (asset: Address) => {
    setFormData(prev => ({ ...prev, toAsset: asset }));
    setErrors(prev => ({ ...prev, toAsset: '' }));
  };

  const handleAmountChange = (amount: string) => {
    setFormData(prev => ({ ...prev, amount }));
    setErrors(prev => ({ ...prev, amount: '' }));
  };

  const handleMinAmountChange = (minAmount: string) => {
    setFormData(prev => ({ ...prev, minToAsset: minAmount }));
    setErrors(prev => ({ ...prev, minToAsset: '' }));
  };

  const handleModeChange = (useFlashLoan: boolean) => {
    setFormData(prev => ({ ...prev, useFlashLoan }));
  };

  const handleSwap = () => {
    const validation = validateSwapInputs(
      formData.fromAsset,
      formData.toAsset,
      formData.amount,
      formData.minToAsset
    );

    if (!validation.isValid) {
      setErrors({ swap: validation.error || 'Invalid input' });
      return;
    }

    onSwap(formData);
  };

  const swapAssets = () => {
    setFormData(prev => ({
      ...prev,
      fromAsset: prev.toAsset,
      toAsset: prev.fromAsset,
    }));
  };

  const selectedFromAsset = assets.find(asset => asset.address === formData.fromAsset);
  const selectedToAsset = assets.find(asset => asset.address === formData.toAsset);

  return (
    <Card className="w-full max-w-md mx-auto">
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          Swap Collateral
          <Button variant="ghost" size="sm">
            <Settings className="h-4 w-4" />
          </Button>
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {/* From Asset */}
        <div className="space-y-2">
          <label className="text-sm font-medium">From</label>
          <AssetSelector
            selectedAsset={formData.fromAsset}
            onAssetSelect={handleFromAssetChange}
            assets={assets}
            placeholder="Select source asset"
          />
          {selectedFromAsset && (
            <AmountInput
              value={formData.amount}
              onChange={handleAmountChange}
              balance={selectedFromAsset.balance}
              decimals={selectedFromAsset.decimals}
              price={selectedFromAsset.price}
              symbol={selectedFromAsset.symbol}
              placeholder="0.0"
              error={errors.amount}
            />
          )}
        </div>

        {/* Swap Button */}
        <div className="flex justify-center">
          <Button
            variant="outline"
            size="sm"
            onClick={swapAssets}
            disabled={!formData.fromAsset || !formData.toAsset}
            className="rounded-full"
          >
            <ArrowUpDown className="h-4 w-4" />
          </Button>
        </div>

        {/* To Asset */}
        <div className="space-y-2">
          <label className="text-sm font-medium">To</label>
          <AssetSelector
            selectedAsset={formData.toAsset}
            onAssetSelect={handleToAssetChange}
            assets={assets.filter(asset => asset.address !== formData.fromAsset)}
            placeholder="Select destination asset"
          />
          {selectedToAsset && (
            <AmountInput
              value={formData.minToAsset}
              onChange={handleMinAmountChange}
              balance={selectedToAsset.balance}
              decimals={selectedToAsset.decimals}
              price={selectedToAsset.price}
              symbol={selectedToAsset.symbol}
              placeholder="0.0"
              error={errors.minToAsset}
            />
          )}
        </div>

        {/* Mode Toggle */}
        <ModeToggle
          useFlashLoan={formData.useFlashLoan}
          onModeChange={handleModeChange}
          healthFactor={healthFactor}
        />

        {/* Error Message */}
        {errors.swap && (
          <div className="text-sm text-red-500 text-center">
            {errors.swap}
          </div>
        )}

        {/* Swap Button */}
        <Button
          onClick={handleSwap}
          disabled={isLoading || !formData.fromAsset || !formData.toAsset || !formData.amount}
          className="w-full"
        >
          {isLoading ? 'Processing...' : 'Review Swap'}
        </Button>
      </CardContent>
    </Card>
  );
}
