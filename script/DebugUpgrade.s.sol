// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../src/Symphony.sol";

contract DebugUpgrade is Script {
    function run() external {
        // Read private key and addresses from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address proxyAdminAddress = vm.envAddress("PROXY_ADMIN");
        address proxyAddress = vm.envAddress("PROXY_ADDRESS");
        
        console.log("\n=== Debug Information ===");
        console.log("Deployer address from private key:", deployer);
        console.log("ProxyAdmin address:", proxyAdminAddress);
        console.log("Proxy address:", proxyAddress);
        
        // Get ProxyAdmin instance
        ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdminAddress);
        
        // Check ProxyAdmin owner
        address proxyAdminOwner = proxyAdmin.owner();
        console.log("ProxyAdmin owner:", proxyAdminOwner);
        
        // Check if deployer is the owner
        if (deployer == proxyAdminOwner) {
            console.log("[OK] Deployer IS the ProxyAdmin owner - upgrade should work");
        } else {
            console.log("[ERROR] Deployer is NOT the ProxyAdmin owner - upgrade will fail!");
            console.log("  The ProxyAdmin owner needs to execute the upgrade");
        }
        
        // Note: ProxyAdmin doesn't expose getters for implementation/admin directly
        // These would need to be called on the proxy itself, but TransparentUpgradeableProxy
        // prevents the admin from calling functions on the proxy directly
        
        console.log("\n=== Attempting test upgrade (no broadcast) ===");
        
        // Try to simulate the upgrade to see if it would work

    }
}