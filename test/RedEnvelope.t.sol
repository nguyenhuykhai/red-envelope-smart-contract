// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {RedEnvelope} from "../src/RedEnvelope.sol";

contract RedEnvelopeTest is Test, RedEnvelope {
    RedEnvelope public redEnvelope;
    address public creator = address(0x123);
    address public receiver = address(0x456);

    function setUp() public {
        // Deploy the RedEnvelope contract
        redEnvelope = new RedEnvelope();

        // Fund the creator and receiver with some Ether
        vm.deal(creator, 10 ether);
        vm.deal(receiver, 10 ether);
    }

    // Test creating an envelope with equal distribution
    function testCreateEqualEnvelope() public {
        vm.prank(creator);
        Envelope envelopes = redEnvelope.createEnvelope{value: 1 ether}(
            5,
            "equal",
            "Happy New Year"
        );

        // Check envelope details
        // (
        //     address envelopeCreator,
        //     uint256 totalFund,
        //     uint256 remainingAmount,
        //     bool isActive,
        // ) = redEnvelope.envelopes;
        // assertEq(envelopeCreator, creator);
        // assertEq(totalFund, 1 ether);
        // assertEq(remainingAmount, 1 ether);
        // assertEq(isActive, true);
        console.log("ENVELOPE: ", envelopes);
    }

    // Test creating an envelope with random distribution
    // function testCreateRandomEnvelope() public {
    //     vm.prank(creator);
    //     redEnvelope.createEnvelope{value: 1 ether}(
    //         5,
    //         "random",
    //         "Happy New Year"
    //     );

    //     // Check envelope details
    //     (
    //         address envelopeCreator,
    //         uint256 totalFund,
    //         uint256 remainingAmount,
    //         ,
    //         ,
    //         ,
    //         bool isActive,

    //     ) = redEnvelope.envelopes(0);
    //     assertEq(envelopeCreator, creator);
    //     assertEq(totalFund, 1 ether);
    //     assertEq(remainingAmount, 1 ether);
    //     assertEq(isActive, true);
    // }

    // // Test opening an envelope
    // function testOpenEnvelope() public {
    //     // Create an envelope
    //     vm.prank(creator);
    //     redEnvelope.createEnvelope{value: 1 ether}(
    //         5,
    //         "equal",
    //         "Happy New Year"
    //     );

    //     // Open the envelope
    //     vm.prank(receiver);
    //     redEnvelope.openEnvelope(0);

    //     // Check envelope state after opening
    //     (
    //         uint256 remainingAmount,
    //         uint256 numberOfPackets,
    //         bool isActive,

    //     ) = redEnvelope.envelopes(0);
    //     assertEq(remainingAmount, 0.8 ether); // 1 ether - 0.2 ether (1/5 of 1 ether)
    //     assertEq(numberOfPackets, 4);
    //     assertEq(isActive, true);

    //     // Check receiver's balance increased
    //     assertEq(receiver.balance, 10 ether + 0.2 ether);
    // }

    // // Test opening all packets in an envelope
    // function testOpenAllPackets() public {
    //     // Create an envelope
    //     vm.prank(creator);
    //     redEnvelope.createEnvelope{value: 1 ether}(
    //         5,
    //         "equal",
    //         "Happy New Year"
    //     );

    //     // Open all packets
    //     for (uint256 i = 0; i < 5; i++) {
    //         vm.prank(receiver);
    //         redEnvelope.openEnvelope(0);
    //     }

    //     // Check envelope state after all packets are opened
    //     (
    //         uint256 remainingAmount,
    //         uint256 numberOfPackets,
    //         bool isActive,

    //     ) = redEnvelope.envelopes(0);
    //     assertEq(remainingAmount, 0);
    //     assertEq(numberOfPackets, 0);
    //     assertEq(isActive, false);

    //     // Check receiver's balance increased by 1 ether
    //     assertEq(receiver.balance, 10 ether + 1 ether);
    // }

    // // Test creating an envelope with zero Ether
    // function testCreateEnvelopeZeroEther() public {
    //     vm.prank(creator);
    //     vm.expectRevert("Amount must be greater than 0");
    //     redEnvelope.createEnvelope{value: 0}(5, "equal", "Happy New Year");
    // }

    // // Test creating an envelope with zero packets
    // function testCreateEnvelopeZeroPackets() public {
    //     vm.prank(creator);
    //     vm.expectRevert("Number of packets must be greater than 0");
    //     redEnvelope.createEnvelope{value: 1 ether}(
    //         0,
    //         "equal",
    //         "Happy New Year"
    //     );
    // }

    // // Test opening an inactive envelope
    // function testOpenInactiveEnvelope() public {
    //     // Create an envelope
    //     vm.prank(creator);
    //     redEnvelope.createEnvelope{value: 1 ether}(
    //         5,
    //         "equal",
    //         "Happy New Year"
    //     );

    //     // Open all packets to deactivate the envelope
    //     for (uint256 i = 0; i < 5; i++) {
    //         vm.prank(receiver);
    //         redEnvelope.openEnvelope(0);
    //     }

    //     // Try to open the inactive envelope
    //     vm.prank(receiver);
    //     vm.expectRevert("Envelope is not active");
    //     redEnvelope.openEnvelope(0);
    // }

    // // Test opening an empty envelope
    // function testOpenEmptyEnvelope() public {
    //     // Create an envelope
    //     vm.prank(creator);
    //     redEnvelope.createEnvelope{value: 1 ether}(
    //         5,
    //         "equal",
    //         "Happy New Year"
    //     );

    //     // Open all packets to empty the envelope
    //     for (uint256 i = 0; i < 5; i++) {
    //         vm.prank(receiver);
    //         redEnvelope.openEnvelope(0);
    //     }

    //     // Try to open the empty envelope
    //     vm.prank(receiver);
    //     vm.expectRevert("Envelope is empty");
    //     redEnvelope.openEnvelope(0);
    // }
}
