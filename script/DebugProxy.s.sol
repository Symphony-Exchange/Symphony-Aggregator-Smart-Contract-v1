// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../src/Symphony.sol";

contract DebugProxy is Script {
    function run() external view {
        address proxyAdminAddress = vm.envAddress("PROXY_ADMIN");
        address proxyAddress = vm.envAddress("PROXY_ADDRESS");
        
        console.log("\n=== Checking Proxy Storage ===");
        
        // The implementation slot for TransparentUpgradeableProxy
        // keccak256("eip1967.proxy.implementation") - 1
        bytes32 IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        
        // The admin slot for TransparentUpgradeableProxy  
        // keccak256("eip1967.proxy.admin") - 1
        bytes32 ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
        
        // Read implementation address from storage
        bytes32 implData = vm.load(proxyAddress, IMPLEMENTATION_SLOT);
        address implementation = address(uint160(uint256(implData)));
        console.log("Current implementation (from storage):", implementation);
        
        // Read admin address from storage
        bytes32 adminData = vm.load(proxyAddress, ADMIN_SLOT);
        address admin = address(uint160(uint256(adminData)));
        console.log("Current admin (from storage):", admin);
        console.log("Expected admin:", proxyAdminAddress);
        
        if (admin == proxyAdminAddress) {
            console.log("[OK] Admin slot matches ProxyAdmin address");
        } else {
            console.log("[ERROR] Admin slot does NOT match ProxyAdmin address!");
            console.log("This proxy may not be controlled by the ProxyAdmin");
        }
        
        // Check if implementation is a contract
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(implementation)
        }
        
        if (codeSize > 0) {
            console.log("[OK] Implementation is a deployed contract");
        } else {
            console.log("[ERROR] Implementation address has no code!");
        }
    }
}