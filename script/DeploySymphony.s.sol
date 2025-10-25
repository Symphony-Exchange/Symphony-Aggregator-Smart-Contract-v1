// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "../src/Symphony.sol";

contract DeploySymphony is Script {
    function run() external {
        // Read private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.addr(deployerPrivateKey);

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy implementation contract
        Symphony symphonyImplementation = new Symphony();
        console.log("Symphony implementation deployed at:", address(symphonyImplementation));
        
        // Deploy ProxyAdmin
        // The deployer EOA will be the owner of the ProxyAdmin contract
        ProxyAdmin proxyAdmin = new ProxyAdmin(owner);
        console.log("ProxyAdmin deployed at:", address(proxyAdmin));
        console.log("ProxyAdmin owner (EOA):", proxyAdmin.owner());
        
        // Prepare initializer data
        bytes memory initData = abi.encodeWithSelector(Symphony.initialize.selector);
        
        // Deploy TransparentUpgradeableProxy
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(symphonyImplementation),
            address(proxyAdmin),
            initData
        );
        console.log("TransparentUpgradeableProxy deployed at:", address(proxy));
        
        // Verify the proxy is working correctly
        Symphony symphony = Symphony(payable(address(proxy)));
        address owner2 = symphony.owner();
        console.log("Symphony owner through proxy:", owner2);
        
        vm.stopBroadcast();
        
        // Log deployment addresses for verification
        console.log("\n=== Deployment Summary ===");
        console.log("Implementation:", address(symphonyImplementation));
        console.log("ProxyAdmin:", address(proxyAdmin));
        console.log("Proxy:", address(proxy));
        console.log("Owner:", owner2);
    }
}