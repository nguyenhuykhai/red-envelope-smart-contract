// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ConstantGlobal} from "./lib/constant.sol";
import {RandomHelper} from "./helpers/utils.sol";

contract RedEnvelope is ConstantGlobal, RandomHelper {
    struct Packet {
        uint256 amount;
        string status;
        address receiver;
    }

    struct Envelope {
        address creator;
        uint256 totalFund;
        uint256 remainingAmount;
        uint256 numberOfPackets;
        string envelopeType;
        string message;
        bool isActive;
        uint256 createdAt;
        uint256[] packetIds;
    }

    mapping(uint256 => Envelope) public envelopes;
    mapping(uint256 => Packet) public packets;

    uint256 public nextEnvelopeId; // Biến đếm để tạo ID cho Envelope
    uint256 public nextPacketId; // Biến đếm để tạo ID cho Packet

    function createEnvelope(
        uint256 _numberOfPackets,
        string memory _envelopeType,
        string memory _message
    ) public payable {
        require(
            _numberOfPackets > 0,
            "Number of packets must be greater than 0"
        );
        require(msg.value > 0, "Amount must be greater than 0");

        uint256 envelopeId = nextEnvelopeId++;
        envelopes[envelopeId] = Envelope({
            creator: msg.sender,
            totalFund: msg.value,
            remainingAmount: msg.value,
            numberOfPackets: _numberOfPackets,
            envelopeType: _envelopeType,
            message: _message,
            isActive: true,
            createdAt: block.timestamp,
            packetIds: new uint256[](0)
        });

        if (stringsEqual(_envelopeType, ENVELOP_TYPE_EQUAL)) {
            uint256 amountPerPacket = msg.value / _numberOfPackets;
            for (uint256 i = 0; i < _numberOfPackets; i++) {
                uint256 packetId = nextPacketId++;
                packets[packetId] = Packet({
                    amount: amountPerPacket,
                    status: "unclaimed",
                    receiver: address(0)
                });
                envelopes[envelopeId].packetIds.push(packetId);
            }
        } else if (stringsEqual(_envelopeType, ENVELOP_TYPE_RANDOM)) {
            uint256 remainingAmount = msg.value;
            for (uint256 i = 0; i < _numberOfPackets; i++) {
                uint256 packetId = nextPacketId++;
                uint256 amount = (i == _numberOfPackets - 1)
                    ? remainingAmount
                    : random(remainingAmount);
                packets[packetId] = Packet({
                    amount: amount,
                    status: "unclaimed",
                    receiver: address(0)
                });
                envelopes[envelopeId].packetIds.push(packetId);
                remainingAmount -= amount;
            }
        }
    }

    function getPacketsByEnvelope(
        uint256 envelopeId
    ) public view returns (Packet[] memory) {
        require(
            envelopes[envelopeId].creator == msg.sender,
            "Only creator can view packets"
        );

        uint256[] memory packetIds = envelopes[envelopeId].packetIds;
        Packet[] memory result = new Packet[](packetIds.length);

        for (uint256 i = 0; i < packetIds.length; i++) {
            result[i] = packets[packetIds[i]];
        }

        return result;
    }

    function claimPacket(uint256 envelopeId, uint256 packetId) public {
        require(envelopes[envelopeId].isActive, "Envelope is not active");
        require(
            packets[packetId].receiver == address(0),
            "Packet already claimed"
        );
        require(
            stringsEqual(packets[packetId].status, PACKET_STATUS_UNCLAIMED),
            "Packet already claimed"
        );
        require(
            stringsNotEqual(packets[packetId].status, PACKET_STATUS_CANCEL),
            "Packet is canceled"
        );

        // Cập nhật thông tin Packet
        packets[packetId].receiver = msg.sender;
        packets[packetId].status = "claimed";

        // Chuyển tiền đến người nhận
        payable(msg.sender).transfer(packets[packetId].amount);

        // Cập nhật remainingAmount của Envelope
        envelopes[envelopeId].remainingAmount -= packets[packetId].amount;

        // Nếu tất cả Packet đã được nhận, đánh dấu Envelope là không hoạt động
        if (envelopes[envelopeId].remainingAmount == 0) {
            envelopes[envelopeId].isActive = false;
        }
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw(uint256 envelopeId) public {
        // Kiểm tra chỉ người tạo Envelope mới có thể gọi hàm này
        require(
            envelopes[envelopeId].creator == msg.sender,
            "Only creator can withdraw"
        );

        // Kiểm tra Envelope phải còn hoạt động
        require(envelopes[envelopeId].isActive, "Envelope is not active");

        // Tính tổng số tiền từ các Packet chưa được nhận
        uint256 totalUnclaimedAmount = 0;
        uint256[] memory packetIds = envelopes[envelopeId].packetIds;

        for (uint256 i = 0; i < packetIds.length; i++) {
            if (
                stringsEqual(
                    packets[packetIds[i]].status,
                    PACKET_STATUS_UNCLAIMED
                )
            ) {
                totalUnclaimedAmount += packets[packetIds[i]].amount;
                // Đánh dấu Packet là "cancel"
                packets[packetIds[i]].status = "cancel";
            }
        }

        // Kiểm tra có Packet nào chưa được nhận không
        require(totalUnclaimedAmount > 0, "No unclaimed packets to withdraw");

        // Chuyển tiền về ví của người tạo

        payable(msg.sender).transfer(totalUnclaimedAmount);

        // Cập nhật remainingAmount của Envelope
        envelopes[envelopeId].remainingAmount -= totalUnclaimedAmount;

        // Nếu không còn Packet nào hoạt động, đánh dấu Envelope là không hoạt động
        if (envelopes[envelopeId].remainingAmount == 0) {
            envelopes[envelopeId].isActive = false;
        }
    }
}
