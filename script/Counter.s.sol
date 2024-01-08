// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";

import {BaseDeployer} from "./BaseDeployer.s.sol";
import {Counter} from "../src/Counter.sol";
import {UUPSProxy} from "../src/UUPSProxy.sol";
import {OAppCoreInitializable} from "../src/OApp/OAppCoreInitializable.sol";

contract DeployCounter is Script, BaseDeployer {
    address private create2addrCounter;
    address private create2addrProxy;

    Counter private wrappedProxy;

    // Endpoint configuration from: https://docs.layerzero.network/contracts/endpoint-addresses
    uint16 public constant LZ_ENDPOINT_ID_SEPOLIA = 40161;
    address public constant LZ_ENDPOINT_SEPOLIA = 0x464570adA09869d8741132183721B4f0769a0287;

    uint16 public constant LZ_ENDPOINT_ID_MUMBAI = 40109;
    address public constant LZ_ENDPOINT_MUMBAI = 0x464570adA09869d8741132183721B4f0769a0287;

    function setUp() public {}

    function run() public {}

    function deployCounterTestnet(uint256 _counterSalt, uint256 _counterProxySalt) public setEnvDeploy(Cycle.Test) {
        Chains[] memory deployForks = new Chains[](2);
        address[] memory lzEndpoints = new address[](2);

        counterSalt = bytes32(_counterSalt);
        counterProxySalt = bytes32(_counterProxySalt);

        deployForks[0] = Chains.Sepolia;
        lzEndpoints[0] = LZ_ENDPOINT_SEPOLIA;

        deployForks[1] = Chains.Mumbai;
        lzEndpoints[1] = LZ_ENDPOINT_MUMBAI;

        createDeployMultichain(deployForks, lzEndpoints);
    }

    /// @dev Helper to iterate over chains and select fork.
    /// @param deployForks The chains to deploy to.
    function createDeployMultichain(Chains[] memory deployForks, address[] memory lzEndpoints) private {
        address[] memory deployedContracts = new address[](2);
        uint256[] memory forkIds = new uint256[](2);

        for (uint256 i; i < deployForks.length;) {
            console2.log("Deploying Counter to chain:", uint256(deployForks[i]), "\n");

            uint256 forkId = createSelectFork(deployForks[i]);
            forkIds[i] = forkId;

            create2addrCounter = vm.computeCreate2Address(counterSalt, hashInitCode(type(Counter).creationCode));

            create2addrProxy = vm.computeCreate2Address(
                counterProxySalt,
                hashInitCode(
                    type(UUPSProxy).creationCode,
                    abi.encode(
                        create2addrCounter,
                        abi.encodeWithSelector(OAppCoreInitializable.initialize.selector, lzEndpoints[i], ownerAddress)
                    )
                )
            );
            deployedContracts[i] = chainDeployCounter(lzEndpoints[i]);

            unchecked {
                ++i;
            }
        }

        vm.selectFork(forkIds[0]);
        vm.startBroadcast(deployerPrivateKey);
        Counter(deployedContracts[0]).setPeer(LZ_ENDPOINT_ID_MUMBAI, addressToBytes32(deployedContracts[1]));
        vm.stopBroadcast();

        vm.selectFork(forkIds[1]);
        vm.startBroadcast(deployerPrivateKey);
        Counter(deployedContracts[1]).setPeer(LZ_ENDPOINT_ID_SEPOLIA, addressToBytes32(deployedContracts[0]));
        vm.stopBroadcast();
    }

    /// @dev Function to perform actual deployment.
    function chainDeployCounter(address lzEndpoint)
        private
        broadcast(deployerPrivateKey)
        returns (address deployedContract)
    {
        Counter counter = new Counter{salt: counterSalt}();

        require(create2addrCounter == address(counter), "Address mismatch Counter");

        console2.log("Counter address:", address(counter), "\n");

        proxyCounter = new UUPSProxy{salt: counterProxySalt}(
            address(counter),
            abi.encodeWithSelector(OAppCoreInitializable.initialize.selector, lzEndpoint, ownerAddress)
        );

        proxyCounterAddress = address(proxyCounter);

        require(create2addrProxy == proxyCounterAddress, "Address mismatch ProxyCounter");

        wrappedProxy = Counter(proxyCounterAddress);

        require(wrappedProxy.owner() == ownerAddress, "Owner role mismatch");

        console2.log("Counter Proxy address:", address(proxyCounter), "\n");

        return address(proxyCounter);
    }

    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }
}
