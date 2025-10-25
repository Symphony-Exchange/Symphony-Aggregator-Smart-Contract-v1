// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../src/Symphony.sol";

contract UpgradeThroughInternalAdmin is Script {
    function run() external {
        // Read private key and addresses from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = 0xb6F11A6296536790d3295D8861C3C331594b126d;
        address yourProxyAdmin = 0x8D4217122804F965e00bE401988b4F6A39071AC9;
        address internalProxyAdmin = 0xFC0948709226c4fb27456db189080717176dF5E1;
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy new implementation
        Symphony newImplementation = new Symphony();
        console.log("New Symphony implementation deployed at:", address(newImplementation));
        
        // Your ProxyAdmin contract can call functions on contracts it owns
        // We use your ProxyAdmin to call upgradeAndCall on the internal ProxyAdmin
        ProxyAdmin(yourProxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(proxyAddress),
            address(newImplementation),
            ""
        );
        
        console.log("Proxy upgraded to new implementation");
        
        vm.stopBroadcast();
        
        // Log upgrade summary
        console.log("\n=== Upgrade Summary ===");
        console.log("Proxy:", proxyAddress);
        console.log("Your ProxyAdmin:", yourProxyAdmin);
        console.log("Internal ProxyAdmin:", internalProxyAdmin);
        console.log("New Implementation:", address(newImplementation));
    }
}