// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/RedEnvelope.sol";
import "../src/helpers/NetworkConfig.sol";
import {ConstantGlobal} from "../src/lib/constant.sol";

contract ClaimPacketScript is Script, ConstantGlobal {
    function run() external {
        // Load private keys for deployer and user
        uint256 deployerPrivateKey = vm.envUint("ANVIL_PRIVATE_KEY");
        uint256 userPrivateKey = vm.envUint("ANVIL_PRIVATE_KEY_2");

        // Get the addresses from private keys
        address deployerAddress = vm.addr(deployerPrivateKey);
        address userAddress = vm.addr(userPrivateKey);

        // For local testing, we can deal some ETH to our addresses
        // This only works on local testnet (Anvil)
        vm.deal(deployerAddress, 10 ether);
        vm.deal(userAddress, 1 ether);

        console.log("Deployer balance:", deployerAddress.balance);
        console.log("User balance:", userAddress.balance);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy NetworkConfig first
        NetworkConfig networkConfig = new NetworkConfig();
        console.log("NetworkConfig deployed at:", address(networkConfig));

        // Deploy RedEnvelope
        RedEnvelope redEnvelope = new RedEnvelope();
        console.log("RedEnvelope deployed at:", address(redEnvelope));

        // Create an equal distribution envelope with smaller amount for testing
        try
            redEnvelope.createEnvelope{value: 0.5 ether}(
                5, // number of packets
                ENVELOP_TYPE_EQUAL,
                "Test Envelope for Claiming"
            )
        {
            console.log("Created test envelope with ID 0");
        } catch Error(string memory reason) {
            console.log("Failed to create envelope:", reason);
            revert("Envelope creation failed");
        }

        vm.stopBroadcast();

        // Now switch to user for claiming
        vm.startBroadcast(userPrivateKey);

        uint256 envelopeId = 0;
        uint256 packetId = 0;

        // Get user balance before claiming
        uint256 userBalanceBefore = userAddress.balance;
        console.log("\nUser balance before claiming:", userBalanceBefore);

        try redEnvelope.claimPacket(envelopeId, packetId) {
            console.log("Successfully claimed packet!");

            // Get user balance after claiming
            uint256 userBalanceAfter = userAddress.balance;
            console.log("User balance after claiming:", userBalanceAfter);
            console.log(
                "Amount received:",
                userBalanceAfter - userBalanceBefore
            );

            // Get packet details after claiming
            (
                uint256 amount,
                string memory status,
                address receiver
            ) = redEnvelope.packets(packetId);
            console.log("\nPacket details:");
            console.log("Amount:", amount);
            console.log("Status:", status);
            console.log("Receiver:", receiver);
        } catch Error(string memory reason) {
            console.log("Failed to claim packet:", reason);
        }

        vm.stopBroadcast();
    }
}
