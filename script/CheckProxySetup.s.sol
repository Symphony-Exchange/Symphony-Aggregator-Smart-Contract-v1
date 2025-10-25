// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract CheckProxySetup is Script {
    function run() external view {
        address proxyAddress = vm.envAddress("PROXY_ADDRESS");
        
        console.log("\n=== Checking Proxy Admin Setup ===");
        
        // The admin slot for TransparentUpgradeableProxy  
        // keccak256("eip1967.proxy.admin") - 1
        bytes32 ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
        
        // Read admin address from storage
        bytes32 adminData = vm.load(proxyAddress, ADMIN_SLOT);
        address actualAdmin = address(uint160(uint256(adminData)));
        console.log("Actual admin from proxy storage:", actualAdmin);
        
        // Check who owns this admin
        ProxyAdmin adminContract = ProxyAdmin(actualAdmin);
        address adminOwner = adminContract.owner();
        console.log("Owner of the admin contract:", adminOwner);
        console.log("Your address:", vm.envAddress("DEPLOYER_ADDRESS"));
        
        if (adminOwner == vm.envAddress("DEPLOYER_ADDRESS")) {
            console.log("[OK] You own the admin contract");
        } else {
            console.log("[ERROR] You don't own the admin contract");
            console.log("The owner is:", adminOwner);
        }
    }
}