'use client';

import { useAccount } from 'wagmi';
import { SwapCard } from '@/components/swap/SwapCard';
import { PositionOverview } from '@/components/position/PositionOverview';
import { WalletConnect } from '@/components/shared/WalletConnect';
import { usePosition } from '@/lib/hooks/usePosition';
import { useSwap } from '@/lib/hooks/useSwap';
import { SwapFormData } from '@/lib/contracts/types';
import { Address } from 'viem';

// Mock assets data - in a real app, this would come from the Comet contract
const MOCK_ASSETS = [
  {
    address: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2' as Address,
    symbol: 'WETH',
    name: 'Wrapped Ether',
    decimals: 18,
    balance: BigInt('3000000000000000000'), // 3 WETH (wrapped for testing)
    price: 2500,
  },
  {
    address: '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599' as Address,
    symbol: 'WBTC',
    name: 'Wrapped Bitcoin',
    decimals: 8,
    balance: BigInt('0'), // 0 WBTC (no balance)
    price: 45000,
  },
  {
    address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48' as Address,
    symbol: 'USDC',
    name: 'USD Coin',
    decimals: 6,
    balance: BigInt('0'), // 0 USDC (no balance)
    price: 1,
  },
];

export default function SwapPage() {
  const { address, isConnected } = useAccount();
  const { positionData, isLoading: positionLoading } = usePosition(address);
  const { executeSwap, transactionStatus, isPending } = useSwap();

  const handleSwap = async (formData: SwapFormData) => {
    if (!address) return;

    // Get the selected assets to determine correct decimals
    const fromAsset = MOCK_ASSETS.find(asset => asset.address === formData.fromAsset);
    const toAsset = MOCK_ASSETS.find(asset => asset.address === formData.toAsset);
    
    if (!fromAsset || !toAsset) return;

    // Convert amounts with correct decimals
    const fromAmount = BigInt(Math.floor(parseFloat(formData.amount) * Math.pow(10, fromAsset.decimals)));
    const minToAsset = BigInt(Math.floor(parseFloat(formData.minToAsset) * Math.pow(10, toAsset.decimals)));

    // Encode Uniswap V3 fee (3000 = 0.3%)
    const swapData = `0x${(3000).toString(16).padStart(8, '0')}` as `0x${string}`;

    const swapParams = {
      comet: '0xc3d688B66703497DAA19211EEdff47f25384cdc3' as Address,
      account: address,
      fromAsset: formData.fromAsset!,
      toAsset: formData.toAsset!,
      fromAmount,
      minToAsset,
      swapData,
      useFlashLoan: formData.useFlashLoan,
      receiver: address,
    };

    console.log('Swap params:', swapParams);
    await executeSwap(swapParams);
  };

  if (!isConnected) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center space-y-4">
          <h1 className="text-3xl font-bold">Comet Collateral Swap</h1>
          <p className="text-muted-foreground">
            Connect your wallet to start swapping collateral
          </p>
          <WalletConnect />
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="container mx-auto px-4 py-8">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold">Swap Collateral</h1>
              <p className="text-muted-foreground">
                Atomically replace your collateral on Compound v3
              </p>
            </div>
            <WalletConnect />
          </div>
        </div>

        {/* Main Content */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 max-w-6xl mx-auto">
          {/* Swap Card */}
          <div className="order-2 lg:order-1">
            <SwapCard
              assets={MOCK_ASSETS}
              onSwap={handleSwap}
              isLoading={isPending}
              healthFactor={positionData?.healthFactor}
            />
          </div>

          {/* Position Overview */}
          <div className="order-1 lg:order-2">
            <PositionOverview
              positionData={positionData}
              isLoading={positionLoading}
              onViewDetails={() => console.log('View details clicked')}
            />
          </div>
        </div>

        {/* Transaction Status */}
        {transactionStatus.status !== 'idle' && (
          <div className="mt-8 max-w-md mx-auto">
            <div className="bg-white rounded-lg border p-4">
              <h3 className="font-medium mb-2">Transaction Status</h3>
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span>Status:</span>
                  <span className={`font-medium ${
                    transactionStatus.status === 'success' ? 'text-green-600' :
                    transactionStatus.status === 'error' ? 'text-red-600' :
                    'text-blue-600'
                  }`}>
                    {transactionStatus.status}
                  </span>
                </div>
                {transactionStatus.hash && (
                  <div className="flex justify-between">
                    <span>Hash:</span>
                    <span className="font-mono text-xs">
                      {transactionStatus.hash.slice(0, 10)}...
                    </span>
                  </div>
                )}
                {transactionStatus.error && (
                  <div className="text-red-600 text-sm">
                    {transactionStatus.error}
                  </div>
                )}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
// Updated: Frontend components
