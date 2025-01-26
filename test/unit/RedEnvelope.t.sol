// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/RedEnvelope.sol";

contract RedEnvelopeTest is Test {
    RedEnvelope private redEnvelope;
    address private creator;
    address private recipient;

    function setUp() public {
        // Khởi tạo hợp đồng RedEnvelope
        redEnvelope = new RedEnvelope();

        // Tạo các địa chỉ ví mẫu
        creator = address(0x123);
        recipient = address(0x456);

        // Gán giá trị ETH cho các ví
        vm.deal(creator, 10 ether);
        vm.deal(recipient, 10 ether);
    }

    function testCreateEnvelope() public {
        // Chuyển sang ví creator
        vm.startPrank(creator);

        // Tạo một Envelope với 5 Packet, chia đều
        uint256 numberOfPackets = 5;
        uint256 amount = 1 ether;
        redEnvelope.createEnvelope{value: amount}(
            numberOfPackets,
            "equal",
            "Happy New Year!"
        );

        // Kiểm tra xem Envelope đã được tạo thành công
        uint256 envelopeId = 0; // ID đầu tiên
        (address envelopeCreator, uint256 totalFund, , , , , , ) = redEnvelope
            .envelopes(envelopeId);
        assertEq(envelopeCreator, creator);
        assertEq(totalFund, amount);

        // Kiểm tra số lượng Packet
        RedEnvelope.Packet[] memory packets = redEnvelope.getPacketsByEnvelope(
            envelopeId
        );
        assertEq(packets.length, numberOfPackets);

        // Kiểm tra số tiền trong mỗi Packet
        uint256 amountPerPacket = amount / numberOfPackets;
        for (uint256 i = 0; i < packets.length; i++) {
            assertEq(packets[i].amount, amountPerPacket);
            assertEq(packets[i].status, "unclaimed");
            assertEq(packets[i].receiver, address(0));
        }

        vm.stopPrank();
    }

    function testClaimPacket() public {
        // Tạo Envelope
        vm.startPrank(creator);
        uint256 numberOfPackets = 5;
        uint256 amount = 1 ether;
        redEnvelope.createEnvelope{value: amount}(
            numberOfPackets,
            "equal",
            "Happy New Year!"
        );
        vm.stopPrank();

        // Chuyển sang ví recipient
        vm.startPrank(recipient);

        // Nhận Packet đầu tiên
        uint256 envelopeId = 0;
        uint256 packetId = 0;
        redEnvelope.claimPacket(envelopeId, packetId);

        // Kiểm tra trạng thái của Packet
        (, string memory status, address receiver) = redEnvelope.packets(
            packetId
        );
        assertEq(status, "claimed");
        assertEq(receiver, recipient);

        // Kiểm tra số dư của recipient
        assertEq(recipient.balance, 10 ether + (amount / numberOfPackets));

        // Kiểm tra remainingAmount của Envelope
        (, , uint256 remainingAmount, , , , , ) = redEnvelope.envelopes(
            envelopeId
        );
        assertEq(remainingAmount, amount - (amount / numberOfPackets));

        vm.stopPrank();
    }

    function testFailClaimPacketTwice() public {
        // Tạo Envelope
        vm.startPrank(creator);
        uint256 numberOfPackets = 5;
        uint256 amount = 1 ether;
        redEnvelope.createEnvelope{value: amount}(
            numberOfPackets,
            "equal",
            "Happy New Year!"
        );
        vm.stopPrank();

        // Chuyển sang ví recipient
        vm.startPrank(recipient);

        // Nhận Packet đầu tiên
        uint256 envelopeId = 0;
        uint256 packetId = 0;
        redEnvelope.claimPacket(envelopeId, packetId);

        // Thử nhận lại Packet đã nhận (sẽ fail)
        redEnvelope.claimPacket(envelopeId, packetId);

        vm.stopPrank();
    }

    function testGetContractBalance() public {
        // Tạo Envelope
        vm.startPrank(creator);
        uint256 numberOfPackets = 5;
        uint256 amount = 1 ether;
        redEnvelope.createEnvelope{value: amount}(
            numberOfPackets,
            "equal",
            "Happy New Year!"
        );
        vm.stopPrank();

        // Kiểm tra số dư của hợp đồng
        assertEq(redEnvelope.getContractBalance(), amount);
    }

    function testWithdrawUnclaimedPackets() public {
        // Tạo Envelope
        vm.startPrank(creator);
        uint256 numberOfPackets = 5;
        uint256 amount = 1 ether;
        redEnvelope.createEnvelope{value: amount}(
            numberOfPackets,
            "equal",
            "Happy New Year!"
        );
        vm.stopPrank();

        // Nhận một Packet
        vm.startPrank(recipient);
        redEnvelope.claimPacket(0, 0); // Envelope ID = 0, Packet ID = 0
        vm.stopPrank();

        // Rút tiền từ các Packet chưa được nhận
        vm.startPrank(creator);
        redEnvelope.withdraw(0); // Envelope ID = 0
        vm.stopPrank();

        // Kiểm tra số dư của creator
        uint256 expectedBalance = 10 ether - (amount / numberOfPackets); // Ban đầu 10 ether, sau khi tạo Envelope còn 9 ether, sau khi rút 4 Packet (0.8 ether) còn 9.8 ether
        assertEq(creator.balance, expectedBalance);

        // Kiểm tra trạng thái của Envelope
        (, , uint256 remainingAmount, , , , bool isActive, ) = redEnvelope
            .envelopes(0);
        assertEq(remainingAmount, 0); // 1 Packet đã được nhận, còn lại 4 Packet đã thu hồi
        assertEq(isActive, false); // Envelope không còn packet nào chưa được nhận nên không còn hoạt động

        // Kiểm tra trạng thái của các Packet
        vm.startPrank(creator);
        RedEnvelope.Packet[] memory packets = redEnvelope.getPacketsByEnvelope(
            0
        );
        vm.stopPrank();
        for (uint256 i = 0; i < packets.length; i++) {
            if (i == 0) {
                assertEq(packets[i].status, "claimed"); // Packet đã được nhận
            } else {
                assertEq(packets[i].status, "cancel"); // Các Packet chưa được nhận đã bị hủy
            }
        }
    }

    function testFailWithdrawNoUnclaimedPackets() public {
        // Tạo Envelope
        vm.startPrank(creator);
        uint256 numberOfPackets = 5;
        uint256 amount = 1 ether;
        redEnvelope.createEnvelope{value: amount}(
            numberOfPackets,
            "equal",
            "Happy New Year!"
        );
        vm.stopPrank();

        // Nhận tất cả các Packet
        vm.startPrank(recipient);
        for (uint256 i = 0; i < numberOfPackets; i++) {
            redEnvelope.claimPacket(0, i); // Nhận tất cả các Packet
        }
        vm.stopPrank();

        // Thử rút tiền (sẽ fail vì không còn Packet nào chưa được nhận)
        vm.startPrank(creator);
        redEnvelope.withdraw(0);
        vm.stopPrank();
    }

    function testFailWithdrawNotCreator() public {
        // Tạo Envelope
        vm.startPrank(creator);
        uint256 numberOfPackets = 5;
        uint256 amount = 1 ether;
        redEnvelope.createEnvelope{value: amount}(
            numberOfPackets,
            "equal",
            "Happy New Year!"
        );
        vm.stopPrank();

        // Thử rút tiền bằng một ví khác (sẽ fail)
        vm.startPrank(recipient);
        redEnvelope.withdraw(0);
        vm.stopPrank();
    }
}
