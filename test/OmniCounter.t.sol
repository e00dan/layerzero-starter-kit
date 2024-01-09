// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";

import {OptionsBuilder} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";

import {OmniCounter, MsgCodec} from "../src/OmniCounter.sol";
import {UUPSProxy} from "../src/UUPSProxy.sol";
import {ProxyTestHelper} from "./utils/ProxyTestHelper.sol";

contract CounterTest is ProxyTestHelper {
    using OptionsBuilder for bytes;

    uint32 aEid = 1;
    uint32 bEid = 2;

    OmniCounter public aCounter;
    OmniCounter public bCounter;

    function setUp() public virtual override {
        super.setUp();

        setUpEndpoints(2, LibraryType.UltraLightNode);

        (address[] memory uas,) = setupOAppsProxies(type(OmniCounter).creationCode, 1, 2);
        aCounter = OmniCounter(payable(uas[0]));
        bCounter = OmniCounter(payable(uas[1]));
    }

    // classic message passing A -> B
    function test_increment() public {
        uint256 counterBefore = bCounter.count();

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        (uint256 nativeFee,) = aCounter.quote(bEid, MsgCodec.VANILLA_TYPE, options);
        aCounter.increment{value: nativeFee}(bEid, MsgCodec.VANILLA_TYPE, options);

        assertEq(bCounter.count(), counterBefore, "shouldn't be increased until packet is verified");

        // verify packet to bCounter manually
        verifyPackets(bEid, addressToBytes32(address(bCounter)));

        assertEq(bCounter.count(), counterBefore + 1, "increment assertion failure");
    }

    function test_batchIncrement() public {
        uint256 counterBefore = bCounter.count();

        uint256 batchSize = 5;
        uint32[] memory eids = new uint32[](batchSize);
        uint8[] memory types = new uint8[](batchSize);
        bytes[] memory options = new bytes[](batchSize);
        bytes memory option = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        uint256 fee;
        for (uint256 i = 0; i < batchSize; i++) {
            eids[i] = bEid;
            types[i] = MsgCodec.VANILLA_TYPE;
            options[i] = option;
            (uint256 nativeFee,) = aCounter.quote(eids[i], types[i], options[i]);
            fee += nativeFee;
        }

        vm.expectRevert(); // Errors.InvalidAmount
        aCounter.batchIncrement{value: fee - 1}(eids, types, options);

        aCounter.batchIncrement{value: fee}(eids, types, options);
        verifyPackets(bEid, addressToBytes32(address(bCounter)));

        assertEq(bCounter.count(), counterBefore + batchSize, "batchIncrement assertion failure");
    }

    function test_nativeDrop_increment() public {
        uint256 balanceBefore = address(bCounter).balance;

        bytes memory options = OptionsBuilder
            .newOptions()
            .addExecutorLzReceiveOption(200000, 0)
            .addExecutorNativeDropOption(1 gwei, addressToBytes32(address(bCounter)));
        (uint256 nativeFee, ) = aCounter.quote(bEid, MsgCodec.VANILLA_TYPE, options);
        aCounter.increment{ value: nativeFee }(bEid, MsgCodec.VANILLA_TYPE, options);

        // verify packet to bCounter manually
        verifyPackets(bEid, addressToBytes32(address(bCounter)));

        assertEq(address(bCounter).balance, balanceBefore + 1 gwei, "nativeDrop assertion failure");

        // transfer funds out
        address payable receiver = payable(address(0xABCD));
        address payable admin = payable(address(this));

        // withdraw with non admin
        vm.startPrank(receiver);
        vm.expectRevert("only admin");
        bCounter.withdraw(receiver, 1 gwei);
        vm.stopPrank();

        // withdraw with admin
        vm.startPrank(admin);
        bCounter.withdraw(receiver, 1 gwei);
        assertEq(address(bCounter).balance, 0, "withdraw assertion failure");
        assertEq(receiver.balance, 1 gwei, "withdraw assertion failure");
        vm.stopPrank();
    }

    // classic message passing A -> B1 -> B2
    function test_lzCompose_increment() public {
        uint256 countBefore = bCounter.count();
        uint256 composedCountBefore = bCounter.composedCount();

        bytes memory options =
            OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0).addExecutorLzComposeOption(0, 200000, 0);
        (uint256 nativeFee,) = aCounter.quote(bEid, MsgCodec.COMPOSED_TYPE, options);
        aCounter.increment{value: nativeFee}(bEid, MsgCodec.COMPOSED_TYPE, options);

        verifyPackets(bEid, addressToBytes32(address(bCounter)), 0, address(bCounter));

        assertEq(bCounter.count(), countBefore + 1, "increment B1 assertion failure");
        assertEq(bCounter.composedCount(), composedCountBefore + 1, "increment B2 assertion failure");
    }

    // A -> B -> A
    function test_ABA_increment() public {
        uint256 countABefore = aCounter.count();
        uint256 countBBefore = bCounter.count();

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(10000000, 10000000);
        (uint256 nativeFee,) = aCounter.quote(bEid, MsgCodec.ABA_TYPE, options);
        aCounter.increment{value: nativeFee}(bEid, MsgCodec.ABA_TYPE, options);

        verifyPackets(bEid, addressToBytes32(address(bCounter)));
        assertEq(aCounter.count(), countABefore, "increment A assertion failure");
        assertEq(bCounter.count(), countBBefore + 1, "increment B assertion failure");

        verifyPackets(aEid, addressToBytes32(address(aCounter)));
        assertEq(aCounter.count(), countABefore + 1, "increment A assertion failure");
    }

    // required for test helper to know how to initialize the OApp
    function _deployOAppProxy(address _endpoint, address _owner, address implementationAddress)
        internal
        override
        returns (address proxyAddress)
    {
        UUPSProxy proxy = new UUPSProxy(
            implementationAddress, abi.encodeWithSelector(OmniCounter.initialize.selector, _endpoint, _owner)
        );
        proxyAddress = address(proxy);
    }
}
