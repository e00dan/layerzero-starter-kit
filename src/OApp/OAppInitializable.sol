// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

// @dev Import the 'MessagingFee' so it's exposed to OApp implementers
// solhint-disable-next-line no-unused-import
import { OAppSender, MessagingFee } from "./OAppSender.sol";
// @dev Import the 'Origin' so it's exposed to OApp implementers
// solhint-disable-next-line no-unused-import
import { OAppReceiver, Origin } from "./OAppReceiver.sol";
import { OAppCoreInitializable } from "./OAppCoreInitializable.sol";

/**
 * @title OAppInitializable
 * @dev Abstract contract serving as the base for OApp implementation, combining OAppSender and OAppReceiver functionality.
 */
abstract contract OAppInitializable is Initializable, OAppSender, OAppReceiver {
    constructor() {
        _disableInitializers();
    }

    // /**
    //  * @dev Initialize the OApp with the provided endpoint and owner.
    //  * @param _endpoint The address of the LOCAL LayerZero endpoint.
    //  * @param _owner The address of the owner of the OApp.
    //  */
    // function initialize(address _endpoint, address _owner) public override initializer {
    //     super.initialize(_endpoint, _owner);
    // }

    /**
     * @notice Retrieves the OApp version information.
     * @return senderVersion The version of the OAppSender.sol implementation.
     * @return receiverVersion The version of the OAppReceiver.sol implementation.
     */
    function oAppVersion()
        public
        pure
        virtual
        override(OAppSender, OAppReceiver)
        returns (uint64 senderVersion, uint64 receiverVersion)
    {
        return (SENDER_VERSION, RECEIVER_VERSION);
    }
}
