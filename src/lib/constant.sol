// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ConstantGlobal {
    string public constant ENVELOP_TYPE_EQUAL = "equal";
    string public constant ENVELOP_TYPE_RANDOM = "random";
    string public constant PACKET_STATUS_UNCLAIMED = "unclaimed";
    string public constant PACKET_STATUS_CLAIMED = "claimed";
    string public constant PACKET_STATUS_CANCELLED = "cancel";
}
