'use client';

import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Info } from 'lucide-react';
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from '@/components/ui/tooltip';

interface ModeToggleProps {
  useFlashLoan: boolean;
  onModeChange: (useFlashLoan: boolean) => void;
  healthFactor?: number;
  disabled?: boolean;
}

export function ModeToggle({
  useFlashLoan,
  onModeChange,
  healthFactor,
  disabled = false,
}: ModeToggleProps) {
  const getRecommendedMode = () => {
    if (healthFactor === undefined) return null;
    if (healthFactor < 1.2) return 'flash';
    if (healthFactor < 1.5) return 'flash';
    return 'direct';
  };

  const recommendedMode = getRecommendedMode();
  const isRecommended = (mode: 'direct' | 'flash') => {
    return recommendedMode === mode;
  };

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-2">
        <span className="text-sm font-medium">Swap Mode</span>
        <TooltipProvider>
          <Tooltip>
            <TooltipTrigger>
              <Info className="h-4 w-4 text-muted-foreground" />
            </TooltipTrigger>
            <TooltipContent>
              <div className="max-w-xs">
                <p className="font-medium mb-1">Direct Mode</p>
                <p className="text-xs mb-2">
                  Fast and cheap. Use when you have sufficient health factor headroom.
                </p>
                <p className="font-medium mb-1">Flash Mode</p>
                <p className="text-xs">
                  Safe for risky positions. Uses flash loans to temporarily reduce debt.
                </p>
              </div>
            </TooltipContent>
          </Tooltip>
        </TooltipProvider>
      </div>

      <div className="grid grid-cols-2 gap-2">
        <Button
          variant={!useFlashLoan ? 'default' : 'outline'}
          onClick={() => onModeChange(false)}
          disabled={disabled}
          className="h-12 flex flex-col items-center gap-1"
        >
          <div className="flex items-center gap-2">
            <span className="font-medium">Direct</span>
            {isRecommended('direct') && (
              <Badge variant="secondary" className="text-xs">
                Recommended
              </Badge>
            )}
          </div>
          <div className="text-xs text-muted-foreground">
            Fast & Cheap
          </div>
          <div className="text-xs text-muted-foreground">
            ~$15 gas
          </div>
        </Button>

        <Button
          variant={useFlashLoan ? 'default' : 'outline'}
          onClick={() => onModeChange(true)}
          disabled={disabled}
          className="h-12 flex flex-col items-center gap-1"
        >
          <div className="flex items-center gap-2">
            <span className="font-medium">Flash</span>
            {isRecommended('flash') && (
              <Badge variant="secondary" className="text-xs">
                Recommended
              </Badge>
            )}
          </div>
          <div className="text-xs text-muted-foreground">
            Safe
          </div>
          <div className="text-xs text-muted-foreground">
            ~$45 gas
          </div>
        </Button>
      </div>

      {healthFactor !== undefined && (
        <div className="text-xs text-muted-foreground">
          {healthFactor < 1.2 && (
            <span className="text-red-600">
              ⚠️ Low health factor detected. Flash mode recommended.
            </span>
          )}
          {healthFactor >= 1.2 && healthFactor < 1.5 && (
            <span className="text-yellow-600">
              ⚠️ Moderate health factor. Consider flash mode for safety.
            </span>
          )}
          {healthFactor >= 1.5 && (
            <span className="text-green-600">
              ✅ Healthy position. Direct mode is safe.
            </span>
          )}
        </div>
      )}
    </div>
  );
}
