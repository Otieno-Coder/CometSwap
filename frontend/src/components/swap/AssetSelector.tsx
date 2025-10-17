'use client';

import { useState } from 'react';
import { Address } from 'viem';
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Badge } from '@/components/ui/badge';
import { ChevronDown, Search } from 'lucide-react';
import { Input } from '@/components/ui/input';

interface Asset {
  address: Address;
  symbol: string;
  name: string;
  decimals: number;
  balance?: bigint;
  price?: number;
  logo?: string;
}

interface AssetSelectorProps {
  selectedAsset: Address | null;
  onAssetSelect: (asset: Address) => void;
  assets: Asset[];
  placeholder?: string;
  disabled?: boolean;
}

export function AssetSelector({
  selectedAsset,
  onAssetSelect,
  assets,
  placeholder = 'Select asset',
  disabled = false,
}: AssetSelectorProps) {
  const [searchTerm, setSearchTerm] = useState('');
  const [isOpen, setIsOpen] = useState(false);

  const selectedAssetData = assets.find(asset => asset.address === selectedAsset);
  
  const filteredAssets = assets.filter(asset =>
    asset.symbol.toLowerCase().includes(searchTerm.toLowerCase()) ||
    asset.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const formatBalance = (balance: bigint, decimals: number) => {
    if (balance === 0n) return '0';
    const formatted = Number(balance) / Math.pow(10, decimals);
    return formatted < 0.000001 ? '<0.000001' : formatted.toFixed(6);
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 2,
      maximumFractionDigits: 6,
    }).format(price);
  };

  return (
    <DropdownMenu open={isOpen} onOpenChange={setIsOpen}>
      <DropdownMenuTrigger asChild>
        <Button
          variant="outline"
          className="w-full justify-between h-12"
          disabled={disabled}
        >
          <div className="flex items-center gap-2">
            {selectedAssetData ? (
              <>
                <div className="w-6 h-6 rounded-full bg-gray-200 flex items-center justify-center">
                  {selectedAssetData.logo ? (
                    <img
                      src={selectedAssetData.logo}
                      alt={selectedAssetData.symbol}
                      className="w-6 h-6 rounded-full"
                    />
                  ) : (
                    <span className="text-xs font-medium">
                      {selectedAssetData.symbol.slice(0, 2)}
                    </span>
                  )}
                </div>
                <div className="text-left">
                  <div className="font-medium">{selectedAssetData.symbol}</div>
                  <div className="text-xs text-muted-foreground">
                    {selectedAssetData.name}
                  </div>
                </div>
              </>
            ) : (
              <span className="text-muted-foreground">{placeholder}</span>
            )}
          </div>
          <ChevronDown className="h-4 w-4" />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent className="w-80 p-0" align="start">
        <div className="p-3 border-b">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="Search assets..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10"
            />
          </div>
        </div>
        <div className="max-h-60 overflow-y-auto">
          {filteredAssets.map((asset) => (
            <DropdownMenuItem
              key={asset.address}
              onClick={() => {
                onAssetSelect(asset.address);
                setIsOpen(false);
                setSearchTerm('');
              }}
              className="flex items-center justify-between p-3 cursor-pointer"
            >
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-gray-200 flex items-center justify-center">
                  {asset.logo ? (
                    <img
                      src={asset.logo}
                      alt={asset.symbol}
                      className="w-8 h-8 rounded-full"
                    />
                  ) : (
                    <span className="text-sm font-medium">
                      {asset.symbol.slice(0, 2)}
                    </span>
                  )}
                </div>
                <div className="text-left">
                  <div className="font-medium">{asset.symbol}</div>
                  <div className="text-xs text-muted-foreground">
                    {asset.name}
                  </div>
                </div>
              </div>
              <div className="text-right">
                {asset.balance !== undefined && (
                  <div className="text-sm">
                    {formatBalance(asset.balance, asset.decimals)}
                  </div>
                )}
                {asset.price && (
                  <div className="text-xs text-muted-foreground">
                    {formatPrice(asset.price)}
                  </div>
                )}
                {asset.balance && asset.balance > 0n && (
                  <Badge variant="secondary" className="text-xs">
                    Available
                  </Badge>
                )}
              </div>
            </DropdownMenuItem>
          ))}
          {filteredAssets.length === 0 && (
            <div className="p-3 text-center text-muted-foreground">
              No assets found
            </div>
          )}
        </div>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
