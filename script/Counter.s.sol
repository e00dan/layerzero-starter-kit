// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { Counter } from "../src/Counter.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Counter counterSepolia = new Counter(address(0x464570adA09869d8741132183721B4f0769a0287));

        vm.stopBroadcast();
    }
}
