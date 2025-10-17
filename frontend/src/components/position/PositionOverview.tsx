'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { formatUSD, formatHealthFactor, formatTokenAmount } from '@/lib/utils/formatters';
import { getHealthFactorColor, getHealthFactorBgColor } from '@/lib/utils/calculations';
import { PositionData } from '@/lib/contracts/types';
import { Address } from 'viem';

interface PositionOverviewProps {
  positionData?: PositionData;
  isLoading?: boolean;
  onViewDetails?: () => void;
}

export function PositionOverview({ 
  positionData, 
  isLoading = false, 
  onViewDetails 
}: PositionOverviewProps) {
  if (isLoading) {
    return (
      <Card className="w-full">
        <CardHeader>
          <CardTitle>Your Position</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Skeleton className="h-4 w-24" />
            <Skeleton className="h-8 w-32" />
          </div>
          <div className="space-y-2">
            <Skeleton className="h-4 w-20" />
            <Skeleton className="h-4 w-28" />
          </div>
          <Skeleton className="h-10 w-full" />
        </CardContent>
      </Card>
    );
  }

  if (!positionData) {
    return (
      <Card className="w-full">
        <CardHeader>
          <CardTitle>Your Position</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-center text-muted-foreground py-8">
            Connect your wallet to view your position
          </div>
        </CardContent>
      </Card>
    );
  }

  const healthFactor = positionData.healthFactor;
  const healthFactorColor = getHealthFactorColor(healthFactor);
  const healthFactorBgColor = getHealthFactorBgColor(healthFactor);

  const getHealthFactorStatus = () => {
    if (healthFactor >= 1.5) return 'Safe';
    if (healthFactor >= 1.2) return 'Caution';
    return 'At Risk';
  };

  const collateralEntries = Object.entries(positionData.collateralBalances).filter(
    ([, balance]) => balance > 0n
  );

  return (
    <Card className="w-full">
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          Your Position
          {onViewDetails && (
            <Button variant="ghost" size="sm" onClick={onViewDetails}>
              View Details
            </Button>
          )}
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {/* Health Factor */}
        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <span className="text-sm font-medium">Health Factor</span>
            <Badge 
              variant="secondary" 
              className={`${healthFactorBgColor} ${healthFactorColor}`}
            >
              {getHealthFactorStatus()}
            </Badge>
          </div>
          <div className={`text-2xl font-bold ${healthFactorColor}`}>
            {formatHealthFactor(healthFactor)}
          </div>
          {healthFactor < 1.2 && (
            <div className="text-xs text-red-600">
              ⚠️ Position at risk of liquidation
            </div>
          )}
        </div>

        {/* Borrowed Amount */}
        <div className="space-y-1">
          <div className="text-sm text-muted-foreground">Borrowed</div>
          <div className="text-lg font-semibold">
            {formatUSD(Number(positionData.borrowBalance) / 1e6)}
          </div>
        </div>

        {/* Collateral Assets */}
        <div className="space-y-2">
          <div className="text-sm font-medium">Collateral</div>
          {collateralEntries.length > 0 ? (
            <div className="space-y-2">
              {collateralEntries.slice(0, 3).map(([asset, balance]) => (
                <div key={asset} className="flex justify-between items-center text-sm">
                  <span className="text-muted-foreground">
                    {formatAddress(asset)}
                  </span>
                  <span className="font-medium">
                    {formatTokenAmount(balance, 18, 4)}
                  </span>
                </div>
              ))}
              {collateralEntries.length > 3 && (
                <div className="text-xs text-muted-foreground">
                  +{collateralEntries.length - 3} more assets
                </div>
              )}
            </div>
          ) : (
            <div className="text-sm text-muted-foreground">
              No collateral supplied
            </div>
          )}
        </div>

        {/* Total Value */}
        <div className="pt-2 border-t">
          <div className="flex justify-between items-center">
            <span className="text-sm text-muted-foreground">Total Value</span>
            <span className="font-semibold">
              {formatUSD(Number(positionData.totalCollateralValue) / 1e6)}
            </span>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

function formatAddress(address: string): string {
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
}
