// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";

import {OptionsBuilder} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";

import {Counter} from "../src/Counter.sol";
import {UUPSProxy} from "../src/UUPSProxy.sol";
import {OAppCoreInitializable} from "../src/OApp/OAppCoreInitializable.sol";
import {ProxyTestHelper} from "./utils/ProxyTestHelper.sol";

contract CounterTest is ProxyTestHelper {
    using OptionsBuilder for bytes;

    uint32 aEid = 1;
    uint32 bEid = 2;

    Counter public aCounter;
    Counter public bCounter;

    function setUp() public virtual override {
        super.setUp();

        setUpEndpoints(2, LibraryType.UltraLightNode);

        (address[] memory uas,) = setupOAppsProxies(1, 2);
        aCounter = Counter(payable(uas[0]));
        bCounter = Counter(payable(uas[1]));
    }

    // classic message passing A -> B
    function test_increment_A_B() public {
        uint256 counterBefore = bCounter.count();

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        (uint256 nativeFee,) = aCounter.quote(bEid, options);
        aCounter.increment{value: nativeFee}(bEid, options);

        assertEq(bCounter.count(), counterBefore, "shouldn't be increased until packet is verified");

        // verify packet to bCounter manually
        verifyPackets(bEid, addressToBytes32(address(bCounter)));

        assertEq(bCounter.count(), counterBefore + 1, "increment assertion failure");
    }

    // classic message passing B -> A
    function test_increment_B_A() public {
        uint256 counterBefore = aCounter.count();

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        (uint256 nativeFee,) = bCounter.quote(aEid, options);
        bCounter.increment{value: nativeFee}(aEid, options);

        assertEq(aCounter.count(), counterBefore, "shouldn't be increased until packet is verified");

        // verify packet to bCounter manually
        verifyPackets(aEid, addressToBytes32(address(aCounter)));

        assertEq(aCounter.count(), counterBefore + 1, "increment assertion failure");
    }
}
