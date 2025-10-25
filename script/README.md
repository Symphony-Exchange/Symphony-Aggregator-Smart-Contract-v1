# Symphony Transparent Proxy Deployment Guide

This guide explains how to deploy and upgrade the Symphony contract using the Transparent Proxy pattern.

## Prerequisites

- Foundry installed
- Private key with sufficient SEI for deployment
- RPC URL for SEI network

## Initial Deployment

1. Set environment variables:
```bash
export PRIVATE_KEY=your_private_key_here
export RPC_URL=https://your-sei-rpc-url
export FOUNDRY_EVM_VERSION=paris  # Required to override any global EVM version settings
```

2. Deploy the contracts:
```bash
forge script script/DeploySymphony.s.sol --rpc-url $RPC_URL --broadcast --verify
```

3. Save the deployment addresses from the output:
   - Implementation address
   - ProxyAdmin address
   - Proxy address (this is your main contract address)


```
forge verify-contract --watch \
  --compiler-version "0.8.23" \
  --evm-version "paris" \
  --verifier blockscout \
  --verifier-url https://seitrace.com/pacific-1/api \
  --etherscan-api-key dummy \
  --chain-id 1329 \
  --force \
  0xB318a16FB124048D1D3FB222083bcfD47485f913 \
  Symphony
  ```

## Upgrading the Contract

1. Set environment variables:
```bash
export PRIVATE_KEY=your_private_key_here
export RPC_URL=https://your-sei-rpc-url
export FOUNDRY_EVM_VERSION=paris  # Required to override any global EVM version settings
export PROXY_ADMIN=0x... # ProxyAdmin address from initial deployment
export PROXY_ADDRESS=0x... # Proxy address from initial deployment
```

2. Run the upgrade script:
```bash
forge script script/UpgradeSymphony.s.sol --rpc-url $RPC_URL --broadcast --verify
```

## Important Notes

- Always test deployments on testnet first
- The ProxyAdmin contract is owned by the deployer address
- Only the ProxyAdmin owner can upgrade the implementation
- Users interact with the Proxy address, not the implementation
- State is stored in the Proxy contract, not the implementation

## Verification

After deployment, verify your contracts on the block explorer:

```bash
forge verify-contract <IMPLEMENTATION_ADDRESS> src/Symphony.sol:Symphony --chain-id <CHAIN_ID>
```

## Security Considerations

- Store the ProxyAdmin address securely
- Consider using a multisig wallet as the ProxyAdmin owner
- Always audit new implementations before upgrading
- Test upgrades on testnet first