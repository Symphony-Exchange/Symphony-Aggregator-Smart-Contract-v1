#!/bin/bash

# Contract Verification Script for Chain ID 1329
# Make sure to set your ETHERSCAN_API_KEY environment variable

echo "=== Contract Verification on Chain 1329 ==="
echo ""

# Replace with your actual RPC URL for chain 1329
RPC_URL=${RPC_URL:-"https://evm-rpc.sei-apis.com"}
ETHERSCAN_API_KEY=${ETHERSCAN_API_KEY:-"6BP6DEGXI5TCSZUU3DN73NQE74ZHV776CX"}
VERIFIER_URL=${VERIFIER_URL:-"https://api.etherscan.io/v2/api"}

echo "Initial Deployment Verification:"
echo "================================"

# Verify initial Symphony implementation
echo "1. Verifying Symphony Implementation (0xB318a16FB124048D1D3FB222083bcfD47485f913)..."
forge verify-contract \
    --chain-id 1329 \
    --compiler-version v0.8.23+commit.f704f362 \
    --optimizer-runs 200 \
    0xB318a16FB124048D1D3FB222083bcfD47485f913 \
    src/Symphony.sol:Symphony \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --verifier-url $VERIFIER_URL

# Verify ProxyAdmin
echo "2. Verifying ProxyAdmin (0x559141d908170Cb962CFC46F43Ba049289aF1f09)..."
forge verify-contract \
    --chain-id 1329 \
    --compiler-version v0.8.23+commit.f704f362 \
    --optimizer-runs 200 \
    --constructor-args $(cast abi-encode "constructor(address)" 0xa2a9dd657D44e46E2d1843B8784eFc3dE3Cf3A57) \
    0x559141d908170Cb962CFC46F43Ba049289aF1f09 \
    lib/openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol:ProxyAdmin \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --verifier-url $VERIFIER_URL

# Verify TransparentUpgradeableProxy
echo "3. Verifying TransparentUpgradeableProxy (0xC340F8C5C58f4f99B4e43673eba07Cf378047DD2)..."
forge verify-contract \
    --chain-id 1329 \
    --compiler-version v0.8.23+commit.f704f362 \
    --optimizer-runs 200 \
    --constructor-args $(cast abi-encode "constructor(address,address,bytes)" 0xB318a16FB124048D1D3FB222083bcfD47485f913 0xa2a9dd657D44e46E2d1843B8784eFc3dE3Cf3A57 0x8129fc1c) \
    0xC340F8C5C58f4f99B4e43673eba07Cf378047DD2 \
    lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol:TransparentUpgradeableProxy \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --verifier-url $VERIFIER_URL

echo ""
echo "Upgrade Verification:"
echo "===================="

# Verify new Symphony implementation
echo "4. Verifying New Symphony Implementation (0x877cb55d8539d43177c29846df96536ee2ceba57)..."
forge verify-contract \
    --chain-id 1329 \
    --compiler-version v0.8.23+commit.f704f362 \
    --optimizer-runs 200 \
    0x877cb55d8539d43177c29846df96536ee2ceba57 \
    src/Symphony.sol:Symphony \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --verifier-url $VERIFIER_URL

echo ""
echo "Note: The proxy at 0x92b087c576ACD9E7e7FC23B4B864643D4FD327c8 should already be verified"
echo "if it's the same proxy from initial deployment or needs separate verification if it's new."
echo ""
echo "Make sure to:"
echo "1. Set RPC_URL environment variable for chain 1329"
echo "2. Set ETHERSCAN_API_KEY with your API key"
echo "3. Set VERIFIER_URL with the block explorer API URL for chain 1329"