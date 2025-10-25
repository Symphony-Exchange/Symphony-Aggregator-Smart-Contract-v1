// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../src/Symphony.sol";

contract UpgradeSymphony is Script {
    function run() external {
        // Read private key and addresses from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAdminAddress = vm.envAddress("PROXY_ADMIN");
        address proxyAddress = vm.envAddress("PROXY_ADDRESS");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy new implementation
        Symphony newImplementation = new Symphony();
        console.log("New Symphony implementation deployed at:", address(newImplementation));
        
        // Get ProxyAdmin instance
        ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdminAddress);
        
        // Upgrade proxy to new implementation
        proxyAdmin.upgradeAndCall(
            ITransparentUpgradeableProxy(proxyAddress),
            address(newImplementation),
            "" // No initialization data needed for upgrade
        );
        
        console.log("Proxy upgraded to new implementation");
        
        vm.stopBroadcast();
        
        // Log upgrade summary
        console.log("\n=== Upgrade Summary ===");
        console.log("Proxy:", proxyAddress);
        console.log("ProxyAdmin:", proxyAdminAddress);
        console.log("New Implementation:", address(newImplementation));
    }
}