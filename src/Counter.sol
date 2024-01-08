// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./lzApp/NonblockingLzApp.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import { OAppInitializable, MessagingFee, Origin } from "./OApp/OAppInitializable.sol";

contract Counter is OAppInitializable, UUPSUpgradeable {
    bytes public constant PAYLOAD = "\x01\x02\x03\x04";
    uint256 public counter;

    function incrementCounter(uint32 _dstEid) public payable {
        bytes memory _options = bytes("0x00030100110100000000000000000000000000030d40");

        _lzSend(
            _dstEid, // Destination chain's endpoint ID.
            PAYLOAD, // Encoded message payload being sent.
            _options, // Message execution options (e.g., gas to use on destination).
            MessagingFee(msg.value, 0), // Fee struct containing native gas and ZRO token.
            payable(msg.sender) // The refund address in case the send call reverts.
        );
    }

    function _lzReceive(
        Origin calldata _origin, // struct containing info about the message sender
        bytes32 _guid, // global packet identifier
        bytes calldata payload, // encoded message payload being received
        address _executor, // the Executor address.
        bytes calldata _extraData // arbitrary data appended by the Executor
    ) internal override {
        counter += 1;
    }

    /* ========== UUPS ========== */
    //solhint-disable-next-line no-empty-blocks
    function _authorizeUpgrade(address) internal override onlyOwner {}
}
