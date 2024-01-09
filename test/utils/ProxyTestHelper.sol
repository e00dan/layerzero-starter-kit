// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";

import {OptionsBuilder} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";
import {TestHelper} from "@layerzerolabs/lz-evm-oapp-v2/test/TestHelper.sol";

import {UUPSProxy} from "../../src/UUPSProxy.sol";

abstract contract ProxyTestHelper is TestHelper {
    using OptionsBuilder for bytes;

    function setUp() public virtual override {}

    /**
     * @dev setup UAs, only if the UA has `endpoint` address as the unique parameter
     */
    function setupOAppsProxies(bytes memory _oappCreationCode, uint8 _startEid, uint8 _oappNum)
        public
        returns (address[] memory oapps, address implementationAddress)
    {
        implementationAddress = address(0);

        assembly {
            implementationAddress := create(0, add(_oappCreationCode, 0x20), mload(_oappCreationCode))
            if iszero(extcodesize(implementationAddress)) { revert(0, 0) }
        }

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
        virtual
        returns (address proxyAddress);
}
