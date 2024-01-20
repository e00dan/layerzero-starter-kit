// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";

import {OptionsBuilder} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";

import {OFTMock} from "./mocks/OFTMock.sol";
import {MessagingFee, MessagingReceipt} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFTCore.sol";
import {IOFT, SendParam, OFTReceipt} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";

import {OFT} from "../src/OFT.sol";
import {UUPSProxy} from "../src/UUPSProxy.sol";
import {ProxyTestHelper} from "./utils/ProxyTestHelper.sol";

contract OFTTest is ProxyTestHelper {
    using OptionsBuilder for bytes;

    uint32 aEid = 1;
    uint32 bEid = 2;
    uint32 cEid = 3;

    OFTMock aOFT;
    OFTMock bOFT;

    address public userA = address(0x1);
    address public userB = address(0x2);
    address public userC = address(0x3);
    uint256 public initialBalance = 100 ether;

    function setUp() public virtual override {
        vm.deal(userA, 1000 ether);
        vm.deal(userB, 1000 ether);
        vm.deal(userC, 1000 ether);

        super.setUp();

        setUpEndpoints(3, LibraryType.UltraLightNode);

        aOFT = OFTMock(
            _deployOAppProxyGeneralized(
                type(OFTMock).creationCode,
                abi.encodeWithSelector(OFT.initialize.selector, "aOFT", "aOFT", address(endpoints[aEid]), address(this))
            )
        );

        bOFT = OFTMock(
            _deployOAppProxyGeneralized(
                type(OFTMock).creationCode,
                abi.encodeWithSelector(OFT.initialize.selector, "bOFT", "bOFT", address(endpoints[bEid]), address(this))
            )
        );

        // config and wire the ofts
        address[] memory ofts = new address[](2);
        ofts[0] = address(aOFT);
        ofts[1] = address(bOFT);
        this.wireOApps(ofts);

        // mint tokens
        aOFT.mint(userA, initialBalance);
        bOFT.mint(userB, initialBalance);
    }

    function test_initializer() public {
        assertEq(aOFT.owner(), address(this));
        assertEq(bOFT.owner(), address(this));

        assertEq(aOFT.balanceOf(userA), initialBalance);
        assertEq(bOFT.balanceOf(userB), initialBalance);

        assertEq(aOFT.token(), address(aOFT));
        assertEq(bOFT.token(), address(bOFT));
    }

    function test_send_oft() public {
        uint256 tokensToSend = 1 ether;
        SendParam memory sendParam = SendParam(bEid, addressToBytes32(userB), tokensToSend, tokensToSend);
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        MessagingFee memory fee = aOFT.quoteSend(sendParam, options, false, "", "");

        assertEq(aOFT.balanceOf(userA), initialBalance);
        assertEq(bOFT.balanceOf(userB), initialBalance);

        vm.prank(userA);
        aOFT.send{value: fee.nativeFee}(sendParam, options, fee, payable(address(this)), "", "");
        verifyPackets(bEid, addressToBytes32(address(bOFT)));

        assertEq(aOFT.balanceOf(userA), initialBalance - tokensToSend);
        assertEq(bOFT.balanceOf(userB), initialBalance + tokensToSend);
    }

    function _deployOAppProxy(address _endpoint, address _owner, address implementationAddress)
        internal
        override
        returns (address proxyAddress)
    {}
}
