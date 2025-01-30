// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ConstantGlobal} from "./lib/constant.sol";
import {RandomHelper} from "./helpers/utils.sol";
import {NetworkConfig} from "./helpers/NetworkConfig.sol";
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
    mapping(uint256 => uint256) public packetToEnvelope;

    uint256 public nextEnvelopeId;
    uint256 public nextPacketId;

    NetworkConfig private networkConfig;

    event EnvelopeCreated(
        uint256 indexed envelopeId,
        address creator,
        uint256 totalAmount,
        uint256 numberOfPackets,
        string envelopeType,
        string message
    );
    event PacketClaimed(
        uint256 indexed envelopeId,
        uint256 indexed packetId,
        address receiver,
        uint256 amount
    );
    event EnvelopeClosed(uint256 indexed envelopeId, uint256 remainingAmount);
    event Withdrawn(
        uint256 indexed envelopeId,
        address creator,
        uint256 amount
    );

    modifier onlyEnvelopeCreator(uint256 envelopeId) {
        require(envelopes[envelopeId].creator == msg.sender, "Not creator");
        _;
    }

    modifier envelopeExists(uint256 envelopeId) {
        require(envelopeId < nextEnvelopeId, "Invalid envelope");
        _;
    }

    modifier packetExists(uint256 packetId) {
        require(packetId < nextPacketId, "Invalid packet");
        _;
    }

    modifier isActive(uint256 envelopeId) {
        require(envelopes[envelopeId].isActive, "Inactive envelope");
        _;
    }

    constructor() {
        networkConfig = new NetworkConfig();
    }

    // Hàm tạo Envelope
    function createEnvelope(
        uint256 _numberOfPackets,
        string memory _envelopeType,
        string memory _message
    ) external payable {
        require(_numberOfPackets > 0, "Invalid packet count");
        require(msg.value > 0, "Invalid amount");

        uint256 ethPriceInUSD = networkConfig.getLatestPriceInWei();
        require(ethPriceInUSD > 0, "Invalid price feed");
        uint256 minPacketValueInWei = (1 ether * 1e18) / ethPriceInUSD; // Tối thiểu 1 USD mỗi Packet
        bool isEqual = keccak256(abi.encodePacked(_envelopeType)) ==
            keccak256(abi.encodePacked(ENVELOP_TYPE_EQUAL));
        bool isRandom = keccak256(abi.encodePacked(_envelopeType)) ==
            keccak256(abi.encodePacked(ENVELOP_TYPE_RANDOM));
        require(isEqual || isRandom, "Invalid envelope type");

        if (isEqual) {
            require(
                msg.value >= _numberOfPackets * minPacketValueInWei,
                "Below min value"
            );
        } else {
            require(
                msg.value >= _numberOfPackets * minPacketValueInWei,
                "Below min value"
            );
        }

        uint256 envelopeId = nextEnvelopeId++;
        Envelope storage newEnvelope = envelopes[envelopeId];
        newEnvelope.creator = msg.sender;
        newEnvelope.totalFund = msg.value;
        newEnvelope.remainingAmount = msg.value;
        newEnvelope.numberOfPackets = _numberOfPackets;
        newEnvelope.envelopeType = _envelopeType;
        newEnvelope.message = _message;
        newEnvelope.isActive = true;
        newEnvelope.createdAt = block.timestamp;

        if (isEqual) {
            uint256 amountPerPacket = msg.value / _numberOfPackets;
            uint256 remainder = msg.value % _numberOfPackets;

            for (uint256 i = 0; i < _numberOfPackets; i++) {
                uint256 packetId = nextPacketId++;
                uint256 amount = amountPerPacket;
                if (i == _numberOfPackets - 1) {
                    amount += remainder;
                }

                packets[packetId] = Packet({
                    amount: amount,
                    status: PACKET_STATUS_UNCLAIMED,
                    receiver: address(0)
                });
                newEnvelope.packetIds.push(packetId);
                packetToEnvelope[packetId] = envelopeId;
            }
        } else {
            uint256 totalMin = _numberOfPackets * minPacketValueInWei;
            uint256 remainingAmount = msg.value - totalMin;

            for (uint256 i = 0; i < _numberOfPackets; i++) {
                uint256 packetId = nextPacketId++;
                uint256 amount = minPacketValueInWei;

                if (i == _numberOfPackets - 1) {
                    amount += remainingAmount;
                    remainingAmount = 0;
                } else if (remainingAmount > 0) {
                    uint256 randomAmount = random(remainingAmount);
                    amount += randomAmount;
                    remainingAmount -= randomAmount;
                }

                packets[packetId] = Packet({
                    amount: amount,
                    status: PACKET_STATUS_UNCLAIMED,
                    receiver: address(0)
                });
                newEnvelope.packetIds.push(packetId);
                packetToEnvelope[packetId] = envelopeId;
            }
        }

        emit EnvelopeCreated(
            envelopeId,
            msg.sender,
            msg.value,
            _numberOfPackets,
            _envelopeType,
            _message
        );
    }

    // Hàm nhận Packet
    function claimPacket(
        uint256 envelopeId,
        uint256 packetId
    )
        external
        envelopeExists(envelopeId)
        isActive(envelopeId)
        packetExists(packetId)
    {
        require(
            packetToEnvelope[packetId] == envelopeId,
            "Packet not in envelope"
        );
        Packet storage packet = packets[packetId];
        require(packet.receiver == address(0), "Already claimed");
        require(
            keccak256(abi.encodePacked(packet.status)) ==
                keccak256(abi.encodePacked(PACKET_STATUS_UNCLAIMED)),
            "Invalid status"
        );

        Envelope storage envelope = envelopes[envelopeId];
        uint256 amount = packet.amount;

        packet.receiver = msg.sender;
        packet.status = PACKET_STATUS_CLAIMED;
        envelope.remainingAmount -= amount;

        if (envelope.remainingAmount == 0) {
            envelope.isActive = false;
            emit EnvelopeClosed(envelopeId, 0);
        }

        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Transfer failed");

        emit PacketClaimed(envelopeId, packetId, msg.sender, amount);
    }

    // Hàm rút tiền từ các Packet chưa được nhận
    function withdraw(
        uint256 envelopeId
    )
        external
        envelopeExists(envelopeId)
        onlyEnvelopeCreator(envelopeId)
        isActive(envelopeId)
    {
        Envelope storage envelope = envelopes[envelopeId];
        uint256 totalUnclaimed = 0;

        for (uint256 i = 0; i < envelope.packetIds.length; i++) {
            uint256 pid = envelope.packetIds[i];
            Packet storage packet = packets[pid];
            if (
                keccak256(abi.encodePacked(packet.status)) ==
                keccak256(abi.encodePacked(PACKET_STATUS_UNCLAIMED))
            ) {
                totalUnclaimed += packet.amount;
                packet.status = PACKET_STATUS_CANCELLED;
            }
        }

        require(totalUnclaimed > 0, "No unclaimed packets");
        envelope.remainingAmount -= totalUnclaimed;
        envelope.isActive = false;

        (bool sent, ) = payable(msg.sender).call{value: totalUnclaimed}("");
        require(sent, "Transfer failed");

        emit Withdrawn(envelopeId, msg.sender, totalUnclaimed);
        emit EnvelopeClosed(envelopeId, envelope.remainingAmount);
    }

    function getPacketsByEnvelope(
        uint256 envelopeId
    ) public view returns (uint256[] memory) {
        return envelopes[envelopeId].packetIds;
    }

    function getPacketsByEnvelopeId(
        uint256 envelopeId
    ) public view returns (Packet[] memory) {
        uint256[] memory packetIds = getPacketsByEnvelope(envelopeId);
        Packet[] memory result = new Packet[](packetIds.length);

        for (uint256 i = 0; i < packetIds.length; i++) {
            result[i] = packets[packetIds[i]];
        }

        return result;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
