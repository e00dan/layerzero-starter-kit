// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";

import {OptionsBuilder} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";
import {Counter} from "../src/Counter.sol";
import {UUPSProxy} from "../src/UUPSProxy.sol";
import {OAppCoreInitializable} from "../src/OApp/OAppCoreInitializable.sol";

import {TestHelper} from "@layerzerolabs/lz-evm-oapp-v2/test/TestHelper.sol";

contract CounterTest is TestHelper {
    using OptionsBuilder for bytes;

    uint32 aEid = 1;
    uint32 bEid = 2;

    Counter public aCounter;
    Counter public bCounter;

    function setUp() public virtual override {
        super.setUp();

        setUpEndpoints(2, LibraryType.UltraLightNode);

        address[] memory uas = setupOAppsProxies(1, 2);
        aCounter = Counter(payable(uas[0]));
        bCounter = Counter(payable(uas[1]));
    }

    // classic message passing A -> B
    function test_increment() public {
        uint256 counterBefore = bCounter.count();

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        console2.logBytes(options);
        (uint256 nativeFee,) = aCounter.quote(bEid, options);
        aCounter.increment{value: nativeFee}(bEid, options);

        assertEq(bCounter.count(), counterBefore, "shouldn't be increased until packet is verified");

        // verify packet to bCounter manually
        verifyPackets(bEid, addressToBytes32(address(bCounter)));

        assertEq(bCounter.count(), counterBefore + 1, "increment assertion failure");
    }

    /**
     * @dev setup UAs, only if the UA has `endpoint` address as the unique parameter
     */
    function setupOAppsProxies(uint8 _startEid, uint8 _oappNum) public returns (address[] memory oapps) {
        oapps = new address[](_oappNum);
        for (uint8 eid = _startEid; eid < _startEid + _oappNum; eid++) {
            address oapp = _deployOAppProxy(address(endpoints[eid]), address(this));
            oapps[eid - _startEid] = oapp;
        }
        // config
        wireOApps(oapps);
    }

    function _deployOAppProxy(address _endpoint, address _owner) internal returns (address addr) {
        Counter counter = new Counter();
        UUPSProxy proxyCounter = new UUPSProxy(
            address(counter), abi.encodeWithSelector(OAppCoreInitializable.initialize.selector, _endpoint, _owner)
        );
        addr = address(proxyCounter);
    }
}
