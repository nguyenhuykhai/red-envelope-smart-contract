// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IRedEnvelope {
    // Structs
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

    // Events (nếu cần)
    event EnvelopeCreated(uint256 indexed envelopeId, address indexed creator);
    event PacketClaimed(
        uint256 indexed envelopeId,
        uint256 indexed packetId,
        address indexed receiver
    );
    event Withdrawn(
        uint256 indexed envelopeId,
        address indexed creator,
        uint256 amount
    );

    // Functions
    function createEnvelope(
        uint256 _numberOfPackets,
        string memory _envelopeType,
        string memory _message
    ) external payable;

    function getPacketsByEnvelope(
        uint256 envelopeId
    ) external view returns (Packet[] memory);

    function claimPacket(uint256 envelopeId, uint256 packetId) external;

    function getContractBalance() external view returns (uint256);

    function withdraw(uint256 envelopeId) external;

    // Public variables
    function envelopes(
        uint256 envelopeId
    )
        external
        view
        returns (
            address creator,
            uint256 totalFund,
            uint256 remainingAmount,
            uint256 numberOfPackets,
            string memory envelopeType,
            string memory message,
            bool isActive,
            uint256 createdAt,
            uint256[] memory packetIds
        );

    function packets(
        uint256 packetId
    )
        external
        view
        returns (uint256 amount, string memory status, address receiver);

    function nextEnvelopeId() external view returns (uint256);
    function nextPacketId() external view returns (uint256);
}
