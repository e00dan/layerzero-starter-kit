// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";

import { BaseDeployer } from './BaseDeployer.s.sol';
import { Counter } from "../src/Counter.sol";
import { UUPSProxy } from "../src/UUPSProxy.sol";
import { LzApp } from "../src/lzApp/LzApp.sol";

contract CounterScript is Script, BaseDeployer {
    address private create2addrCounter;
    address private create2addrProxy;

    Counter private wrappedProxy;

    address public constant LZ_ENDPOINT_SEPOLIA = 0x464570adA09869d8741132183721B4f0769a0287;

    function setUp() public {}

    function run() public {
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // vm.startBroadcast(deployerPrivateKey);

        // Counter counterSepolia = new Counter(LZ_SEPOLIA_ENDPOINT);

        // vm.stopBroadcast();
    }

    function deployCounterTestnet() public {
        Chains[] memory deployForks = new Chains[](1);

        deployForks[0] = Chains.Sepolia;

        createDeployMultichain(deployForks);
    }

    /// @dev Helper to iterate over chains and select fork.
    /// @param deployForks The chains to deploy to.
    function createDeployMultichain(
        Chains[] memory deployForks
    ) private {
        for (uint256 i; i < deployForks.length; ) {
            console2.log("Deploying Counter to chain: ", uint(deployForks[i]), "\n");

            createSelectFork(deployForks[i]);

            chainDeployCounter();

            unchecked {
                ++i;
            }
        }
    }

     /// @dev Function to perform actual deployment.
    function chainDeployCounter() private broadcast(deployerPrivateKey) {
        Counter counter = new Counter{salt: counterSalt}();

        require(create2addrCounter == address(counter), "Address mismatch Counter");

        console2.log("Counter address:", address(counter), "\n");

        proxyCounter = new UUPSProxy{salt: counterProxySalt}(
            address(counter),
            abi.encodeWithSelector(LzApp.initialize.selector, ownerAddress, LZ_ENDPOINT_SEPOLIA)
        );

        proxyCounterAddress = address(proxyCounter);

        require(create2addrProxy == proxyCounterAddress, "Address mismatch ProxyCounter");

        wrappedProxy = Counter(proxyCounterAddress);

        require(wrappedProxy.owner() == ownerAddress, "Owner role mismatch");

        console2.log("Counter Proxy address:", address(proxyCounter), "\n");
    }
}
