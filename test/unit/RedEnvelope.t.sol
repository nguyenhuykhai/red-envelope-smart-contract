// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/RedEnvelope.sol";
import "../../src/helpers/NetworkConfig.sol";
import {ConstantGlobal} from "../../src/lib/constant.sol";

contract RedEnvelopeTest is Test, ConstantGlobal {
    RedEnvelope public redEnvelope;
    NetworkConfig public networkConfig;

    address public deployer;
    address public user1;
    address public user2;
    uint256 public deployerPrivateKey;
    uint256 public user1PrivateKey;
    uint256 public user2PrivateKey;

    function setUp() public {
        // Generate private keys and addresses
        deployerPrivateKey = 0xDEADBEEF;
        user1PrivateKey = 0x0BEEF;
        user2PrivateKey = 0x0C0FFEE;

        deployer = vm.addr(deployerPrivateKey);
        user1 = vm.addr(user1PrivateKey);
        user2 = vm.addr(user2PrivateKey);

        // Fund accounts
        vm.deal(deployer, 100 ether);
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);

        // Deploy contracts as deployer
        vm.startPrank(deployer);
        networkConfig = new NetworkConfig();
        redEnvelope = new RedEnvelope();
        vm.stopPrank();
    }

    function test_DeploymentState() public view {
        assertEq(redEnvelope.nextEnvelopeId(), 0);
        assertEq(redEnvelope.nextPacketId(), 0);
        assertEq(redEnvelope.getContractBalance(), 0);
    }

    function test_CreateEqualEnvelope() public {
        vm.startPrank(deployer);

        uint256 envelopeAmount = 11 ether;
        uint256 numberOfPackets = 5;

        redEnvelope.createEnvelope{value: envelopeAmount}(
            numberOfPackets,
            ENVELOP_TYPE_EQUAL,
            "Test Equal Envelope"
        );

        // Check envelope state
        (
            address creator,
            uint256 totalFund,
            uint256 remainingAmount,
            uint256 numberOfPacketsStored,
            string memory envelopeType, // message
            ,
            bool isActive, // createdAt

        ) = redEnvelope.envelopes(0);

        assertEq(creator, deployer);
        assertEq(totalFund, envelopeAmount);
        assertEq(remainingAmount, envelopeAmount);
        assertEq(numberOfPacketsStored, numberOfPackets);
        assertEq(
            keccak256(abi.encodePacked(envelopeType)),
            keccak256(abi.encodePacked(ENVELOP_TYPE_EQUAL))
        );
        assertTrue(isActive);

        // Check packet states
        uint256[] memory packetIds = redEnvelope.getPacketsByEnvelope(0);
        assertEq(packetIds.length, numberOfPackets);

        // Check equal distribution
        uint256 expectedAmount = envelopeAmount / numberOfPackets;
        for (uint256 i = 0; i < packetIds.length; i++) {
            (
                uint256 amount,
                string memory status,
                address receiver
            ) = redEnvelope.packets(packetIds[i]);
            if (i == packetIds.length - 1) {
                // Last packet larger than expectedAmount
                assertTrue(amount >= expectedAmount);
            } else {
                assertEq(amount, expectedAmount);
            }
            assertEq(
                keccak256(abi.encodePacked(status)),
                keccak256(abi.encodePacked(PACKET_STATUS_UNCLAIMED))
            );
            assertEq(receiver, address(0));
        }

        vm.stopPrank();
    }

    function test_CreateRandomEnvelope() public {
        vm.startPrank(deployer);

        uint256 envelopeAmount = 13 ether;
        uint256 numberOfPackets = 5;

        redEnvelope.createEnvelope{value: envelopeAmount}(
            numberOfPackets,
            ENVELOP_TYPE_RANDOM,
            "Test Random Envelope"
        );

        // Check basic envelope state
        (
            address creator,
            uint256 totalFund,
            uint256 remainingAmount, // numberOfPackets
            ,
            string memory envelopeType, // message
            ,
            bool isActive, // createdAt

        ) = redEnvelope.envelopes(0);

        assertEq(creator, deployer);
        assertEq(totalFund, envelopeAmount);
        assertEq(remainingAmount, envelopeAmount);
        assertEq(
            keccak256(abi.encodePacked(envelopeType)),
            keccak256(abi.encodePacked(ENVELOP_TYPE_RANDOM))
        );
        assertTrue(isActive);

        // Check that all packets add up to total amount
        uint256[] memory packetIds = redEnvelope.getPacketsByEnvelope(0);
        uint256 totalDistributed = 0;

        for (uint256 i = 0; i < packetIds.length; i++) {
            (
                uint256 amount,
                string memory status,
                address receiver
            ) = redEnvelope.packets(packetIds[i]);
            totalDistributed += amount;
            assertEq(
                keccak256(abi.encodePacked(status)),
                keccak256(abi.encodePacked(PACKET_STATUS_UNCLAIMED))
            );
            assertEq(receiver, address(0));
        }

        assertEq(totalDistributed, envelopeAmount);

        vm.stopPrank();
    }

    function test_ClaimPacket() public {
        // First create an envelope
        vm.startPrank(deployer);
        uint256 envelopeAmount = 5 ether;
        uint256 numberOfPackets = 5;

        redEnvelope.createEnvelope{value: envelopeAmount}(
            numberOfPackets,
            ENVELOP_TYPE_EQUAL,
            "Test Equal Envelope"
        );
        vm.stopPrank();

        // Now claim as user1
        vm.startPrank(user1);

        uint256 user1BalanceBefore = user1.balance;

        redEnvelope.claimPacket(0, 0);

        // Check packet state
        (uint256 amount, string memory status, address receiver) = redEnvelope
            .packets(0);
        assertEq(
            keccak256(abi.encodePacked(status)),
            keccak256(abi.encodePacked(PACKET_STATUS_CLAIMED))
        );
        assertEq(receiver, user1);

        // Check user received the funds
        assertEq(user1.balance, user1BalanceBefore + amount);

        // Check envelope state
        (, , uint256 remainingAmount, , , , bool isActive, ) = redEnvelope
            .envelopes(0);
        assertEq(remainingAmount, envelopeAmount - amount);
        assertTrue(isActive);

        vm.stopPrank();
    }

    function testFail_ClaimSamePacketTwice() public {
        // Create envelope
        vm.prank(deployer);
        redEnvelope.createEnvelope{value: 1 ether}(
            5,
            ENVELOP_TYPE_EQUAL,
            "Test Equal Envelope"
        );

        // Claim same packet twice
        vm.startPrank(user1);
        redEnvelope.claimPacket(0, 0);
        redEnvelope.claimPacket(0, 0); // Should fail
        vm.stopPrank();
    }

    function testFail_WithdrawAsNonCreator() public {
        // Create envelope
        vm.prank(deployer);
        redEnvelope.createEnvelope{value: 1 ether}(
            5,
            ENVELOP_TYPE_EQUAL,
            "Test Equal Envelope"
        );

        // Try to withdraw as non-creator
        vm.prank(user1);
        redEnvelope.withdraw(0); // Should fail
    }

    function test_WithdrawUnclaimed() public {
        // Create envelope
        vm.prank(deployer);
        redEnvelope.createEnvelope{value: 5 ether}(
            5,
            ENVELOP_TYPE_EQUAL,
            "Test Equal Envelope"
        );

        // Let one user claim a packet
        vm.prank(user1);
        redEnvelope.claimPacket(0, 0);

        // Creator withdraws remaining
        vm.startPrank(deployer);
        uint256 deployerBalanceBefore = deployer.balance;
        redEnvelope.withdraw(0);

        // Check envelope is inactive
        (, , uint256 remainingAmount, , , , bool isActive, ) = redEnvelope
            .envelopes(0);
        assertEq(remainingAmount, 0);
        assertFalse(isActive);

        // Check deployer received funds
        assertTrue(deployer.balance > deployerBalanceBefore);
        vm.stopPrank();
    }
}
