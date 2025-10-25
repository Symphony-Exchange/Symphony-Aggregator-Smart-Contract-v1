// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

/// @notice Script to verify deployed contracts on block explorer
/// Run with: forge script script/VerifyContracts.s.sol --rpc-url <RPC_URL> --broadcast
contract VerifyContracts is Script {
    function run() external {
        console2.log("=== Contract Verification Info ===");
        console2.log("Chain ID: 1329 (0x531)");
        console2.log("");

        console2.log("Initial Deployment:");
        console2.log("- Implementation: 0xB318a16FB124048D1D3FB222083bcfD47485f913");
        console2.log("- Proxy: 0xC340F8C5C58f4f99B4e43673eba07Cf378047DD2");
        console2.log("- ProxyAdmin: 0x559141d908170Cb962CFC46F43Ba049289aF1f09");
        console2.log("");

        console2.log("Upgrade:");
        console2.log("- New Implementation: 0x877cb55d8539d43177c29846df96536ee2ceba57");
        console2.log("- Proxy Address: 0x92b087c576ACD9E7e7FC23B4B864643D4FD327c8");
        console2.log("- ProxyAdmin: 0x6b2ad7ff78e4e49478a286292bb1b5ebe558301c");
        console2.log("");

        console2.log("To verify on Etherscan/Blockscout:");
        console2.log("1. Verify Implementation contract (Symphony.sol)");
        console2.log("2. Verify ProxyAdmin contract");
        console2.log("3. Verify TransparentUpgradeableProxy");
    }
}