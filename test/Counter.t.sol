// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";

import {LZEndpointMock} from "../src/lzApp/mocks/LZEndpointMock.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
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

        vm.prank(address(0x2));
        counterSepolia = new Counter(address(lzEndpointMock));

        vm.prank(address(0x3));
        counterMumbai = new Counter(address(lzEndpointMock));

        vm.deal(address(lzEndpointMock), 100 ether);
        vm.deal(address(counterSepolia), 100 ether);
        vm.deal(address(counterMumbai), 100 ether);

        vm.startPrank(address(0x1));
        lzEndpointMock.setDestLzEndpoint(address(counterSepolia), address(lzEndpointMock));
        lzEndpointMock.setDestLzEndpoint(address(counterMumbai), address(lzEndpointMock));
        vm.stopPrank();
        
        bytes memory counterMumbaiAddress = abi.encodePacked(uint160(address(counterMumbai)));
        bytes memory counterSepoliaAddress = abi.encodePacked(uint160(address(counterSepolia)));

        vm.prank(address(0x2));
        counterSepolia.setTrustedRemoteAddress(ChainId, counterMumbaiAddress);

        vm.prank(address(0x3));
        counterMumbai.setTrustedRemoteAddress(ChainId, counterSepoliaAddress);
    }

    function test_SepoliaToMumbai() public {
        uint counter_initial = counterSepolia.counter();

        vm.deal(address(0x10), 100 ether);
        vm.startPrank(address(0x10));
        counterSepolia.incrementCounter{value: 1 ether}(ChainId);
        counterSepolia.incrementCounter{value: 1 ether}(ChainId);
        vm.stopPrank();

        assertEq(counterMumbai.counter(), counter_initial+2);
    }

    function test_MumbaiToSepolia() public {
        uint counter_initial = counterMumbai.counter();

        vm.deal(address(0x10), 100 ether);
        vm.prank(address(0x10));
        counterMumbai.incrementCounter{value: 1 ether}(ChainId);
        assertEq(counterSepolia.counter(), counter_initial+1);
    }
}