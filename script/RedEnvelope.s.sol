// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/RedEnvelope.sol";

contract RedEnvelopeScript is Script {
    // Địa chỉ của hợp đồng RedEnvelope (sẽ được deploy hoặc truyền vào)
    address public redEnvelopeAddress;

    // Hàm chạy script
    function run() external {
        // Lấy private key từ biến môi trường
        uint256 deployerPrivateKey = vm.envUint("ANVIL_PRIVATE_KEY");

        // Deploy hợp đồng RedEnvelope (nếu chưa có địa chỉ)
        if (redEnvelopeAddress == address(0)) {
            vm.startBroadcast(deployerPrivateKey);
            RedEnvelope newRedEnvelope = new RedEnvelope();
            redEnvelopeAddress = address(newRedEnvelope);
            vm.stopBroadcast();
            console.log("RedEnvelope deployed at:", redEnvelopeAddress);
        }

        // Tạo một Envelope mới
        vm.startBroadcast(deployerPrivateKey);
        RedEnvelope redEnvelope = RedEnvelope(redEnvelopeAddress);
        uint256 numberOfPackets = 5;
        uint256 amount = 1 ether;
        redEnvelope.createEnvelope{value: amount}(
            numberOfPackets,
            "equal",
            "Happy New Year!"
        );
        vm.stopBroadcast();
        console.log("Envelope created with ID: 0");

        // Nhận một Packet
        address recipient = address(0x123); // Địa chỉ ví người nhận
        uint256 recipientPrivateKey = vm.envUint("RECIPIENT_PRIVATE_KEY"); // Lấy private key của người nhận
        vm.startBroadcast(recipientPrivateKey);
        redEnvelope.claimPacket(0, 0); // Envelope ID = 0, Packet ID = 0
        vm.stopBroadcast();
        console.log("Packet 0 claimed by recipient:", recipient);

        // Rút tiền từ các Packet chưa được nhận
        vm.startBroadcast(deployerPrivateKey);
        redEnvelope.withdraw(0); // Envelope ID = 0
        vm.stopBroadcast();
        console.log("Withdrawn unclaimed packets from Envelope 0");
    }
}
