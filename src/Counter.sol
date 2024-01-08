// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import { OAppInitializable, MessagingFee, Origin } from "./OApp/OAppInitializable.sol";

contract Counter is OAppInitializable, UUPSUpgradeable {
    bytes public constant MESSAGE = "";

    uint256 public count;

    function increment(uint32 _dstEid,  bytes calldata _options) public payable {
        _lzSend(
            _dstEid, // Destination chain's endpoint ID.
            MESSAGE, // Encoded message payload being sent.
            _options, // Message execution options (e.g., gas to use on destination).
            MessagingFee(msg.value, 0), // Fee struct containing native gas and ZRO token.
            payable(msg.sender) // The refund address in case the send call reverts.
        );
    }

    /* @dev Quotes the gas needed to pay for the full omnichain transaction.
    * @return nativeFee Estimated gas fee in native gas.
    * @return lzTokenFee Estimated gas fee in ZRO token.
    */
    function quote(
        uint32 _dstEid, // Destination chain's endpoint ID.
        bytes calldata _options // Message execution options
    ) public view returns (uint256 nativeFee, uint256 lzTokenFee) {
        MessagingFee memory fee = _quote(_dstEid, MESSAGE, _options, false);
        return (fee.nativeFee, fee.lzTokenFee);
    }

    function _lzReceive(
        Origin calldata _origin, // struct containing info about the message sender
        bytes32 _guid, // global packet identifier
        bytes calldata _message, // encoded message payload being received
        address _executor, // the Executor address.
        bytes calldata _extraData // arbitrary data appended by the Executor
    ) internal override {
        count++;
    }

    /* ========== UUPS ========== */
    //solhint-disable-next-line no-empty-blocks
    function _authorizeUpgrade(address) internal override onlyOwner {}
}
