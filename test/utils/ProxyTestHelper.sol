// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";

import {OptionsBuilder} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";
import {TestHelper} from "@layerzerolabs/lz-evm-oapp-v2/test/TestHelper.sol";

import {Counter} from "../../src/Counter.sol";
import {UUPSProxy} from "../../src/UUPSProxy.sol";
import {OAppCoreInitializable} from "../../src/OApp/OAppCoreInitializable.sol";

contract ProxyTestHelper is TestHelper {
    using OptionsBuilder for bytes;

    function setUp() public virtual override {}

    /**
     * @dev setup UAs, only if the UA has `endpoint` address as the unique parameter
     */
    function setupOAppsProxies(uint8 _startEid, uint8 _oappNum)
        public
        returns (address[] memory oapps, address implementationAddress)
    {
        Counter counter = new Counter();
        implementationAddress = address(counter);

        oapps = new address[](_oappNum);
        for (uint8 eid = _startEid; eid < _startEid + _oappNum; eid++) {
            address oapp = _deployOAppProxy(address(endpoints[eid]), address(this), implementationAddress);
            oapps[eid - _startEid] = oapp;
        }
        // config
        wireOApps(oapps);
    }

    function _deployOAppProxy(address _endpoint, address _owner, address implementationAddress)
        internal
        returns (address proxyAddress)
    {
        UUPSProxy proxy = new UUPSProxy(
            implementationAddress, abi.encodeWithSelector(OAppCoreInitializable.initialize.selector, _endpoint, _owner)
        );
        proxyAddress = address(proxy);
    }
}
