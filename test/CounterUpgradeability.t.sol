// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";

import {OptionsBuilder} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";

import {Counter} from "../src/Counter.sol";
import {Counter2} from "./mocks/Counter2.sol";
import {UUPSProxy} from "../src/UUPSProxy.sol";
import {ProxyTestHelper} from "./utils/ProxyTestHelper.sol";

contract CounterUpgradeabilityTest is ProxyTestHelper {
    using OptionsBuilder for bytes;

    uint32 aEid = 1;
    uint32 bEid = 2;

    Counter private counterImplementation;

    Counter public counter;
    Counter public bCounter;

    address private nonAdminAccount = makeAddr("nonAdminAccount");

    function setUp() public virtual override {
        super.setUp();

        setUpEndpoints(2, LibraryType.UltraLightNode);

        (address[] memory uas, address implementationAddress) = setupOAppsProxies(1, 2);

        counterImplementation = Counter(implementationAddress);

        counter = Counter(payable(uas[0]));
        bCounter = Counter(payable(uas[1]));
    }

    function test_setUp_alreadyInitialized_asProxy_reverts() public {
        vm.expectRevert("Initializable: contract is already initialized");

        counter.initialize(address(0), nonAdminAccount);
    }

    function test_setUp_alreadyInitialized_asImpl_reverts() public {
        vm.expectRevert("Initializable: contract is already initialized");
        counterImplementation.initialize(address(0), nonAdminAccount);
    }

    function test_setUp_succeeds() public {
        address expectedOwner = address(this);

        assertEq(counter.owner(), expectedOwner, "Owner should be set");
        assertEq(counter.count(), 0, "Counter number should be 0");
        assertEq(counter.getImplementation(), address(counterImplementation), "Implementation should be set");
    }

    function test_upgradeTo_notAdmin_reverts() public {
        Counter2 counterImpl2 = new Counter2();
        vm.prank(nonAdminAccount);

        vm.expectRevert("Ownable: caller is not the owner");
        counter.upgradeTo(address(counterImpl2));
    }

    function test_upgradeTo_succeeds() public {
        Counter2 counterImpl2 = new Counter2();
        address expectedOwner = address(this);

        increment_B_A();

        assertEq(counter.owner(), expectedOwner, "Owner should be correctly set before upgrade");
        assertEq(counter.count(), 1, "Counter number should be 1");

        counter.upgradeTo(address(counterImpl2));

        assertEq(counter.getImplementation(), address(counterImpl2), "Implementation should be upgraded");

        Counter2 counter2 = Counter2(address(counter));

        // State persists
        assertEq(counter2.count(), 1, "Counter number should be persisted after the upgrade");
        assertEq(counter2.owner(), expectedOwner, "Owner should be set correctly after the upgrade");
        assertEq(counter2.incrementsByTen(), 0);

        increment_B_A();

        assertEq(counter2.count(), 11);
        assertEq(counter2.incrementsByTen(), 1);
    }

    // increment from chain B to A
    function increment_B_A() private {
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        (uint256 nativeFee,) = bCounter.quote(aEid, options);
        bCounter.increment{value: nativeFee}(aEid, options);
        verifyPackets(aEid, addressToBytes32(address(counter)));
    }
}
