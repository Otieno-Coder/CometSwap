import { useReadContract, useReadContracts } from 'wagmi';
import { Address } from 'viem';
import { ICOMET_ABI } from '@/lib/contracts/abis';
import { getContractAddress } from '@/lib/contracts/addresses';

export function usePrice(priceFeed: Address) {
  const cometAddress = getContractAddress('COMET') as Address;
  
  const { data: price, isLoading, error } = useReadContract({
    address: cometAddress,
    abi: ICOMET_ABI,
    functionName: 'getPrice',
    args: [priceFeed],
  });

  return {
    price: price ? Number(price) / 1e8 : 0, // Convert from 8 decimals to USD
    isLoading,
    error,
  };
}

export function usePrices(priceFeeds: Address[]) {
  const cometAddress = getContractAddress('COMET') as Address;
  
  const contracts = priceFeeds.map(priceFeed => ({
    address: cometAddress,
    abi: ICOMET_ABI,
    functionName: 'getPrice' as const,
    args: [priceFeed] as const,
  }));

  const { data: prices, isLoading, error } = useReadContracts({
    contracts,
  });

  const priceMap: Record<Address, number> = {};
  priceFeeds.forEach((priceFeed, index) => {
    const priceData = prices?.[index];
    if (priceData?.result) {
      priceMap[priceFeed] = Number(priceData.result) / 1e8;
    }
  });

  return {
    prices: priceMap,
    isLoading,
    error,
  };
}
