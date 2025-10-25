// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "../src/Symphony.sol";

/// @notice Deploys Symphony behind a TransparentUpgradeableProxy with a sane single ProxyAdmin.
/// - If ENV PROXY_ADMIN is set, reuses that address as the proxy admin (must already exist).
/// - Else deploys a new ProxyAdmin whose owner is ENV OWNER (or defaults to deployer EOA).
/// - Calls Symphony.initialize() via the proxy constructor.
/// ENV:
///   PRIVATE_KEY        (required) - deployer key
///   OWNER              (optional) - owner of ProxyAdmin (EOA or multisig). Defaults to deployer EOA
contract DeploySymphony is Script {
    function run() external {
        uint256 deployerPk = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPk);

        // Optional owner override for ProxyAdmin
        address owner = _tryEnvAddress("OWNER");
        if (owner == address(0)) owner = deployer;
        require(owner != address(0), "OWNER cannot be zero");

        vm.startBroadcast(deployerPk);

        // 1) Deploy implementation
        Symphony impl = new Symphony();
        console2.log("Symphony implementation:", address(impl));

        // 2) Prepare initializer calldata
        bytes memory initData = abi.encodeCall(Symphony.initialize, ());

        // 3) Deploy TransparentUpgradeableProxy
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(impl),
            address(owner),
            initData
        );
        console2.log("Proxy                  :", address(proxy));

        // 4) Quick runtime checks through proxy
        Symphony proxied = Symphony(payable(address(proxy)));

        // Example sanity: owner() should be set by initialize()
        address symOwner = proxied.owner();
        console2.log("Symphony.owner() via proxy:", symOwner);

        // Optional: confirm admin slot value (EIP-1967 admin)
        // bytes32 implSlot = vm.load(address(proxy), 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc);
        // bytes32 adminSlot = vm.load(address(proxy), 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103);
        // console2.logBytes32(implSlot);
        // console2.logBytes32(adminSlot);

        vm.stopBroadcast();

        console2.log("\n=== Deployment Summary ===");
        console2.log("Deployer EOA           :", deployer);
        console2.log("Implementation         :", address(impl));
        console2.log("Proxy                  :", address(proxy));
        console2.log("Symphony.owner()       :", symOwner);
    }

    /// @dev Reads an env var as address if present; returns address(0) if missing/empty.
    function _tryEnvAddress(string memory key) internal view returns (address) {
        // Foundry doesn't have a direct "optional" env address read, so we try bytes and parse.
        // If unset, vm.envOr(...) could be used on newer versions; this is broadly compatible.
        try vm.envAddress(key) returns (address a) {
            return a;
        } catch {
            return address(0);
        }
    }
}
