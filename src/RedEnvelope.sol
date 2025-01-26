// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ConstantGlobal} from "./lib/constant.sol";
import {RandomHelper} from "./helpers/utils.sol";

contract RedEnvelope is ConstantGlobal, RandomHelper {
    struct Envelope {
        address creator;
        uint256 totalFund;
        uint256 remainingAmount;
        uint256 numberOfPackets;
        string envelopeType;
        string message;
        bool isActive;
        uint256[] amounts;
    }

    mapping(uint256 => Envelope) public envelopes;
    uint256 public envelopeCounter;

    event EnvelopeCreated(
        uint256 indexed envelopeId,
        address indexed creator,
        uint256 totalAmount,
        uint256 numberOfPackets
    );
    event EnvelopeOpened(
        uint256 indexed envelopeId,
        address indexed receiver,
        uint256 amount
    );

    function createEnvelope(
        uint256 numberOfPackets,
        string memory envelopeType,
        string memory message
    ) external payable {
        require(msg.value > 0, "Amount must be greater than 0");
        require(
            numberOfPackets > 0,
            "Number of packets must be greater than 0"
        );

        uint256 envelopeId = envelopeCounter++;
        envelopes[envelopeId] = Envelope({
            creator: msg.sender,
            totalFund: msg.value,
            remainingAmount: msg.value,
            numberOfPackets: numberOfPackets,
            envelopeType: envelopeType,
            message: message,
            isActive: true,
            amounts: new uint256[](numberOfPackets)
        });

        if (stringsEqual(envelopeType, ENVELOP_TYPE_EQUAL)) {
            createEqualEnvelope(envelopeId, numberOfPackets);
        } else {
            createRandomEnvelope(envelopeId, numberOfPackets);
        }

        emit EnvelopeCreated(
            envelopeId,
            msg.sender,
            msg.value,
            numberOfPackets
        );
    }

    function openEnvelope(uint256 envelopeId) external {
        require(envelopes[envelopeId].isActive, "Envelope is not active");
        require(envelopes[envelopeId].remainingAmount > 0, "Envelope is empty");

        uint256 amount = envelopes[envelopeId].amounts[
            envelopes[envelopeId].amounts.length - 1
        ];
        envelopes[envelopeId].amounts.pop();
        envelopes[envelopeId].remainingAmount -= amount;
        envelopes[envelopeId].numberOfPackets--;

        if (envelopes[envelopeId].numberOfPackets == 0) {
            envelopes[envelopeId].isActive = false;
        }

        payable(msg.sender).transfer(amount);
        emit EnvelopeOpened(envelopeId, msg.sender, amount);
    }

    function createEqualEnvelope(
        uint256 envelopeId,
        uint256 numberOfPackets
    ) private {
        uint256 amountPerPacket = envelopes[envelopeId].totalFund /
            numberOfPackets;
        for (uint256 i = 0; i < numberOfPackets; i++) {
            envelopes[envelopeId].amounts[i] = amountPerPacket;
        }
    }

    function createRandomEnvelope(
        uint256 envelopeId,
        uint256 numberOfPackets
    ) private {
        uint256 remainingAmount = envelopes[envelopeId].totalFund;
        for (uint256 i = 0; i < numberOfPackets - 1; i++) {
            uint256 amount = random(remainingAmount);
            envelopes[envelopeId].amounts[i] = amount;
            remainingAmount -= amount;
        }
        envelopes[envelopeId].amounts[numberOfPackets - 1] = remainingAmount;
    }
}
