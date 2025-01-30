// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {RedEnvelope} from "src/RedEnvelope.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        // Deploy với địa chỉ priceFeedAddress
        RedEnvelope redEnvelope = new RedEnvelope();

        vm.stopBroadcast();
        console.log("RedEnvelope deployed at:", address(redEnvelope));
    }
}
