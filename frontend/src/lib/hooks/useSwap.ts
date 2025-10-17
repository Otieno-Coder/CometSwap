import { useState } from 'react';
import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { Address } from 'viem';
import { COLLATERAL_SWAP_ROUTER_ABI } from '@/lib/contracts/abis';
import { getContractAddress } from '@/lib/contracts/addresses';
import { SwapExactInParams, TransactionStatus } from '@/lib/contracts/types';

export function useSwap() {
  const [transactionStatus, setTransactionStatus] = useState<TransactionStatus>({
    status: 'idle',
  });

  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  const executeSwap = async (params: SwapExactInParams) => {
    try {
      setTransactionStatus({ status: 'pending', step: 1, totalSteps: 4 });
      
      const routerAddress = getContractAddress('ROUTER') as Address;
      if (!routerAddress) {
        throw new Error('Router address not configured');
      }

      writeContract({
        address: routerAddress,
        abi: COLLATERAL_SWAP_ROUTER_ABI,
        functionName: 'swapCollateralExactIn',
        args: [params],
      });

      setTransactionStatus({ 
        status: 'pending', 
        hash, 
        step: 2, 
        totalSteps: 4 
      });
    } catch (err) {
      setTransactionStatus({ 
        status: 'error', 
        error: err instanceof Error ? err.message : 'Unknown error' 
      });
    }
  };

  // Update status when transaction is confirmed
  if (isSuccess && transactionStatus.status === 'pending') {
    setTransactionStatus({ status: 'success', hash });
  }

  if (error && transactionStatus.status === 'pending') {
    setTransactionStatus({ 
      status: 'error', 
      error: error.message 
    });
  }

  return {
    executeSwap,
    transactionStatus,
    isPending: isPending || isConfirming,
    hash,
    error,
  };
}
