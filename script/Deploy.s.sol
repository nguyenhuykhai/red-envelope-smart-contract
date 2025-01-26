// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Script} from "forge-std/Script.sol";
import {RedEnvelope} from "src/RedEnvelope.sol";

contract Deploy is Script {
    RedEnvelope public redEnvelope;

    function run() external {
        vm.startBroadcast();
        redEnvelope = new RedEnvelope();
        vm.stopBroadcast();
    }
}
