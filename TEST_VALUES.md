# 🧪 Comet Collateral Swap - Test Values

## 🔧 MetaMask Configuration

**Network Settings:**
- **Network Name:** Anvil Local
- **RPC URL:** http://localhost:8545
- **Chain ID:** 1
- **Currency Symbol:** ETH
- **Block Explorer URL:** (leave empty)

## 🔑 Test Account

**Import this account into MetaMask:**
- **Private Key:** `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`
- **Address:** `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`

## 💰 Current Balances

**Test Account has:**
- **ETH:** 9.22 ETH (for gas fees)
- **WETH:** 3 WETH (for collateral)
- **USDC:** 0 USDC (can be obtained via swap)
- **WBTC:** 0 WBTC (can be obtained via swap)

## 🏦 Contract Addresses

**Deployed Contracts:**
- **Router:** `0xf2F77681d677523D94a4F0EC1c054D61D04bf63c`
- **Swapper:** `0x5771c832D78fDf76A3DA918E4B7a49c062910639`

**Mainnet Contracts (via fork):**
- **Comet:** `0xc3d688B66703497DAA19211EEdff47f25384cdc3`
- **Aave Pool:** `0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2`
- **Uniswap Router:** `0xE592427A0AEce92De3Edee1F18E0157C05861564`
- **WETH:** `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
- **USDC:** `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`
- **WBTC:** `0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599`

## 🧪 Test Scenarios

### Scenario 1: Basic WETH to USDC Swap (Direct Mode)

**Setup:**
1. Connect MetaMask to Anvil Local network
2. Import the test account
3. Go to http://localhost:3000/swap

**Test Values:**
- **From Asset:** WETH
- **To Asset:** USDC
- **Amount:** 0.1 WETH
- **Mode:** Direct
- **Slippage:** 0.5%

**Expected Result:**
- Should show preview of swap
- WETH balance should decrease by 0.1
- USDC balance should increase by ~$250-300

### Scenario 2: Flash-Assisted Swap (Safe Mode)

**Setup:**
1. First, supply some WETH as collateral to Comet
2. Borrow some USDC against it
3. Then try to swap collateral

**Test Values:**
- **From Asset:** WETH
- **To Asset:** USDC
- **Amount:** 0.5 WETH
- **Mode:** Flash-assisted
- **Slippage:** 1.0%

**Expected Result:**
- Should use flash loan to temporarily repay debt
- Allow collateral withdrawal
- Execute swap
- Re-borrow to restore position

### Scenario 3: Large Amount Swap

**Test Values:**
- **From Asset:** WETH
- **To Asset:** USDC
- **Amount:** 1.0 WETH
- **Mode:** Direct
- **Slippage:** 0.1%

**Expected Result:**
- Should handle larger amounts
- May show price impact warning
- Should complete successfully

## 🔍 What to Look For

### ✅ Success Indicators
- Wallet connects successfully
- Assets load with correct balances
- Swap preview shows realistic amounts
- Transaction executes without errors
- Balances update after swap
- Health factor remains stable

### ⚠️ Warning Signs
- "Wrong network" errors (check Chain ID = 1)
- "Insufficient balance" errors
- "Transaction failed" errors
- Health factor drops below 1.0
- Gas estimation failures

## 🐛 Common Issues & Solutions

### Issue: "Wrong Network"
**Solution:** Ensure MetaMask is on Chain ID 1, not 31337

### Issue: "Insufficient Balance"
**Solution:** Check that you have enough WETH (3 WETH available)

### Issue: "Transaction Failed"
**Solution:** 
- Check gas limit (try 500,000)
- Increase slippage tolerance
- Ensure contracts are deployed

### Issue: "Contract Not Found"
**Solution:** 
- Verify Anvil is running
- Check contract addresses are correct
- Redeploy contracts if needed

## 📊 Expected Swap Rates (Approximate)

**WETH to USDC:**
- 0.1 WETH ≈ $250-300 USDC
- 0.5 WETH ≈ $1,250-1,500 USDC
- 1.0 WETH ≈ $2,500-3,000 USDC

*Note: Rates are approximate and depend on current market conditions*

## 🚀 Quick Start Commands

```bash
# Start Anvil (if not running)
anvil --fork-url https://eth-mainnet.g.alchemy.com/v2/-9qz-DtOGipKb25eo-uCFmudmEqxgPbV

# Deploy contracts (if needed)
./scripts/deploy-to-anvil.sh

# Start frontend
cd frontend && npm run dev:local

# Test connection
./scripts/test-network-connection.sh
```

## 🎯 Testing Checklist

- [ ] MetaMask connected to Chain ID 1
- [ ] Test account imported (0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266)
- [ ] Frontend loads at http://localhost:3000/swap
- [ ] WETH balance shows 3 WETH
- [ ] Asset selector works
- [ ] Amount input accepts values
- [ ] Swap preview calculates correctly
- [ ] Transaction executes successfully
- [ ] Balances update after swap
- [ ] No console errors

## 💡 Pro Tips

1. **Start Small:** Begin with 0.1 WETH to test the flow
2. **Check Gas:** Use 500,000 gas limit for complex swaps
3. **Monitor Health Factor:** Keep it above 1.2 for safety
4. **Use Direct Mode First:** Simpler and faster for testing
5. **Check Console:** Look for any JavaScript errors

Happy testing! 🎉
