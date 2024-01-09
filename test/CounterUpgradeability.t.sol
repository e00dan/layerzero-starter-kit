// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";

import {OptionsBuilder} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";

import {Counter} from "../src/Counter.sol";
import {UUPSProxy} from "../src/UUPSProxy.sol";
import {OAppCoreInitializable} from "../src/OApp/OAppCoreInitializable.sol";
import {ProxyTestHelper} from "./utils/ProxyTestHelper.sol";

contract CounterUpgradeabilityTest is ProxyTestHelper {
    using OptionsBuilder for bytes;

    uint32 aEid = 1;
    uint32 bEid = 2;

    Counter private counterImplementation;

    Counter public aCounter;
    Counter public bCounter;

    address private nonAdminAccount = makeAddr("nonAdminAccount");

    function setUp() public virtual override {
        super.setUp();

        setUpEndpoints(2, LibraryType.UltraLightNode);

        (address[] memory uas, address implementationAddress) = setupOAppsProxies(1, 2);

        counterImplementation = Counter(implementationAddress);

        aCounter = Counter(payable(uas[0]));
        bCounter = Counter(payable(uas[1]));
    }

    function test_setUp_alreadyInitialized_asProxy_reverts() public {
        vm.expectRevert("Initializable: contract is already initialized");

        aCounter.initialize(address(0), nonAdminAccount);
    }

    function test_setUp_alreadyInitialized_asImpl_reverts() public {
        vm.expectRevert("Initializable: contract is already initialized");
        counterImplementation.initialize(address(0), nonAdminAccount);
    }
}
