import { useReadContract, useReadContracts } from 'wagmi';
import { Address } from 'viem';
import { ICOMET_ABI } from '@/lib/contracts/abis';
import { getContractAddress } from '@/lib/contracts/addresses';
import { AssetInfo, PositionData } from '@/lib/contracts/types';
import { calculateHealthFactor } from '@/lib/utils/calculations';

export function usePosition(userAddress: Address | undefined) {
  const cometAddress = getContractAddress('COMET') as Address;
  
  // Read borrow balance
  const { data: borrowBalance } = useReadContract({
    address: cometAddress,
    abi: ICOMET_ABI,
    functionName: 'borrowBalanceOf',
    args: userAddress ? [userAddress] : undefined,
    query: { enabled: !!userAddress },
  });

  // Read number of assets
  const { data: numAssets } = useReadContract({
    address: cometAddress,
    abi: ICOMET_ABI,
    functionName: 'numAssets',
    query: { enabled: !!userAddress },
  });

  // Read all asset info
  const assetInfoContracts = Array.from({ length: numAssets || 0 }, (_, i) => ({
    address: cometAddress,
    abi: ICOMET_ABI,
    functionName: 'getAssetInfo' as const,
    args: [i] as const,
  }));

  const { data: assetInfos } = useReadContracts({
    contracts: assetInfoContracts,
    query: { enabled: !!userAddress && !!numAssets },
  });

  // Read collateral balances for each asset
  const collateralContracts = assetInfos?.map((assetInfo) => ({
    address: cometAddress,
    abi: ICOMET_ABI,
    functionName: 'collateralBalanceOf' as const,
    args: userAddress ? [userAddress, assetInfo.result?.asset] : undefined,
  })) || [];

  const { data: collateralBalances } = useReadContracts({
    contracts: collateralContracts,
    query: { enabled: !!userAddress && !!assetInfos },
  });

  // Read health factor
  const { data: isBorrowCollateralized } = useReadContract({
    address: cometAddress,
    abi: ICOMET_ABI,
    functionName: 'isBorrowCollateralized',
    args: userAddress ? [userAddress] : undefined,
    query: { enabled: !!userAddress },
  });

  const { data: isLiquidatable } = useReadContract({
    address: cometAddress,
    abi: ICOMET_ABI,
    functionName: 'isLiquidatable',
    args: userAddress ? [userAddress] : undefined,
    query: { enabled: !!userAddress },
  });

  // Process data
  const positionData: PositionData | undefined = userAddress && assetInfos && collateralBalances ? {
    borrowBalance: borrowBalance || 0n,
    collateralBalances: {},
    healthFactor: 0,
    liquidationPrice: 0,
    borrowCapacity: 0n,
    totalCollateralValue: 0n,
  } : undefined;

  return {
    positionData,
    isLoading: !userAddress || !assetInfos || !collateralBalances,
    error: null,
  };
}
