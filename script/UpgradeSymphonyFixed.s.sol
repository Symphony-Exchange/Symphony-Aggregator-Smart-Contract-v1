// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../src/Symphony.sol";

contract UpgradeSymphonyFixed is Script {
    function run() external {
        // Read private key and addresses from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("PROXY_ADDRESS");
        
        // The actual ProxyAdmin that controls the proxy (from storage)
        address actualProxyAdmin = 0xFC0948709226c4fb27456db189080717176dF5E1;
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy new implementation
        Symphony newImplementation = new Symphony();
        console.log("New Symphony implementation deployed at:", address(newImplementation));
        
        // Get the actual ProxyAdmin instance
        ProxyAdmin proxyAdmin = ProxyAdmin(actualProxyAdmin);
        
        // Check current owner
        address currentOwner = proxyAdmin.owner();
        console.log("Current ProxyAdmin owner:", currentOwner);
        
        // The owner is the ProxyAdmin we deployed (0x8D4217122804F965e00bE401988b4F6A39071AC9)
        // So we need to call through that contract
        ProxyAdmin ownerProxyAdmin = ProxyAdmin(currentOwner);
        
        // Call upgradeAndCall through the owner ProxyAdmin
        // This will forward the call to the actual ProxyAdmin
        ownerProxyAdmin.upgradeAndCall(
            ITransparentUpgradeableProxy(proxyAddress),
            address(newImplementation),
            "" // No initialization data needed for upgrade
        );
        
        console.log("Proxy upgraded to new implementation");
        
        vm.stopBroadcast();
        
        // Log upgrade summary
        console.log("\n=== Upgrade Summary ===");
        console.log("Proxy:", proxyAddress);
        console.log("Actual ProxyAdmin:", actualProxyAdmin);
        console.log("Owner ProxyAdmin:", currentOwner);
        console.log("New Implementation:", address(newImplementation));
    }
}