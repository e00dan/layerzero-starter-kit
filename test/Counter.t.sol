// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";

import {LZEndpointMock} from "../src/lzApp/mocks/LZEndpointMock.sol";
import {Counter} from "../src/Counter.sol";
import {UUPSProxy} from "../src/UUPSProxy.sol";
import {LzApp} from "../src/lzApp/LzApp.sol";

import { TestHelper } from "@layerzerolabs/lz-evm-oapp-v2/test/TestHelper.sol";

contract CounterTest is TestHelper {
    LZEndpointMock public lzEndpointMock;

    Counter public counterSepolia;
    Counter public counterMumbai;

    uint16 public constant ChainId = 1221;

    function setUp() public {
        vm.deal(address(0x1), 100 ether);
        vm.deal(address(0x2), 100 ether);
        vm.deal(address(0x3), 100 ether);

        vm.prank(address(0x1));
        lzEndpointMock = new LZEndpointMock(ChainId);

        address ownerAddressSepolia = address(0x2);
        address ownerAddressMumbai = address(0x2);

        vm.prank(ownerAddressSepolia);

        counterSepolia = new Counter();
        UUPSProxy proxyCounterSepolia = new UUPSProxy(
            address(counterSepolia),
            abi.encodeWithSelector(LzApp.initialize.selector, ownerAddressSepolia, address(lzEndpointMock))
        );
        address proxyCounterAddressSepolia = address(proxyCounterSepolia);
        counterSepolia = Counter(proxyCounterAddressSepolia);

        // vm.prank(ownerAddressMumbai);
        // counterMumbai = new Counter();
        // UUPSProxy proxyCounterMumbai = new UUPSProxy(
        //     address(counterMumbai),
        //     abi.encodeWithSelector(LzApp.initialize.selector, ownerAddressMumbai, address(lzEndpointMock))
        // );
        // address proxyCounterAddressMumbai = address(proxyCounterMumbai);
        // counterMumbai = Counter(proxyCounterAddressMumbai);

        // vm.deal(address(lzEndpointMock), 100 ether);
        // vm.deal(address(counterSepolia), 100 ether);
        // vm.deal(address(counterMumbai), 100 ether);

        // vm.startPrank(address(0x1));
        // lzEndpointMock.setDestLzEndpoint(address(counterSepolia), address(lzEndpointMock));
        // lzEndpointMock.setDestLzEndpoint(address(counterMumbai), address(lzEndpointMock));
        // vm.stopPrank();

        // bytes memory counterSepoliaAddress = abi.encodePacked(uint160(proxyCounterAddressSepolia));
        // bytes memory counterMumbaiAddress = abi.encodePacked(uint160(proxyCounterAddressMumbai));

        // vm.prank(ownerAddressSepolia);
        // counterSepolia.setTrustedRemoteAddress(ChainId, counterMumbaiAddress);

        // vm.prank(ownerAddressMumbai);
        // counterMumbai.setTrustedRemoteAddress(ChainId, counterSepoliaAddress);
    }

    function test_SepoliaToMumbai() public {
        uint256 counter_initial = counterSepolia.counter();

        vm.deal(address(0x10), 100 ether);
        vm.startPrank(address(0x10));
        counterSepolia.incrementCounter{value: 1 ether}(ChainId);
        counterSepolia.incrementCounter{value: 1 ether}(ChainId);
        vm.stopPrank();

        assertEq(counterMumbai.counter(), counter_initial + 2);
    }

    // function test_MumbaiToSepolia() public {
    //     uint256 counter_initial = counterMumbai.counter();

    //     vm.deal(address(0x10), 100 ether);
    //     vm.prank(address(0x10));
    //     counterMumbai.incrementCounter{value: 1 ether}(ChainId);
    //     assertEq(counterSepolia.counter(), counter_initial + 1);
    // }
}
