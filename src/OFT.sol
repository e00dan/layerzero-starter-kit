// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OFTUpgradeable} from "@zodomo/oapp-upgradeable/oft/OFTUpgradeable.sol";

contract OFT is OFTUpgradeable, UUPSUpgradeable {
    constructor() {
        _disableInitializers();
    }

    function initialize(string memory _name, string memory _symbol, address _lzEndpoint, address _owner)
        public
        initializer
    {
        _initializeOFT(_name, _symbol, _lzEndpoint, _owner);
    }

    /* ========== UUPS ========== */
    //solhint-disable-next-line no-empty-blocks
    function _authorizeUpgrade(address) internal override onlyOwner {}

    function getImplementation() external view returns (address) {
        return _getImplementation();
    }
}
