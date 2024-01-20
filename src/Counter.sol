// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OAppUpgradeable, MessagingFee, Origin} from "@zodomo/oapp-upgradeable/oapp/OAppUpgradeable.sol";

contract Counter is OAppUpgradeable, UUPSUpgradeable {
    bytes public constant MESSAGE = "";

    uint256 public count;

    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initialize the OApp with the provided endpoint and owner.
     * @param _endpoint The address of the LOCAL LayerZero endpoint.
     * @param _owner The address of the owner of the OApp.
     */
    function initialize(address _endpoint, address _owner) public initializer {
        _initializeOApp(_endpoint, _owner);
    }

    function increment(uint32 _dstEid, bytes calldata _options) public payable {
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

    function getImplementation() external view returns (address) {
        return _getImplementation();
    }
}
